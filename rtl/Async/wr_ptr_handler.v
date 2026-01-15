// Write point Handler

module wr_ptr_handler #(parameter PTR_WIDTH)(
    input i_clk, i_rstn, i_en,
    input  [PTR_WIDTH : 0] i_g_rd_ptr,
    output reg [PTR_WIDTH : 0] o_b_wr_ptr, // to fifo mem
    output reg [PTR_WIDTH : 0] o_g_wr_ptr, // gray ptr o/p to ff_sync
    output reg o_full
);

    wire [PTR_WIDTH : 0] nxt_b_wr_ptr, nxt_g_wr_ptr;
    wire wr_full;

    always @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) begin
            o_b_wr_ptr <= 0;
            o_g_wr_ptr <= 0;
            o_full <= 0;
        end
        else begin
            o_b_wr_ptr <= nxt_b_wr_ptr;
            o_g_wr_ptr <= nxt_g_wr_ptr;
            o_full <= wr_full;
        end
    end

    // next binary ptr calculation
    assign nxt_b_wr_ptr = o_b_wr_ptr + (~o_full & i_en);
    // next gray ptr calculation
    assign nxt_g_wr_ptr = nxt_b_wr_ptr ^ (nxt_b_wr_ptr >> 1);

    // Full flag
    // Without conversion of gray to binary
    assign wr_full = (nxt_g_wr_ptr == ({~i_g_rd_ptr [PTR_WIDTH : PTR_WIDTH - 1], i_g_rd_ptr [PTR_WIDTH-2 : 0]}));

endmodule //wpr_handler