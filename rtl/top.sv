module top(
    input logic clk, rst,

    //spi pins
    output logic sclk,
    output logic mosi,
    input logic miso,
    output logic cs_n,

    inout logic [15:0] gpio_pins
);

    logic [31:0] data_rdata;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic data_we, data_re;
    logic [2:0] data_type;
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

    logic [31:0] instr_data_boot;
    logic [31:0] instr_data_sdram;
    logic instr_valid_boot;
    logic instr_valid_sdram;
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

    logic I_sdrc_rst_n;
    logic I_sdrc_clk;
    logic I_sdram_clk;
    logic I_sdrc_cmd_en;
    logic [2:0] I_sdrc_cmd;
    logic I_sdrc_precharge_ctrl;
    logic I_sdram_power_down;
    logic I_sdram_selfrefresh;
    logic [20:0] I_sdrc_addr;
    logic [3:0] I_sdrc_dqm;
    logic [31:0] I_sdrc_data;
    logic [7:0] I_sdrc_data_len;
    logic [31:0] O_sdrc_data;
    logic O_sdrc_init_done;
    logic O_sdrc_cmd_ack;

    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic mem_we;
    logic mem_re;
    logic [7:0] mem_len;
    logic [31:0] mem_rdata;
    logic mem_valid;

    axi_lite_if cpu(.ACLK(clk), .ARESETn(rst));
    axi_lite_if spi(.ACLK(clk), .ARESETn(rst));
    axi_lite_if gpio(.ACLK(clk), .ARESETn(rst));

    localparam BOOT_START = 32'hFFFF_0000;
    localparam BOOT_SIZE  = 1024; // words

    always_comb begin
        instr_data  = '0;
        instr_valid = '0;
        if (instr_addr >= BOOT_START &&
            instr_addr < BOOT_START + BOOT_SIZE*4) begin
            instr_data  = instr_data_boot;
            instr_valid = instr_valid_boot;
        end else begin
            instr_data  = instr_data_sdram;
            instr_valid = instr_valid_sdram;
        end
    end

    cpu #(.PC_START(BOOT_START)) cpu_inst(
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
        .instr_valid(instr_valid),
        .instr_addr(instr_addr),
        .instr_ready(instr_ready),
        .flush_instr(flush_instr)
    );

    logic [31:0] mosi_shift;
    logic sclk_d;

    always_ff @(posedge clk) begin
        sclk_d <= sclk;
        if (!cs_n && (sclk_d && !sclk)) begin
            mosi_shift <= {mosi_shift[30:0], mosi};
        end
    end

    cpu_axi_master_bridge cpu_axi_bridge(
        .clk(clk),
        .rst(rst),
        .data_addr(mmio_addr),
        .data_wdata(mmio_wdata),
        .data_we(mmio_we),
        .data_re(mmio_re),
        .data_type(mmio_type),
        .data_rdata(mmio_rdata),
        .data_done(mmio_done),
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

    logic [31:0] boot_addr;
    assign boot_addr = instr_addr - BOOT_START;

    CPU_instruction_memory instr_mem_inst(
        .address(boot_addr),
        .instruction(instr_data_boot)
    );

    assign instr_valid_boot = 1'b1;

    data_interconnect data_interconnect_inst(
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_we(data_we),
        .data_re(data_re),
        .data_type(data_type),
        .data_rdata(data_rdata),
        .data_done(data_done),
        .mmio_data_addr(mmio_addr),
        .mmio_data_wdata(mmio_wdata),
        .mmio_data_we(mmio_we),
        .mmio_data_re(mmio_re),
        .mmio_data_type(mmio_type),
        .mmio_data_rdata(mmio_rdata),
        .mmio_data_done(mmio_done),
        .sdram_data_addr(sdram_addr),
        .sdram_data_wdata(sdram_wdata),
        .sdram_data_we(sdram_we),
        .sdram_data_re(sdram_re),
        .sdram_data_type(sdram_type),
        .sdram_data_rdata(sdram_rdata),
        .sdram_data_done(sdram_done)
    );

    SDRAM_ARBITER sdram_arbiter_inst(
        .clk(clk),
        .rst(rst),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_len(mem_len),
        .mem_rdata(mem_rdata),
        .mem_valid(mem_valid),
        .data_rdata(sdram_rdata),
        .data_addr(sdram_addr),
        .data_wdata(sdram_wdata),
        .data_we(sdram_we),
        .data_re(sdram_re),
        .data_type(sdram_type),
        .data_done(sdram_done),
        .instr_data(instr_data_sdram),
        .instr_valid(instr_valid_sdram),
        .instr_addr(instr_addr),
        .instr_ready(instr_ready)
    );

    SDRAM_BRIDGE sdram_bridge_inst(
        .*
    );

    fake_sdram fake_sdram_inst(
        .I_sdrc_clk(I_sdrc_clk),
        .I_sdrc_rst_n(I_sdrc_rst_n),
        .I_sdrc_cmd_en(I_sdrc_cmd_en),
        .I_sdrc_cmd(I_sdrc_cmd),
        .I_sdrc_addr(I_sdrc_addr),
        .I_sdrc_data(I_sdrc_data),
        .O_sdrc_data(O_sdrc_data),
        .O_sdrc_init_done(O_sdrc_init_done),
        .O_sdrc_cmd_ack(O_sdrc_cmd_ack)
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
        .spi(spi),
        .gpio(gpio)
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

    gpio_peripheral gpio_peripheral_inst(
        .clk(clk),
        .rst(rst),
        .gpio_pins(gpio_pins),
        .axi(gpio)
    );

endmodule