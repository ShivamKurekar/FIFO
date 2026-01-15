module async_fifo #(parameter DEPTH = 8,
                    parameter DATA_WIDTH = 4)(

    /* wr clk domain */
    input i_wr_clk,
    input i_wr_rstn,
    input i_wr_en,
    input [DATA_WIDTH-1: 0] i_wr_data,

    output o_full,
    
    /* rd clk domain */
    input i_rd_clk,
    input i_rd_rstn,
    input i_rd_en,
    
    output [DATA_WIDTH-1: 0] o_rd_data,
    output o_empty
);

    localparam PTR_WIDTH = $clog2(DEPTH);

    wire [PTR_WIDTH: 0] g_wr_ptr, g_rd_ptr, rd_ptr, wr_ptr;
    wire [PTR_WIDTH: 0] sync_g_wr_ptr, sync_g_rd_ptr;

    wr_ptr_handler #(.PTR_WIDTH(PTR_WIDTH)) wr_hand (
        .i_clk(i_wr_clk),
        .i_rstn(i_wr_rstn),
        .i_en(i_wr_en),
        .i_g_rd_ptr(sync_g_rd_ptr), // o/p of 2ff sync of rd pointer handler
        .o_b_wr_ptr(wr_ptr),
        .o_g_wr_ptr(g_wr_ptr),
        .o_full(o_full)
    );

    ff_sync #(.DATA_WIDTH(PTR_WIDTH)) wr_ff (
        .clk(i_wr_clk),
        .rstn(i_wr_rstn),
        .i_data(g_rd_ptr),
        .o_data(sync_g_rd_ptr)
    );
    
    ff_sync #(.DATA_WIDTH(PTR_WIDTH)) rd_ff (
        .clk(i_rd_clk),
        .rstn(i_rd_rstn),
        .i_data(g_wr_ptr),
        .o_data(sync_g_wr_ptr)
    );

    rd_ptr_handler #(.PTR_WIDTH(PTR_WIDTH)) rd_hand (
        .i_clk(i_rd_clk),
        .i_rstn(i_rd_rstn),
        .i_en(i_rd_en),
        .i_g_wr_ptr(sync_g_wr_ptr),
        .o_b_rd_ptr(rd_ptr), // read pointer to fifo_memory
        .o_g_rd_ptr(g_rd_ptr), // gray gray rd ptr to ff_sync
        .o_empty(o_empty)
    );

    fifo_mem #(.DEPTH(DEPTH),
                .DATA_WIDTH(DATA_WIDTH)) memory (
        .i_wr_clk(i_wr_clk),
        .i_wr_en(i_wr_en),
        .i_full(o_full),
        .i_wr_data(i_wr_data),
        .i_b_wr_ptr(wr_ptr),

        .i_rd_clk(i_rd_clk),
        .i_rd_en(i_rd_en),
        .i_empty(o_empty),
        .i_b_rd_ptr(rd_ptr),
        .o_rd_data(o_rd_data)
    );

endmodule //async_fifo