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
    typedef enum logic [1:0] {IDLE, DATA, INSTRUCTION, DONE} transfer_state;
    transfer_state state;
    logic last_state;
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

            last_state <= 1'b0;

            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if(last_state) begin
                        if(data_we || data_re) state <= DATA;
                        else if(instr_ready && instr_addr < SDRAM_TEXT_END) state <= INSTRUCTION;
                    end else begin
                        if(instr_ready && instr_addr < SDRAM_TEXT_END) state <= INSTRUCTION;
                        else if(data_we ||data_re) state <= DATA;
                    end
                end
                DATA: begin
                    mem_addr <= data_addr;
                    mem_wdata <= data_wdata;
                    mem_we <= data_we;
                    mem_re <= data_re;
                    mem_len <= 8'd0; // 0 maps to 1 byte
                    last_state <= 1'b0;
                    if(mem_valid) begin
                        state <= DONE;
                        data_done <= 1'b1;
                        data_rdata <= mem_rdata;
                    end
                end
                INSTRUCTION: begin
                    mem_addr <= instr_addr;
                    mem_wdata <= '0;
                    mem_we <= '0;
                    mem_re <= 1'b1;
                    mem_len <= '0; 
                    last_state <= 1'b1;

                    if(mem_valid) begin
                        state <= DONE;                    
                        instr_data <= mem_rdata;
                        instr_valid <= 1'b1; 
                    end
                end
                DONE: begin
                    mem_addr <= '0;
                    mem_wdata <= '0;
                    mem_we <= '0;
                    mem_re <= '0;
                    mem_len <= '0;
                    data_done <= '0;
                    data_rdata <= '0;
                    instr_data <= '0;
                    instr_valid <= '0; 
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule