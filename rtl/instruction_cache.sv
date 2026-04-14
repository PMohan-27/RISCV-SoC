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
    // TODO: Add LRU and proper replacement
    logic [21:0] tag;
    logic [4:0] byte_offset;
    logic [4:0] set;

    typedef struct packed {
        logic valid;
        logic [21:0] tag;
        logic [7:0][31:0] data; 
        logic [1:0] lru;
    } cache_line_t;
    
    cache_line_t cache [0:31][0:3];


    assign tag = cpu_addr[31:10];
    assign set = cpu_addr[9:5];
    assign byte_offset = cpu_addr[4:0];

    logic cache_hit;
    logic [1:0] hit_way;

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
    end

    logic [1:0] fill_way;
    assign fill_way = 0;
    logic [2:0] beat_count;
    
    always_ff @(posedge clk) begin
        if(!rst) begin
            state <= IDLE;
            for (int i = 0; i < 32; i=i+1) begin
                for (int j = 0; j < 4; j=j+1) begin
                    cache[i][j] = '0;
                end
            end
            beat_count <= '0;
            
            instr_ready  <= 1'b0;
            instr_addr   <= '0;

            cpu_valid    <= 1'b0;

        end else begin
            
            case(state) 
                IDLE: begin
                    beat_count <= '0;
                    instr_ready <= 1'b0;
                    cpu_valid <= '0;
                    
                    if(cache_hit && cpu_ready) begin
                        cpu_valid <= 1'b1;
                    end else if(cpu_addr <= SDRAM_TEXT_END && cpu_ready)begin
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
                            cache[set][fill_way].lru <= '0;
                            cpu_valid <= 1'b1;
                        end
                        beat_count++;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    assign cpu_data = cache[set][hit_way].data[byte_offset[4:2]];
    

endmodule