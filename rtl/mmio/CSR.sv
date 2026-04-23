module CSR_peripheral(
    input  logic clk,
    input  logic rst,

    axi_lite_if.slave axi
);
    localparam CSR_CLOCK_CYCLES = 32'h8000_000C;

    logic [31:0] slave_raddr, slave_waddr;
    logic [31:0] slave_wdata;
    logic [3:0] slave_wstrb;
    logic send_slave_write, send_slave_read;
    logic [31:0] slave_rdata;
    logic slave_write_done, slave_read_done;
    logic [1:0] slave_rresp, slave_bresp;

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

    logic [31:0] clock_cycles; // Address: 32'h8000_000C

    always_ff @(posedge clk) begin
        if(!rst) begin
            clock_cycles <= '0;
        end else begin
            slave_read_done <= 1'b0;
            clock_cycles <= clock_cycles + 1'b1;
            if(send_slave_read && slave_raddr <= CSR_CLOCK_CYCLES) begin
                slave_rdata <= clock_cycles;
                slave_read_done <= 1'b1;
                slave_rresp <= '0;
            end
        end
    end

endmodule