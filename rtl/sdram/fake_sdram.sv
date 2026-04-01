// to simulate in place of gowin ip
module fake_sdram #(
    parameter DEPTH = 1024  
)(
    input logic I_sdrc_clk,
    input logic I_sdrc_rst_n,
    input logic I_sdrc_cmd_en,
    input logic [2:0] I_sdrc_cmd,
    input logic [20:0] I_sdrc_addr,
    input logic [31:0] I_sdrc_data,
    
    output logic [31:0] O_sdrc_data,
    output logic O_sdrc_init_done,
    output logic O_sdrc_cmd_ack
);
    localparam CMD_READ = 3'b101;
    localparam CMD_WRITE = 3'b100;
    logic [31:0] mem [0:DEPTH];
    /* verilator lint_off WIDTHTRUNC */

    assign O_sdrc_init_done = 1'b1; 
    
    always_ff @(posedge I_sdrc_clk or negedge I_sdrc_rst_n) begin
        if (!I_sdrc_rst_n) begin
            O_sdrc_cmd_ack <= 1'b0;
            O_sdrc_data <= 32'h0;
        end else begin
            O_sdrc_cmd_ack <= I_sdrc_cmd_en;
            
            if (I_sdrc_cmd_en) begin
                case (I_sdrc_cmd)
                    CMD_READ: O_sdrc_data <= mem[I_sdrc_addr];
                    CMD_WRITE: mem[I_sdrc_addr] <= I_sdrc_data; 
                    default: ;
                endcase
            end
        end
    end

endmodule