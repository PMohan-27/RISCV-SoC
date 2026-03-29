module gpio_peripheral(
    input  logic clk,
    input  logic rst,

    inout logic [15:0] gpio_pins,

    axi_lite_if.slave axi
);
    localparam GPIO_ADDR = 32'h8000_0008;

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

    logic [15:0] gpio_data, gpio_dir, gpio_read;
    always_ff @(posedge clk) begin
        if(!rst) begin
            slave_write_done <= 1'b0;
            gpio_data <= '0;
            gpio_dir <= '0;
            slave_write_done <= '0;
            slave_bresp <= '0;
            slave_read_done <= '0;
        end else begin
            if (send_slave_write && slave_waddr == GPIO_ADDR) begin
                slave_write_done <= 1'b1;
                slave_bresp <= 2'b00;
                if (slave_wstrb[0]) gpio_data[7:0] <= slave_wdata[7:0];
                if (slave_wstrb[1]) gpio_data[15:8] <= slave_wdata[15:8];
                if (slave_wstrb[2]) gpio_dir[7:0] <= slave_wdata[23:16];
                if (slave_wstrb[3]) gpio_dir[15:8] <= slave_wdata[31:24];
            end else slave_write_done <= 1'b0;
            if (send_slave_read && slave_raddr == GPIO_ADDR) begin
                slave_rdata     <= {gpio_dir, gpio_read};
                slave_read_done <= 1'b1;
                slave_rresp     <= 2'b00;
            end else slave_read_done <= 1'b0;
        end
    end
    genvar i;
    generate 
        for(i = 0; i < 16; i++)begin
            assign gpio_pins[i]  = gpio_dir[i] ? gpio_data[i] : 1'bz;
        end
    endgenerate

    assign gpio_read = gpio_pins;

endmodule