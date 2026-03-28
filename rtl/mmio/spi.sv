module spi_peripheral(
    input  logic clk,
    input  logic rst,

    output logic sclk,
    output logic mosi,
    input  logic miso,
    output logic cs_n,

    axi_lite_if.slave axi
);
    localparam DATA_ADDR = 32'h8000_0000;
    localparam CTRL_ADDR = 32'h8000_0004;

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

    logic [1:0] byte_count, total_bytes;
    logic [3:0] wstrb_d;

    always_ff @(posedge clk) begin
        if(!rst)
            wstrb_d <= 4'b0000;
        else begin
            if(send_slave_write && slave_waddr == DATA_ADDR)
                wstrb_d <= slave_wstrb;
            else if(send_slave_read)
                wstrb_d <= 4'b1111;
        end
    end

    always_comb begin
        case (wstrb_d)
            4'b0001, 4'b0010, 4'b0100, 4'b1000: total_bytes = 2'b00;
            4'b0011, 4'b1100: total_bytes = 2'b01;
            4'b1111: total_bytes = 2'b11;
            default: total_bytes = 2'b00;
        endcase
    end

    reg [7:0] tx_reg, rx_reg;
    logic clk_en;
    logic [2:0] bit_count;
    logic [6:0] clk_count;
    logic sclk_internal, sclk_toggle;

    always_ff @(posedge clk) begin
        if(!rst) begin 
            sclk_internal <= 1'b1;
            sclk_toggle <= 1'b0;
            clk_count <= '0;
        end else begin
            if(clk_en) begin
                if(clk_count >= CTRL[11:5]) begin 
                    clk_count <= '0;
                    sclk_internal <= ~sclk_internal;
                    sclk_toggle <= 1'b1;
                end else begin
                    clk_count <= clk_count + 1;
                    sclk_toggle <= 1'b0;
                end
            end else begin
                sclk_internal <= 1'b1;
                sclk_toggle <= 1'b0;
            end
        end
    end

    logic reading, writing;
    assign clk_en = (reading || writing) && !cs_n;
    assign mosi = (state == TRANSFER) ? tx_reg[7] : 1'b0;
    assign sclk = (state == TRANSFER) ? sclk_internal : 1'b1;

    logic [31:0] rx_buffer;

    always_ff @(posedge clk) begin
        if(!rst) begin
            tx_reg <= '0;
            rx_reg <= '0;
            bit_count <= '0;
            byte_count <= '0;
            slave_write_done <= '0;
            slave_read_done <= '0;
            slave_rdata <= '0;
            slave_bresp <= '0;
            slave_rresp <= '0;
            CTRL <= 32'h1;
            DATA <= '0;
            cs_n <= 1'b1;
            reading <= 1'b0;
            writing <= 1'b0;
            state <= IDLE;
            rx_buffer <= '0;

        end else begin

            slave_write_done <= 1'b0;
            slave_read_done  <= 1'b0;

            cs_n <= CTRL[0];

            case(state)
                IDLE: begin
                    bit_count  <= 0;
                    byte_count <= 0;

                    if (send_slave_write) begin
                        case(slave_waddr)
                            DATA_ADDR: begin
                                writing <= 1'b1;
                                DATA <= slave_wdata;
                                tx_reg <= slave_wdata[31:24];
                                state <= TRANSFER;
                            end
                            CTRL_ADDR: begin
                                CTRL <= slave_wdata;
                                slave_write_done <= 1'b1;
                                slave_bresp <= 2'b00;
                            end
                        endcase
                    end

                    if(send_slave_read) begin
                        reading <= 1'b1;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if(bit_count == 0) begin
                        if (writing)
                            case(byte_count)
                                2'd0: tx_reg <= DATA[31:24];
                                2'd1: tx_reg <= DATA[23:16];
                                2'd2: tx_reg <= DATA[15:8];
                                2'd3: tx_reg <= DATA[7:0];
                            endcase
                        else
                            tx_reg <= 8'hFF;
                    end

                    if (sclk_toggle) begin
                        if (!sclk_internal) begin
                            tx_reg <= {tx_reg[6:0], 1'b0};
                            bit_count <= bit_count + 1;
                        end

                        if (sclk_internal)
                            rx_reg <= {rx_reg[6:0], miso};

                        if (!sclk_internal && bit_count >= 3'd7) begin
                            case(byte_count)
                                2'd0: rx_buffer[31:24] <= rx_reg;
                                2'd1: rx_buffer[23:16] <= rx_reg;
                                2'd2: rx_buffer[15:8] <= rx_reg;
                                2'd3: rx_buffer[7:0] <= rx_reg;
                            endcase
                            if (byte_count < total_bytes) begin
                                byte_count <= byte_count + 1;
                                bit_count <= 0;
                            end else begin
                                state <= DONE;
                            end
                        end
                    end
                end

                DONE: begin
                    if(writing) begin
                        slave_write_done <= 1'b1;
                        slave_bresp <= 2'b00;
                        writing <= 1'b0;
                    end

                    if(reading) begin
                        slave_rdata <= rx_buffer;
                        slave_read_done <= 1'b1;
                        slave_rresp <= 2'b00;
                        reading <= 1'b0;
                    end

                    if(slave_write_done || slave_read_done)
                        state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule