`timescale 1ns/1ps

module tb_async_fifo;

    // --------------------------------------------------
    // Parameters
    // --------------------------------------------------
    localparam DATA_WIDTH = 64;
    localparam DEPTH      = 512;

    // --------------------------------------------------
    // Clocks & reset
    // --------------------------------------------------
    reg i_wr_clk;
    reg i_rd_clk;
    reg i_wr_rstn;
    reg i_rd_rstn;

    // --------------------------------------------------
    // Write interface
    // --------------------------------------------------
    reg                  i_wr_en;
    reg  [DATA_WIDTH-1:0] i_wr_data;
    wire                 o_full;

    // --------------------------------------------------
    // Read interface
    // --------------------------------------------------
    reg                  i_rd_en;
    wire [DATA_WIDTH-1:0] o_rd_data;
    wire                 o_empty;

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    async_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_wr_clk  (i_wr_clk),
        .i_wr_rstn (i_wr_rstn),
        .i_wr_en   (i_wr_en),
        .i_wr_data (i_wr_data),
        .o_full    (o_full),

        .i_rd_clk  (i_rd_clk),
        .i_rd_rstn (i_rd_rstn),
        .i_rd_en   (i_rd_en),
        .o_rd_data (o_rd_data),
        .o_empty   (o_empty)
    );

    // --------------------------------------------------
    // Clock generation (async clocks)
    // --------------------------------------------------
    initial i_wr_clk = 0;
    always #5  i_wr_clk = ~i_wr_clk;   // 100 MHz

    initial i_rd_clk = 0;
    always #7  i_rd_clk = ~i_rd_clk;   // ~71 MHz

    // --------------------------------------------------
    // Scoreboard
    // --------------------------------------------------
    reg [DATA_WIDTH-1:0] scoreboard [0:1023];
    integer wr_count = 0;
    integer rd_count = 0;

    // --------------------------------------------------
    // Reset
    // --------------------------------------------------
    initial begin
        i_wr_rstn = 0;
        i_rd_rstn = 0;
        i_wr_en   = 0;
        i_rd_en   = 0;
        i_wr_data = 0;

        #50;
        i_wr_rstn = 1;
        i_rd_rstn = 1;
    end

    // --------------------------------------------------
    // Write process
    // --------------------------------------------------
    always @(posedge i_wr_clk) begin
        if (i_wr_rstn) begin
            i_wr_en <= ($random % 2);

            if (i_wr_en && !o_full) begin
                i_wr_data <= $random;
                scoreboard[wr_count] <= i_wr_data;
                wr_count <= wr_count + 1;
            end
        end
    end

    // --------------------------------------------------
    // Read process
    // --------------------------------------------------
    // /*
    always @(posedge i_rd_clk) begin
        if (i_rd_rstn) begin
            i_rd_en <= ($random % 2);

            if (i_rd_en && !o_empty) begin
                if (o_rd_data !== scoreboard[rd_count]) begin
                    $display("ERROR at time %0t: Expected %0h, Got %0h",
                             $time, scoreboard[rd_count], o_rd_data);
                    $fatal;
                end
                rd_count <= rd_count + 1;
            end
        end
    end
    // */

    // --------------------------------------------------
    // Simulation control
    // --------------------------------------------------
    initial begin
        #5000;
        $display("-------------------------------------------------");
        $display("TEST PASSED");
        $display("Total Writes = %0d", wr_count);
        $display("Total Reads  = %0d", rd_count);
        $display("-------------------------------------------------");
        $finish;
    end

    initial begin
        $dumpfile("tb_async.vcd");
        $dumpvars(0, tb_async_fifo);
    end

endmodule
