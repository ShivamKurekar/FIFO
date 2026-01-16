`timescale 1ns/1ps

module async_fifo_tb;

    parameter DATA_WIDTH = 64;
    parameter DEPTH      = 512;

    reg                   i_wr_clk;
    reg                   i_rd_clk;
    reg                   i_wr_rstn;
    reg                   i_rd_rstn;
    reg                   i_wr_en;
    reg                   i_rd_en;
    reg [DATA_WIDTH-1:0]  i_wr_data;

    wire [DATA_WIDTH-1:0] o_rd_data;
    wire                  o_full;
    wire                  o_empty;

    integer write_count;
    integer read_count;

    async_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_wr_clk   (i_wr_clk),
        .i_wr_rstn  (i_wr_rstn),
        .i_wr_en    (i_wr_en),
        .i_wr_data  (i_wr_data),
        .o_full     (o_full),
        .i_rd_clk   (i_rd_clk),
        .i_rd_rstn  (i_rd_rstn),
        .i_rd_en    (i_rd_en),
        .o_rd_data  (o_rd_data),
        .o_empty    (o_empty)
    );

    // Asynchronous clocks
    always #5  i_wr_clk = ~i_wr_clk;
    always #11 i_rd_clk = ~i_rd_clk;

    initial begin
        // Init
        i_wr_clk  = 0;
        i_rd_clk  = 0;
        i_wr_rstn = 0;
        i_rd_rstn = 0;
        i_wr_en   = 0;
        i_rd_en   = 0;
        i_wr_data = {DATA_WIDTH{1'b0}};
        write_count = 0;
        read_count  = 0;

        // Reset
        repeat (5) @(posedge i_wr_clk);
        repeat (5) @(posedge i_rd_clk);
        i_wr_rstn = 1;
        i_rd_rstn = 1;

        $display("[%0t] Reset released", $time);

        // ---------------- FILL FIFO ----------------
        while (!o_full) begin
            @(posedge i_wr_clk);
            i_wr_en   = 1'b1;
            i_wr_data = $random;
            write_count = write_count + 1;
        end
        @(posedge i_wr_clk);
        i_wr_en = 0;

        if (!o_full) begin
            $display("ERROR: FIFO not FULL");
            $finish;
        end

        // ---------------- OVERFLOW CHECK ----------------
        @(posedge i_wr_clk);
        i_wr_en = 1;
        @(posedge i_wr_clk);
        i_wr_en = 0;

        if (!o_full) begin
            $display("ERROR: FIFO overflow allowed");
            $finish;
        end

        // ---------------- DRAIN FIFO ----------------
        while (!o_empty) begin
            @(posedge i_rd_clk);
            i_rd_en = 1'b1;
            read_count = read_count + 1;
        end
        @(posedge i_rd_clk);
        i_rd_en = 0;

        if (!o_empty) begin
            $display("ERROR: FIFO not EMPTY");
            $finish;
        end

        // ---------------- UNDERFLOW CHECK ----------------
        @(posedge i_rd_clk);
        i_rd_en = 1;
        @(posedge i_rd_clk);
        i_rd_en = 0;

        if (!o_empty) begin
            $display("ERROR: FIFO underflow allowed");
            $finish;
        end

        $display("[%0t] ASYNC FIFO TEST PASSED", $time);
        $finish;
    end

    initial begin
        $dumpfile("tb_async2.vcd");
        $dumpvars(0, async_fifo_tb);
    end

endmodule
