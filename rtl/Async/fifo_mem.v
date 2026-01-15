module fifo_mem #(parameter DEPTH = 512,
                parameter DATA_WIDTH = 64)(

    /* Write clk domain */
    input i_wr_clk,
    input i_wr_en, i_full,
    input [DATA_WIDTH-1: 0] i_wr_data,
    input [$clog2(DEPTH): 0] i_b_wr_ptr,

    /* Read clk domain */
    input  i_rd_clk,
    input i_rd_en, i_empty,
    input [$clog2(DEPTH): 0] i_b_rd_ptr,
    output reg [(DATA_WIDTH-1): 0] o_rd_data
);

    /* Since pointers are passed we exclude MSB as they are for wrap bits */
    wire [($clog2(DEPTH)-1) : 0] WR_ADDR;
    wire [($clog2(DEPTH)-1) : 0] RD_ADDR;

    assign WR_ADDR = i_b_wr_ptr[($clog2(DEPTH)-1): 0];
    assign RD_ADDR = i_b_rd_ptr[($clog2(DEPTH)-1): 0];    

    reg [(DATA_WIDTH-1) : 0] mem [0: DEPTH-1];

    always @(posedge i_wr_clk)
        if(i_wr_en && !i_full) mem [WR_ADDR] <= i_wr_data;
    
    always @(posedge i_rd_clk)
        if(i_rd_en && !i_empty) o_rd_data <= mem [RD_ADDR];

endmodule //memory