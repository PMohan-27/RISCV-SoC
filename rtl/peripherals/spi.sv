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

    // TODO: SPI

endmodule