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

    //clk 60 MHz -> 10Mhz SCLK    
    logic [1:0] clk_count;
    always_ff @(posedge clk) begin
        if(!rst) begin 
            sclk <= '1;
            clk_count <= '0;
        end
        else begin
            if(clk_count >= 2'b10) begin 
                clk_count <= '0;
                sclk <= ~sclk;
            end
            else clk_count <= clk_count + 1;
        end
    end

    reg [31:0] tx_reg [0:256];
    integer i;
    always_ff @(posedge clk) begin
        if (!rst) begin
            slave_write_done <= '0;
            slave_bresp      <= '0;
            for (i = 0; i <= 256; i = i + 1)
                tx_reg[i] <= '0;
        end else begin
            if (send_slave_write) begin
                /* verilator lint_off WIDTHTRUNC */
                tx_reg[slave_waddr[31:2]] <= slave_wdata;
                slave_write_done <= '1;
                slave_bresp      <= 2'b00;
            end 
            if (send_slave_read) begin
                slave_rdata     <= tx_reg[slave_raddr[31:2]];
                slave_read_done <= 1'b1;
                slave_rresp     <= 2'b00;
            end else
                slave_read_done <= 1'b0;
        end
    end

endmodule