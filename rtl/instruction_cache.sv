module instruction_cache(
    input logic clk, rst,
    // cpu
    input logic [31:0] cpu_addr, //PC
    input logic cpu_ready,
    output logic [31:0] cpu_data, 
    output logic cpu_valid,

    // sdram
    input logic [31:0] instr_data, 
    input logic instr_valid,
    input logic instr_last_beat,
    output logic [31:0] instr_addr,
    output logic instr_ready

);
    localparam SDRAM_TEXT_END = 32'h0010_0000;

    // 4KB 4 way 32B lines
    logic [21:0] tag;
    logic [4:0] byte_offset;
    logic [4:0] set;

    typedef struct packed {
        logic valid;
        logic [21:0] tag;
        logic [7:0][31:0] data; 
    } cache_line_t; 
    // plru[0] -> way 0 or 1 
    // plru[1] -> way 2 or 3
    // plru[2] -> plru[0] or plru[1] 
    logic [2:0] plru [0:31];
    cache_line_t cache [0:31][0:3];


    assign tag = cpu_addr[31:10];
    assign set = cpu_addr[9:5];
    assign byte_offset = cpu_addr[4:0];

    logic cache_hit;
    logic [1:0] hit_way;
    logic [1:0] fill_way;

    typedef enum logic [1:0] {IDLE, MISS} cache_state;
    cache_state state;

    always_comb begin
        cache_hit = 1'b0;
        hit_way = '0;
        for (int way = 0; way < 4; way = way + 1)  begin 
            if(cache[set][way].tag == tag && cache[set][way].valid) begin
                cache_hit = 1'b1;
                hit_way = way[1:0];
                break;
            end
        end

        fill_way = (plru[set][2]) ? 
                    (plru[set][1] ? 'd2 : 'd3) 
                    : (plru[set][0] ? 'd0 : 'd1);

        for (int way = 0; way < 4; way = way + 1)  begin 
            if(!cache[set][way].valid) begin
                fill_way = way[1:0];
                break;
            end
        end
    end

    logic [2:0] beat_count;
    
    always_ff @(posedge clk) begin
        if(!rst) begin
            state <= IDLE;
            for (int i = 0; i < 32; i=i+1) begin
                for (int j = 0; j < 4; j=j+1) begin
                    cache[i][j] <= '0;
                end
            end
            for (int i = 0; i < 32; i++) begin
                plru[i] <= 3'b000;
            end
            beat_count <= '0;
            
            instr_ready <= 1'b0;
            instr_addr <= '0;


        end else begin
            
            case(state) 
                IDLE: begin
                    instr_ready <= 1'b0;
                    
                    if(cache_hit && cpu_ready) begin
                        case(hit_way) 
                            'd0: begin
                                plru[set][0] <= '1;
                                plru[set][2] <= '1;
                            end
                            'd1: begin
                                plru[set][0] <= '0;
                                plru[set][2] <= '1;
                            end
                            'd2: begin
                                plru[set][1] <= '1;
                                plru[set][2] <= '0;
                            end
                            'd3: begin
                                plru[set][1] <= '0;
                                plru[set][2] <= '0;
                            end
                        endcase
                    end else if(cpu_addr <= SDRAM_TEXT_END && cpu_ready)begin
                        beat_count <= '0;
                        state <= MISS;
                    end
                end
                MISS: begin
                     
                    
                    instr_ready <= 1'b1;
                    instr_addr <= {cpu_addr[31:5], 5'b0};
                    cache[set][fill_way].valid <= 1'b0;
                    if(instr_valid) begin
                        instr_ready <= 1'b0;
                        cache[set][fill_way].data[beat_count] <= instr_data;
                        if(instr_last_beat) begin
                            state <= IDLE;
                            cache[set][fill_way].tag <= tag;
                            cache[set][fill_way].valid <= 1'b1;
                            case(hit_way) 
                                'd0: begin
                                    plru[set][0] <= '1;
                                    plru[set][2] <= '1;
                                end
                                'd1: begin
                                    plru[set][0] <= '0;
                                    plru[set][2] <= '1;
                                end
                                'd2: begin
                                    plru[set][1] <= '1;
                                    plru[set][2] <= '0;
                                end
                                'd3: begin
                                    plru[set][1] <= '0;
                                    plru[set][2] <= '0;
                                end
                            endcase
                        end
                        beat_count++;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    assign cpu_valid = cache_hit && cpu_ready;
    assign cpu_data = cache_hit ? cache[set][hit_way].data[byte_offset[4:2]] : '0;
    

endmodule