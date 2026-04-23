module SDRAM_BRIDGE(
    input logic clk, rst,

    input logic [31:0] mem_addr,
    input logic [31:0] mem_wdata,
    input logic mem_we,
    input logic mem_re,
    input logic [7:0] mem_len, 
    output logic [31:0] mem_rdata,
    output logic mem_valid,
    output logic mem_final_beat,
    
    // SDRAM signals 
    output  logic I_sdrc_rst_n,
    output  logic I_sdrc_clk,
    output  logic I_sdram_clk,
    output  logic I_sdrc_cmd_en,
    output  logic [2:0] I_sdrc_cmd,
    output  logic I_sdrc_precharge_ctrl,
    output  logic I_sdram_power_down,
    output  logic I_sdram_selfrefresh,
    output  logic [20:0] I_sdrc_addr,
    output  logic [3:0] I_sdrc_dqm,
    output  logic [31:0] I_sdrc_data,
    output  logic [7:0] I_sdrc_data_len,

    input logic [31:0] O_sdrc_data,
    input logic O_sdrc_init_done,
    input logic O_sdrc_cmd_ack
);  
    localparam tCL = 'd2;

    localparam CMD_NOP = 3'b111;
    localparam CMD_ACTIVE = 3'b011;
    localparam CMD_READ = 3'b101;
    localparam CMD_WRITE = 3'b100;
    localparam CMD_PRECHARGE = 3'b010;
    localparam CMD_REFRESH = 3'b001;

    assign I_sdrc_rst_n = rst;
    assign I_sdrc_clk = clk;
    assign I_sdram_clk = clk;
    assign I_sdrc_precharge_ctrl = 1'b1;
    assign I_sdram_power_down = 1'b1;
    assign I_sdram_selfrefresh = 1'b0;
    assign I_sdrc_dqm = '0;

    typedef enum logic [3:0] {IDLE, ACTIVE, READ, READ_ACK, WRITE, WRITE_ACK, REFRESH, REFRESH_ACK, DONE} sdram_state;
    sdram_state state;
    logic [7:0] tCL_counter, burst_counter;
    always_ff @(posedge clk) begin
        if(!rst) begin
            state <= IDLE;

            I_sdrc_addr <= '0;
            I_sdrc_cmd <= CMD_NOP;
            I_sdrc_cmd_en <= '0;
            I_sdrc_data <= '0;
            I_sdrc_data_len <= '0;
            

            mem_rdata <= '0;
            mem_valid <= '0;    
            mem_final_beat <= '0;
        end else begin
            mem_valid <= 1'b0;
            mem_final_beat <= 1'b0;
            I_sdrc_cmd_en <= '0;

            case(state) 
            IDLE: begin
                if(O_sdrc_init_done && (mem_we || mem_re)) begin
                    state <= ACTIVE;
                end
            end
            ACTIVE: begin
                I_sdrc_cmd_en <= 1'b1;
                I_sdrc_cmd <= CMD_ACTIVE;
                I_sdrc_addr <= mem_addr[22:2];
                if(O_sdrc_cmd_ack) begin
                    if(mem_we) state <= WRITE;
                    else if (mem_re) state <= READ;
                end
            end
            READ: begin
                I_sdrc_cmd <= CMD_READ;
                I_sdrc_cmd_en <= 1'b1;
                if(O_sdrc_cmd_ack) begin
                    tCL_counter <= tCL;
                    burst_counter <= mem_len + 1;
                    I_sdrc_data_len <= mem_len;
                    state <= READ_ACK;
                end
            end
            READ_ACK: begin
                if(tCL_counter != 0) begin
                    tCL_counter--;
                end else begin
                    if(burst_counter != 0) begin 
                        burst_counter--;
                        mem_valid <= 1'b1;
                        mem_rdata <= O_sdrc_data;
                        if(burst_counter == 0) mem_final_beat <= 1'b1;
                    end else begin
                        state <= DONE;
                    end
                end
            end
            WRITE: begin
                I_sdrc_cmd <= CMD_WRITE;
                I_sdrc_cmd_en <= 1'b1;
                I_sdrc_data <= mem_wdata;
                I_sdrc_addr <= mem_addr[22:2];
                if(O_sdrc_cmd_ack) begin
                    I_sdrc_data_len <= '0;
                    state <= WRITE_ACK;
                end
            end
            WRITE_ACK: begin
                mem_final_beat <= 1'b1;
                mem_valid <= 1'b1;
                state <= DONE;
            end
            DONE: begin
                I_sdrc_data <= '0;
                I_sdrc_addr <= '0;
                I_sdrc_cmd <= CMD_NOP;
                state <= IDLE;
            end
            default: state <= IDLE;
            endcase
        end
    end

endmodule