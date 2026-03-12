`define AXI_LITE_CONNECT(m, s)          \
    assign s.AWADDR  = m.AWADDR;        \
    assign s.AWPROT  = m.AWPROT;        \
    assign s.AWVALID = m.AWVALID;       \
    assign m.AWREADY = s.AWREADY;       \
    assign s.WDATA   = m.WDATA;         \
    assign s.WSTRB   = m.WSTRB;         \
    assign s.WVALID  = m.WVALID;        \
    assign m.WREADY  = s.WREADY;        \
    assign m.BRESP   = s.BRESP;         \
    assign m.BVALID  = s.BVALID;        \
    assign s.BREADY  = m.BREADY;        \
    assign s.ARADDR  = m.ARADDR;        \
    assign s.ARPROT  = m.ARPROT;        \
    assign s.ARVALID = m.ARVALID;       \
    assign m.ARREADY = s.ARREADY;       \
    assign m.RDATA   = s.RDATA;         \
    assign m.RRESP   = s.RRESP;         \
    assign m.RVALID  = s.RVALID;        \
    assign s.RREADY  = m.RREADY;

module axi4_lite_interconnect(
    axi_lite_if cpu, //input from cpu
    axi_lite_if spi //output to spi periph
);
    `AXI_LITE_CONNECT(cpu,spi);

endmodule