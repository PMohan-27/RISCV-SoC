module data_interconnect(
    input logic [31:0] data_addr,
    input logic [31:0] data_wdata,
    input logic data_we,
    input logic data_re,
    input logic [2:0]  data_type,
    output logic [31:0] data_rdata,
    output logic data_done,

    output logic [31:0] mmio_data_addr,
    output logic [31:0] mmio_data_wdata,
    output logic mmio_data_we,
    output logic mmio_data_re,
    output logic [2:0] mmio_data_type,
    input logic [31:0] mmio_data_rdata,
    input logic mmio_data_done,

    output logic [31:0] sdram_data_addr,
    output logic [31:0] sdram_data_wdata,
    output logic sdram_data_we,
    output logic sdram_data_re,
    output logic [2:0] sdram_data_type,
    input logic [31:0] sdram_data_rdata,
    input logic sdram_data_done
    
); 
    localparam SDRAM_BASE = '0;
    localparam SDRAM_END = 32'h7FFF_FFFF;
    localparam MMMIO_BASE = 32'h8000_0000;
    localparam MMIO_END= 32'h8FFF_FFFF;
    /* verilator lint_off UNSIGNED */
    logic sdram_sel, mmio_sel;
    assign sdram_sel = (data_addr >= SDRAM_BASE) && (data_addr <= SDRAM_END);
    assign mmio_sel  = (data_addr >= MMMIO_BASE) && (data_addr <= MMIO_END);
    /* verilator lint_on UNSIGNED */
    always_comb begin

        mmio_data_addr = 32'd0;
        mmio_data_wdata = 32'd0;
        mmio_data_we = 1'b0;
        mmio_data_re = 1'b0;
        mmio_data_type = 3'd0;

        sdram_data_addr = 32'd0;
        sdram_data_wdata = 32'd0;
        sdram_data_we = 1'b0;
        sdram_data_re = 1'b0;
        sdram_data_type = 3'd0;

        data_rdata = 32'd0;
        data_done = 1'b0;

        if (sdram_sel) begin
            sdram_data_addr = data_addr;
            sdram_data_wdata = data_wdata;
            sdram_data_we = data_we;
            sdram_data_re = data_re;
            sdram_data_type = data_type;

            data_rdata = sdram_data_rdata;
            data_done = sdram_data_done;
        end
        else if (mmio_sel) begin
            mmio_data_addr = data_addr;
            mmio_data_wdata = data_wdata;
            mmio_data_we = data_we;
            mmio_data_re = data_re;
            mmio_data_type = data_type;

            data_rdata = mmio_data_rdata;
            data_done = mmio_data_done;
        end
        else begin
            data_rdata = '0;
            data_done  = 1'b1;
        end
    end
endmodule