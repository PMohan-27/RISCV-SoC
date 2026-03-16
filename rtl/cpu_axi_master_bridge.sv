module cpu_axi_master_bridge(
    input clk, rst,
    input logic [31:0] data_addr,
    input logic [31:0] data_wdata,
    input logic data_we,
    input logic data_re,
    input logic [2:0]  data_type,
    output logic [31:0] data_rdata,
    output logic data_done,

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
    logic ready_write;
    always_ff @(posedge clk) begin
        if (!rst)                 ready_write <= 1'b1;
        else if (ctrl_write_req)  ready_write <= 1'b0;
        else if (ctrl_write_done) ready_write <= 1'b1;
    end

    assign ctrl_write_req = (data_we & ready_write);

    assign ctrl_waddr = data_addr;
    assign ctrl_wdata = data_wdata;
    always_comb begin
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
    end
    
    logic ready_read;
    always_ff @(posedge clk) begin
        if (!rst)                ready_read <= 1'b1;
        else if (ctrl_read_req)  ready_read <= 1'b0;
        else if (ctrl_read_done) ready_read <= 1'b1;
    end
    assign ctrl_read_req = data_re & ready_read;
    assign data_rdata = ctrl_rdata;
    assign ctrl_raddr = data_addr;

    assign data_done = (data_we && ctrl_write_done) || (data_re && ctrl_read_done);

endmodule