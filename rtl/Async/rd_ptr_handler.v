// Read point Handler

module rd_ptr_handler #(parameter PTR_WIDTH)(
    input i_clk, i_rstn, i_en,
    input  [PTR_WIDTH : 0] i_g_wr_ptr,
    output [(PTR_WIDTH - 1) : 0] o_b_rd_ptr, // to fifo mem
    output reg [PTR_WIDTH : 0] o_g_rd_ptr, // gray ptr o/p to ff_sync
    output reg o_empty
);

    wire [PTR_WIDTH : 0] nxt_b_rd_ptr, nxt_g_rd_ptr;
    wire rd_empty;

    always @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) begin
            o_b_rd_ptr <= 0;
            o_g_rd_ptr <= 0;
            o_empty <= 0;
        end
        else begin
            o_b_rd_ptr <= nxt_b_rd_ptr;
            o_g_rd_ptr <= nxt_g_rd_ptr;
            o_empty <= rd_empty;
        end
    end

    // next binary ptr calculation
    assign nxt_b_rd_ptr = o_b_rd_ptr + (~o_empty & i_en);
    // next gray ptr calculation
    assign nxt_g_rd_ptr = nxt_b_rd_ptr ^ (nxt_b_rd_ptr >> 1);

    // Full flag
    // Without conversion of gray to binary
    assign rd_empty = (nxt_g_rd_ptr == i_g_wr_ptr);

endmodule //rd_handler