module SDRAM_ARBITER(
    input logic clk, rst,

    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic mem_we,
    output logic mem_re,
    output logic [7:0] mem_len,

    input logic [31:0] mem_rdata,
    input logic mem_valid,
    input logic mem_final_beat,

    output logic [31:0] data_rdata,
    input logic [31:0] data_addr,
    input logic [31:0] data_wdata,
    input logic data_we,
    input logic data_re,
    input logic [2:0] data_type,
    output logic data_done,

    output logic [31:0] instr_data,
    output logic instr_valid, instr_last_beat,
    input logic [31:0] instr_addr,
    input logic instr_ready
);

    localparam SDRAM_TEXT_END = 32'h0010_0000;

    logic busy;
    logic owner;

    always_ff @(posedge clk) begin
        if (!rst) begin
            busy <= 1'b0;
            owner <= 1'b0;
        end else begin
            if (!busy) begin
                if (instr_ready && instr_addr < SDRAM_TEXT_END) begin
                    busy <= 1'b1;
                    owner <= 1'b1;
                end else if (data_we || data_re) begin
                    busy <= 1'b1;
                    owner <= 1'b0;
                end
            end else begin
                if (mem_valid && mem_final_beat) begin
                    busy <= 1'b0;
                end
            end
        end
    end

    always_comb begin
        mem_addr = '0;
        mem_wdata = '0;
        mem_we = 1'b0;
        mem_re = 1'b0;
        mem_len = '0;

        instr_data = '0;
        instr_valid = 1'b0;
        instr_last_beat = '0;

        data_rdata = '0;
        data_done = 1'b0;

        if (busy && owner) begin
            mem_addr = instr_addr;
            mem_re = 1'b1;
            mem_len = 8'd7;

            instr_data = mem_rdata;
            instr_valid = mem_valid;
            instr_last_beat = mem_final_beat;
        end else if (busy && !owner) begin
            mem_addr = data_addr;
            mem_wdata = data_wdata;
            mem_we = data_we;
            mem_re = data_re;
            mem_len = 8'd0;

            data_rdata = mem_rdata;
            data_done = mem_valid;
        end
    end

endmodule