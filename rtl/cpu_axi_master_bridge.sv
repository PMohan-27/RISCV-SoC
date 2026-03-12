module cpu_axi_master_bridge(
    input clk, rst,
    // cpu signals
    input logic [31:0] data_addr,
    input logic [31:0] data_wdata,
    input logic data_we,
    input logic data_re,
    input logic [2:0]  data_type,
    output  logic [31:0] data_rdata,
    output logic data_stall,

    // axi lite master
    input logic [31:0] ctrl_rdata,
    input logic ctrl_write_done,
    input logic ctrl_read_done,
    input logic [1:0] ctrl_bresp,
    input logic [1:0] ctrl_rresp,
    output logic [31:0] ctrl_waddr,
    output logic [31:0] ctrl_raddr,
    output logic [31:0] ctrl_wdata,
    output logic [3:0] ctrl_wstrb,
    output logic ctrl_write_req,
    output logic ctrl_read_req
);
    logic writing, reading;

    always_ff @(posedge clk) begin
        if(!rst) begin
            writing <= 1'b0;
            reading <= 1'b0;
        end
        else begin
            if(data_we && !writing)  writing <= 1'b1;
            if(ctrl_write_done)      writing <= 1'b0;

            if(data_re && !reading)  reading <= 1'b1;
            if(ctrl_read_done)       reading <= 1'b0;
        end
    end

    always_comb begin
        data_stall = (writing || reading);

        ctrl_waddr = data_addr;
        ctrl_raddr = data_addr;

        ctrl_wdata = data_wdata;
        case(data_type)
            WORD:       ctrl_wstrb = 4'b1111;
            HALFWORD,
            U_HALFWORD: 
                case(data_addr[1])
                    1'b0: ctrl_wstrb = 4'b0011;
                    1'b1: ctrl_wstrb = 4'b1100;
                endcase
            BYTE,
            U_BYTE:
                case(data_addr[1:0])
                    2'b00: ctrl_wstrb = 4'b0001;
                    2'b01: ctrl_wstrb = 4'b0010;
                    2'b10: ctrl_wstrb = 4'b0100;
                    2'b11: ctrl_wstrb = 4'b1000;
                endcase
            default: ctrl_wstrb = 4'b1111;
        endcase
        data_rdata = ctrl_rdata;
        
        ctrl_write_req = data_we && !writing;
        ctrl_read_req  = data_re && !reading;
    end
endmodule