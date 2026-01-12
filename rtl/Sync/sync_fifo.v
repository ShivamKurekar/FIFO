// Synchronous FIFO

module sync_fifo #(parameter DATA_WIDTH = 64)(
    
    input i_rstn,

    // wr clk domain
    input i_wr_clk,
    input i_wr_en,
    input [DATA_WIDTH-1: 0] i_wr_data,

    output o_full,

    // rd clk domain
    // input i_rd_clk,
    input i_rd_en,

    output [DATA_WIDTH-1: 0] o_rd_data,
    output o_empty
);

    localparam DEPTH = 512;
    reg [63:0] mem [0: (DEPTH-1)]
    reg [$clog2(DEPTH)-1 :0] wr_ptr, nxt_wr_ptr;
    reg [$clog2(DEPTH)-1 :0] rd_ptr, nxt_rd_ptr;

    always @(posedge i_wr_clk or negedge i_rstn) begin
        if(!i_rstn) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            o_rd_data <= 0;
        end
        else begin
            //for wr
            if (i_wr_en && !o_full)begin
                mem[wr_ptr] <= i_wr_data;
                wr_ptr <= nxt_wr_ptr;
            end
            // else begin
            //     mem[wr_ptr] <= 0;
            // end

            //for rd
            if (i_rd_en && !o_empty)begin
                o_rd_data <= mem[rd_ptr];
                rd_ptr <= nxt_rd_ptr;
            end
            // else begin
            //     o_rd_data <= 0;
            // end

        end
    end

    assign o_full = (nxt_wr_ptr == rd_ptr)? 1: 0;
    assign o_empty = (wr_ptr == rd_ptr)? 1: 0;


    always @(*) begin
        nxt_wr_ptr = (wr_ptr == DEPTH - 1)? 0: wr_ptr + 1; 
        nxt_rd_ptr = (rd_ptr == DEPTH - 1)? 0: rd_ptr + 1;
    end

endmodule //sync_fifo