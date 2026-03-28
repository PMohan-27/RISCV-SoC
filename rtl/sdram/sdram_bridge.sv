module SDRAM_BRIDGE(
    input logic clk, rst,

    input logic [31:0] mem_addr,
    input logic [31:0] mem_wdata,
    input logic mem_we,
    input logic mem_re,
    input logic [7:0] mem_len, 
    output logic [31:0] mem_rdata,
    output logic mem_valid,
    
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
    localparam CMD_NOP = 3'b111;
    localparam CMD_ACTIVE = 3'b011;
    localparam CMD_READ = 3'b101;
    localparam CMD_WRITE = 3'b100;
    localparam CMD_PRECHARGE = 3'b010;
    localparam CMD_REFRESH = 3'b001;

    assign I_sdrc_rst_n = rst;
    assign I_sdrc_clk = clk;
    assign I_sdram_clk = clk;
    
    typedef enum logic [3:0] {IDLE, ACTIVE, ACTIVE_ACK, READ_WRITE, RW_ACK, REFRESH, REFRESH_ACK, DONE} sdram_state;
    sdram_state state, next_state;

    localparam REFRESH_CYCLES = 16'd1000; 
    logic [15:0] refresh_cnt;
    logic refresh_req;
    logic refresh_pending;

    always_ff @(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
            refresh_cnt <= 0;
            refresh_req <= 0;
            refresh_pending <= 0;
        end else begin
            state <= next_state;
            if (refresh_cnt == REFRESH_CYCLES) begin
                refresh_cnt <= 0;
                refresh_req <= 1'b1;
            end else begin
                refresh_cnt <= refresh_cnt + 1;
                refresh_req <= 1'b0;
            end
            if (refresh_req)
                refresh_pending <= 1'b1;
            else if (state == IDLE && refresh_pending)
                refresh_pending <= 1'b0;
        end
    end
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (O_sdrc_init_done && (mem_re || mem_we)) begin
                    next_state = ACTIVE;
                end
            end
            ACTIVE: begin
                next_state = ACTIVE_ACK;
            end
            ACTIVE_ACK: begin
                if (O_sdrc_cmd_ack)
                    next_state = READ_WRITE;
            end
            READ_WRITE: begin
                next_state = RW_ACK;
            end
            RW_ACK: begin
                if (O_sdrc_cmd_ack)
                    next_state = DONE;
            end
            REFRESH:begin
                next_state = REFRESH_ACK;
            end
            REFRESH_ACK: begin
                if(O_sdrc_cmd_ack)
                    next_state = IDLE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
    logic [31:0] mem_addr_r;
    logic [31:0] mem_wdata_r;
    logic [7:0] mem_len_r;
    logic mem_we_r;
    logic mem_re_r;
    always_ff @(posedge clk) begin
        if(!rst) begin
            I_sdrc_cmd <= '1;
            I_sdrc_cmd_en <= '0;
            I_sdrc_precharge_ctrl <= '1;
            I_sdram_power_down <= '0;
            I_sdram_selfrefresh <= '0;
            I_sdrc_addr <= '0;
            I_sdrc_dqm <= '0;
            I_sdrc_data <= '0;
            I_sdrc_data_len <= '0;

            mem_rdata <= '0;
            mem_valid <= '0;
        end else begin
            I_sdrc_cmd <= CMD_NOP;
            I_sdrc_cmd_en <= '0;
            mem_valid <= '0;
            mem_rdata <= '0;    
            I_sdram_selfrefresh <= 1'b0;
            I_sdram_power_down  <= 1'b0;
            I_sdrc_precharge_ctrl <= 1'b1;

            case (state) 
                IDLE: begin
                    I_sdrc_cmd <= CMD_NOP;
                    if (O_sdrc_init_done && (mem_re || mem_we)) begin
                        mem_addr_r  <= mem_addr;
                        mem_wdata_r <= mem_wdata;
                        mem_len_r <= mem_len;
                        mem_we_r <= mem_we;
                        mem_re_r <= mem_re;
                    end
                end
                ACTIVE: begin
                    I_sdrc_cmd <= CMD_ACTIVE;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_addr <= mem_addr_r[22:2]; 
                    I_sdrc_data_len <= mem_len_r;
                end
                ACTIVE_ACK: begin
                    I_sdrc_cmd <= CMD_NOP;
                    I_sdrc_cmd_en <= 1'b0;
                end
                READ_WRITE:begin
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_addr <= mem_addr_r[22:2]; 
                    I_sdrc_data_len <= mem_len_r;
                    if(mem_we_r) begin
                        I_sdrc_cmd <= CMD_WRITE;
                        I_sdrc_data <= mem_wdata_r;
                    end
                    else if(mem_re_r) begin
                        I_sdrc_cmd <= CMD_READ;
                    end
                end
                RW_ACK: begin
                    I_sdrc_cmd_en <= 1'b0;
                    I_sdrc_cmd <= CMD_NOP;
                    if (O_sdrc_cmd_ack && mem_re_r) begin
                        mem_rdata <= O_sdrc_data;
                    end
                end
                REFRESH: begin
                    I_sdrc_cmd <= CMD_REFRESH;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_addr <= '0;
                end
                REFRESH_ACK: begin
                    I_sdrc_cmd <= CMD_NOP;
                    I_sdrc_cmd_en <= 1'b0;
                end
                DONE: begin
                    mem_valid <= 1'b1;
                end
                default: I_sdrc_cmd_en <= '0;
            endcase 
        end
    end
endmodule