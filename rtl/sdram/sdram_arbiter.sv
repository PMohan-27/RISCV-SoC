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
        end else begin
            if(data_we || data_re) begin
                mem_addr <= data_addr;
                mem_wdata <= data_wdata;
                mem_we <= data_we;
                mem_re <= data_re;
                mem_len <= 8'd0; // 0 maps to 1

                data_done <= mem_valid;
                data_rdata <= mem_rdata;

                instr_data <= instr_data;
                instr_valid <= instr_valid; 
            end else if(instr_ready) begin
                mem_addr <= instr_addr;
                mem_wdata <= '0;
                mem_we <= '0;
                mem_re <= 1'b1;
                mem_len <= '0; 

                instr_valid <= mem_valid;
                instr_data <= mem_rdata;

                data_done <= data_done;
                data_rdata <= data_rdata;
            end else begin
                mem_addr <= '0;
                mem_wdata <= '0;
                mem_we <= '0;
                mem_re <= '0;
                mem_len <= '0;

                instr_data <= '0;
                instr_valid <= '0;

                data_done <= '0;
                data_rdata <= '0;
            end
        end
    end

endmodule