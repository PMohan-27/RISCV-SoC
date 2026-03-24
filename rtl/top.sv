module top(
    input logic clk, rst,

    //spi pins
    output logic sclk,
    output logic mosi,
    input logic miso,
    output logic cs_n

);
    logic [31:0] data_rdata;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic data_we, data_re;
    logic [2:0]  data_type;
    logic data_done;

    logic [31:0] ctrl_rdata;
    logic ctrl_write_done;
    logic ctrl_read_done;
    logic [1:0] ctrl_bresp;
    logic [1:0] ctrl_rresp;
    logic [31:0] ctrl_waddr;
    logic [31:0] ctrl_raddr;
    logic [31:0] ctrl_wdata;
    logic [3:0] ctrl_wstrb;
    logic ctrl_write_req;
    logic ctrl_read_req;

    logic [31:0] instr_data; 
    logic instr_valid;
    logic [31:0] instr_addr;
    logic instr_ready;
    logic flush_instr;

    logic [31:0] mmio_addr;
    logic [31:0] mmio_wdata;
    logic mmio_we, mmio_re;
    logic [2:0] mmio_type;
    logic [31:0] mmio_rdata;
    logic mmio_done;

    logic [31:0] sdram_addr;
    logic [31:0] sdram_wdata;
    logic sdram_we, sdram_re;
    logic [2:0] sdram_type;
    logic [31:0] sdram_rdata;
    logic sdram_done;

    axi_lite_if cpu(.ACLK(clk), .ARESETn(rst) );
    axi_lite_if spi(.ACLK(clk), .ARESETn(rst) );

    cpu cpu_inst(
        .clk(clk),
        .rst(rst),
        .data_rdata(data_rdata),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_we(data_we),
        .data_re(data_re),
        .data_type(data_type),
        .data_done(data_done),

        .instr_data(instr_data), 
        .instr_valid(1'b1),
        .instr_addr(instr_addr),
        .instr_ready(instr_ready),
        .flush_instr(flush_instr)
    );

    cpu_axi_master_bridge cpu_axi_bridge(
        .clk(clk),
        .rst(rst),

        .data_addr (mmio_addr),
        .data_wdata(mmio_wdata),
        .data_we   (mmio_we),
        .data_re   (mmio_re),
        .data_type (mmio_type),
        .data_rdata(mmio_rdata),
        .data_done (mmio_done),

        .ctrl_rdata(ctrl_rdata),
        .ctrl_write_done(ctrl_write_done),
        .ctrl_read_done(ctrl_read_done),
        .ctrl_bresp(ctrl_bresp),
        .ctrl_rresp(ctrl_rresp),
        .ctrl_waddr(ctrl_waddr),
        .ctrl_raddr(ctrl_raddr),
        .ctrl_wdata(ctrl_wdata),
        .ctrl_wstrb(ctrl_wstrb),
        .ctrl_write_req(ctrl_write_req),
        .ctrl_read_req(ctrl_read_req)
    );

    instruction_memory instr_mem_inst(
        .address(instr_addr),
        .instruction(instr_data)
    );

    data_interconnect data_interconnect_inst(
        .data_addr   (data_addr),
        .data_wdata  (data_wdata),
        .data_we     (data_we),
        .data_re     (data_re),
        .data_type   (data_type),
        .data_rdata  (data_rdata),
        .data_done   (data_done),

        .mmio_data_addr   (mmio_addr),
        .mmio_data_wdata  (mmio_wdata),
        .mmio_data_we     (mmio_we),
        .mmio_data_re     (mmio_re),
        .mmio_data_type   (mmio_type),
        .mmio_data_rdata  (mmio_rdata),
        .mmio_data_done   (mmio_done),

        .sdram_data_addr  (sdram_addr),
        .sdram_data_wdata (sdram_wdata),
        .sdram_data_we    (sdram_we),
        .sdram_data_re    (sdram_re),
        .sdram_data_type  (sdram_type),
        .sdram_data_rdata (sdram_rdata),
        .sdram_data_done  (sdram_done)
    );
    axi4_lite_master axi_lite_cpu_master(
        .ctrl_rdata(ctrl_rdata),
        .ctrl_write_done(ctrl_write_done),
        .ctrl_read_done(ctrl_read_done),
        .ctrl_bresp(ctrl_bresp),
        .ctrl_rresp(ctrl_rresp),
        .ctrl_waddr(ctrl_waddr),
        .ctrl_raddr(ctrl_raddr),
        .ctrl_wdata(ctrl_wdata),
        .ctrl_wstrb(ctrl_wstrb),
        .ctrl_write_req(ctrl_write_req),
        .ctrl_read_req(ctrl_read_req),

        .axi(cpu)
    );

    axi4_lite_interconnect axi4_lite_interconnect_inst(
        .cpu(cpu),
        .spi(spi)
    );


    spi_peripheral spi_inst(
        .clk(clk),
        .rst(rst),

        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n),

        .axi(spi)
    );

    
endmodule