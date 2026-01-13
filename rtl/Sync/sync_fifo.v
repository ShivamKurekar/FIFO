// Synchronous FIFO

module sync_fifo #(parameter DATA_WIDTH = 64,
                   parameter DEPTH = 512)(
    
    input i_rstn,

    /* wr clk domain */
    input i_wr_clk,
    input i_wr_en,
    input [DATA_WIDTH-1: 0] i_wr_data,

    output o_full,
    output [$clog2(DEPTH): 0] wr_data_count,
    
    /* rd clk domain */
    // input i_rd_clk,
    input i_rd_en,
    
    output [DATA_WIDTH-1: 0] o_rd_data,
    output o_empty,
    output [$clog2(DEPTH): 0] rd_data_count
);

    reg [DATA_WIDTH - 1 :0] mem [0: (DEPTH-1)];
    reg [$clog2(DEPTH)-1 :0] wr_ptr, nxt_wr_ptr;
    reg [$clog2(DEPTH)-1 :0] rd_ptr, nxt_rd_ptr;
    reg [$clog2(DEPTH) :0] count;

    always @(posedge i_wr_clk or negedge i_rstn) begin
        if(!i_rstn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            o_rd_data <= 0;
            count <= 0;
        end

        else begin
    
            case ({(i_wr_en && !o_full), (i_rd_en && !o_empty)})
                //for wr
                10: begin
                    mem[wr_ptr] <= i_wr_data;
                    wr_ptr <= nxt_wr_ptr;
                    count <= count + 1;
                end
                //for rd
                01: begin
                    o_rd_data <= mem[rd_ptr];
                    rd_ptr <= nxt_rd_ptr;
                    count <= count - 1;
                    
                end

                11: begin
                    mem[wr_ptr] <= i_wr_data;
                    o_rd_data <= mem[rd_ptr];
                    wr_ptr <= nxt_wr_ptr;
                    rd_ptr <= nxt_rd_ptr;
                end
        
            endcase
        end
    end

    assign o_full = (count == DEPTH)? 1: 0;
    assign o_empty = (count == 0)? 1: 0;
    assign wr_data_count = count; /* how many valid data are stored after wr operation */
    assign rd_data_count = count; /* how many valid data are stored for rd operation */

    always @(*) begin
        nxt_wr_ptr = (wr_ptr == DEPTH - 1)? 0: wr_ptr + 1; 
        nxt_rd_ptr = (rd_ptr == DEPTH - 1)? 0: rd_ptr + 1;
    end

endmodule //sync_fifo