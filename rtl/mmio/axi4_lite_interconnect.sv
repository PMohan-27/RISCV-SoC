`define AXI_LITE_CONNECT(m, s)          \
     s.AWADDR  = m.AWADDR;        \
     s.AWPROT  = m.AWPROT;        \
     s.AWVALID = m.AWVALID;       \
     m.AWREADY = s.AWREADY;       \
     s.WDATA   = m.WDATA;         \
     s.WSTRB   = m.WSTRB;         \
     s.WVALID  = m.WVALID;        \
     m.WREADY  = s.WREADY;        \
     m.BRESP   = s.BRESP;         \
     m.BVALID  = s.BVALID;        \
     s.BREADY  = m.BREADY;        \
     s.ARADDR  = m.ARADDR;        \
     s.ARPROT  = m.ARPROT;        \
     s.ARVALID = m.ARVALID;       \
     m.ARREADY = s.ARREADY;       \
     m.RDATA   = s.RDATA;         \
     m.RRESP   = s.RRESP;         \
     m.RVALID  = s.RVALID;        \
     s.RREADY  = m.RREADY;

module axi4_lite_interconnect(
    axi_lite_if cpu, //input from cpu
    axi_lite_if spi, //output to spi periph
    axi_lite_if gpio
);  
    localparam SPI_BASE  = 32'h8000_0000;
    localparam SPI_END   = 32'h8000_0007; 
    localparam GPIO_BASE = 32'h8000_0008;
    localparam GPIO_END  = 32'h8000_000B;  

    logic sel_spi, sel_gpio;
    logic busy;
     always_ff @(posedge cpu.ACLK or negedge cpu.ARESETn) begin
        if (!cpu.ARESETn) begin
            sel_spi  <= 1'b0;
            sel_gpio <= 1'b0;
            busy <= 1'b0;
        end else begin
            if (!busy) begin
                if (cpu.AWVALID || cpu.ARVALID) begin
                    sel_spi  <= (cpu.AWVALID && cpu.AWADDR >= SPI_BASE && cpu.AWADDR <= SPI_END) ||
                    (cpu.ARVALID && cpu.ARADDR >= SPI_BASE && cpu.ARADDR <= SPI_END);

                    sel_gpio <= (cpu.AWVALID && cpu.AWADDR >= GPIO_BASE && cpu.AWADDR <= GPIO_END) ||
                    (cpu.ARVALID && cpu.ARADDR >= GPIO_BASE && cpu.ARADDR <= GPIO_END);

                    busy <= 1'b1;
                end
            end else begin
                if ((cpu.BVALID && cpu.BREADY) || (cpu.RVALID && cpu.RREADY)) begin
                    busy <= 1'b0;
                    sel_gpio <= 1'b0;
                    sel_spi <= 1'b0;
                end
            end
        end
    end
    always_comb begin
        cpu.AWREADY = 1'b0;
        cpu.WREADY  = 1'b0;
        cpu.BRESP   = 2'b00;
        cpu.BVALID  = 1'b0;
        cpu.ARREADY = 1'b0;
        cpu.RDATA   = '0;
        cpu.RRESP   = 2'b00;
        cpu.RVALID  = 1'b0;
        
        spi.AWADDR  = '0;
        spi.AWPROT  = '0;
        spi.AWVALID = 1'b0;
        spi.WDATA   = '0;
        spi.WSTRB   = '0;
        spi.WVALID  = 1'b0;
        spi.BREADY  = 1'b0;
        spi.ARADDR  = '0;
        spi.ARPROT  = '0;
        spi.ARVALID = 1'b0;
        spi.RREADY  = 1'b0;
        
        gpio.AWADDR  = '0;
        gpio.AWPROT  = '0;
        gpio.AWVALID = 1'b0;
        gpio.WDATA   = '0;
        gpio.WSTRB   = '0;
        gpio.WVALID  = 1'b0;
        gpio.BREADY  = 1'b0;
        gpio.ARADDR  = '0;
        gpio.ARPROT  = '0;
        gpio.ARVALID = 1'b0;
        gpio.RREADY  = 1'b0;
    
        if(sel_gpio) begin 
             `AXI_LITE_CONNECT(cpu, gpio)
        end else if (sel_spi) begin
             `AXI_LITE_CONNECT(cpu, spi);
        end
    end
endmodule