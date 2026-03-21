module spi_peripheral(
    input  logic clk,
    input  logic rst,

    output logic sclk,
    output logic mosi,
    input  logic miso,
    output logic cs_n,

    axi_lite_if.slave axi
);


    logic [31:0] slave_raddr, slave_waddr;
    logic [31:0] slave_wdata;
    logic [3:0]  slave_wstrb;
    logic        send_slave_write, send_slave_read;
    logic [31:0] slave_rdata;
    logic        slave_write_done, slave_read_done;
    logic [1:0]  slave_rresp, slave_bresp;

    axi4_lite_slave axi_slave(
        .slave_raddr(slave_raddr),
        .slave_waddr(slave_waddr),
        .slave_wdata(slave_wdata),
        .slave_wstrb(slave_wstrb),
        .send_slave_write(send_slave_write),
        .send_slave_read(send_slave_read),
        .slave_rdata(slave_rdata),
        .slave_write_done(slave_write_done),
        .slave_read_done(slave_read_done),
        .slave_rresp(slave_rresp),
        .slave_bresp(slave_bresp),
        .axi(axi)
    );
    typedef enum logic [1:0] {IDLE, TRANSFER, DONE} spi_state_t;
    spi_state_t state;

    reg [31:0] CTRL, DATA;

    always_ff @(posedge clk) begin
        if (!rst) state <= IDLE;
        else begin 
            case(state) 
                IDLE: if(reading || writing) state <= TRANSFER;
                TRANSFER: if(bit_count >= 'd33) state <= DONE;
                DONE: if(slave_write_done || slave_read_done) state <= IDLE; 
                default: state <= IDLE;
            endcase
        end
    end
    //clk 60 MHz -> 10Mhz SCLK    
    reg [31:0] tx_reg, rx_reg;
    logic clk_en;
    logic [6:0] bit_count;
    logic [3:0] clk_count;
    logic sclk_d, sclk_rise, sclk_fall; 
    
    always_ff @(posedge clk) begin
        if(!rst) begin 
            sclk <= '1;
            clk_count <= '0;
        end
        else begin
            if(clk_count >= CTRL[8:5] && clk_en) begin 
                clk_count <= '0;
                sclk <= ~sclk;
            end
            else clk_count <= clk_count + 1;
            sclk_d <= sclk;
        end

    end
    assign clk_en = reading | writing;
    assign sclk_rise = sclk & ~sclk_d;
    assign sclk_fall = ~sclk &  sclk_d;
    logic reading, writing;
    always_ff @(posedge clk) begin
        if(!rst) begin
            tx_reg <= '0;
            rx_reg <= '0;
            bit_count <= '0;
            slave_write_done <= '0;
            slave_bresp <= '0;
            CTRL <= '0;
            DATA <= '0;
        end else begin
            case(state) 
                IDLE: begin
                    if (send_slave_write) begin
                    case(slave_waddr)
                        32'h0000:
                        begin
                            writing <= 1'b1;
                            DATA <= slave_wdata;
                        end
                        32'h0004: begin
                            CTRL <= slave_wdata;
                            slave_write_done <= 1'b1;
                            slave_bresp <= 2'b00;
                        end
                    endcase
                    end else slave_write_done <= 1'b0;
                    if(send_slave_read) reading <= 1'b1;
                    bit_count <= '0;
                    
                    if(reading || writing) begin
                        if(writing) begin
                            tx_reg <= DATA;
                        end 
                        cs_n <= 1'b0;   
                    end else begin
                        cs_n <= 1'b1;
                        tx_reg <= '0;
                    end
                end
                TRANSFER: begin
                     if(sclk_fall) begin
                        bit_count <= bit_count + 1;
                        mosi <= tx_reg[31];
                        tx_reg <= {tx_reg[30:0], 1'b0};
                    end
                    if(sclk_rise) begin
                        rx_reg <= {rx_reg[30:0], miso};
                    end
                end
                DONE: begin
                    cs_n <= 1'b1;
                    writing <= 1'b0;
                    reading <= 1'b0;
                    if(writing) begin
                        slave_write_done <= 1'b1;
                        slave_bresp <= 2'b00;
                    end
                    if(reading) begin
                        slave_read_done <= 1'b1;
                        slave_rresp <= 2'b00;
                    end
                end
                default: ;
            endcase 
        end
    end
        

endmodule