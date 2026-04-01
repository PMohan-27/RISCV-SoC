module SDRAM_ARBITER(
    input logic clk, rst,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic mem_we,
    output logic mem_re,
    output logic [7:0] mem_len, 
    input logic [31:0] mem_rdata,
    input logic mem_valid,

    output  logic [31:0] data_rdata,
    input logic [31:0] data_addr,
    input logic [31:0] data_wdata,
    input logic data_we,
    input logic data_re,
    input logic [2:0]  data_type,
    output logic data_done,

    output logic [31:0] instr_data, 
    output logic instr_valid,
    input logic [31:0] instr_addr, //PC
    input logic instr_ready
);
    localparam SDRAM_TEXT_BEGIN = '0;
    localparam SDRAM_TEXT_END = 32'h0010_0000;

    logic instr_pending, data_pending;
    always_ff @(posedge clk) begin
        if(!rst) begin
            mem_addr <= '0;
            mem_wdata <= '0;
            mem_we <= '0;
            mem_re <= '0;
            mem_len <= '0;

            instr_data <= '0;
            instr_valid <= '0;

            data_done <= '0;
            data_rdata <= '0;

            instr_pending <= 1'b0;
            data_pending <= 1'b0;
        end else begin
            data_done <= 1'b0;
            instr_valid <= 1'b0;
            if((data_we || data_re) && !data_pending && !instr_pending) begin
                mem_addr <= data_addr;
                mem_wdata <= data_wdata;
                mem_we <= data_we;
                mem_re <= data_re;
                mem_len <= 8'd0; // 0 maps to 1 byte

                data_pending <= 1'b1;
            end else if(instr_ready && !data_pending && !instr_pending && instr_addr < SDRAM_TEXT_END) begin
                mem_addr <= instr_addr;
                mem_wdata <= '0;
                mem_we <= '0;
                mem_re <= 1'b1;
                mem_len <= '0; 

                instr_pending <= 1'b1;
            end
            if(mem_valid) begin
                mem_addr <= '0;
                mem_wdata <= '0;
                mem_we <= '0;
                mem_re <= '0;
                mem_len <= '0;

                if(data_pending) begin
                    data_done <= 1'b1;
                    data_rdata <= mem_rdata;
                end else if(instr_pending) begin
                    instr_data <= mem_rdata;
                    instr_valid <= 1'b1; 
                end else begin 
                    data_done <= '0;
                    data_rdata <= '0;
                    instr_data <= '0;
                    instr_valid <= '0; 
                end
                instr_pending <= 1'b0;
                data_pending <= 1'b0;
            end
        end
    end

endmodule