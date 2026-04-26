module fake_sdram(
    input logic I_sdrc_rst_n,
    input logic I_sdrc_clk,
    input logic I_sdram_clk,
    input logic I_sdrc_cmd_en,
    input logic [2:0] I_sdrc_cmd,
    input logic I_sdrc_precharge_ctrl,
    input logic I_sdram_power_down,
    input logic I_sdram_selfrefresh,
    input logic [20:0] I_sdrc_addr,
    input logic [3:0] I_sdrc_dqm,
    input logic [31:0] I_sdrc_data,
    input logic [7:0] I_sdrc_data_len,

    output logic [31:0] O_sdrc_data,
    output logic O_sdrc_init_done,
    output logic O_sdrc_cmd_ack
);

    localparam CMD_READ  = 3'b101;
    localparam CMD_WRITE = 3'b100;
    localparam tCL = 1;
/* verilator lint_off WIDTHTRUNC */
    logic [31:0] mem [0:2097151]; // 8M

    logic [1:0] tcl_counter;
    logic [7:0] burst_counter;
    logic [20:0] addr_r;
    logic read_active, write_active;

    assign O_sdrc_init_done = 1'b1; 
    
    always_ff @(posedge I_sdrc_clk) begin
        if (!I_sdrc_rst_n) begin
            O_sdrc_cmd_ack <= 0;
            O_sdrc_data <= 0;

            tcl_counter <= 0;
            burst_counter <= 0;
            addr_r <= 0;
            read_active <= 0;
            write_active <= 0;

        end else begin
            O_sdrc_cmd_ack <= I_sdrc_cmd_en;

            if (I_sdrc_cmd_en) begin
                addr_r <= I_sdrc_addr;
                burst_counter <= I_sdrc_data_len + 1;

                case (I_sdrc_cmd)
                    CMD_READ: begin
                        tcl_counter <= tCL - 1;
                        read_active <= 1;
                        write_active <= 0;
                    end

                    CMD_WRITE: begin
                        write_active <= 1;
                        read_active  <= 0;
                    end
                    default: ;
                endcase
            end

            if (read_active) begin
                if (tcl_counter > 0) begin
                    tcl_counter <= tcl_counter - 1;
                end else if (burst_counter > 0) begin
                    O_sdrc_data <= mem[addr_r];
                    addr_r <= addr_r + 1;
                    burst_counter <= burst_counter - 1;
                end else begin
                    read_active <= 0;
                end
            end

            if (write_active) begin
                if (burst_counter > 0) begin
                    mem[addr_r] <= I_sdrc_data;
                    addr_r <= addr_r + 1;
                    burst_counter <= burst_counter - 1;
                end else begin
                    write_active <= 0;
                end
            end
        end
    end

endmodule