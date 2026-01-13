`timescale 1ns/1ps

module tb_sync_fifo;

    // Parameters
    localparam DATA_WIDTH = 64;
    localparam DEPTH      = 512;   // use small depth for faster simulation

    // DUT signals
    reg                     i_wr_clk;
    reg                     i_rstn;
    reg                     i_wr_en;
    reg                     i_rd_en;
    reg  [DATA_WIDTH-1:0]   i_wr_data;

    wire                    o_full;
    wire                    o_empty;
    wire [DATA_WIDTH-1:0]   o_rd_data;
    wire [$clog2(DEPTH):0]  wr_data_count;
    wire [$clog2(DEPTH):0]  rd_data_count;

    // Instantiate DUT
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .i_rstn(i_rstn),
        .i_wr_clk(i_wr_clk),
        .i_wr_en(i_wr_en),
        .i_wr_data(i_wr_data),
        .o_full(o_full),
        .wr_data_count(wr_data_count),
        .i_rd_en(i_rd_en),
        .o_rd_data(o_rd_data),
        .o_empty(o_empty),
        .rd_data_count(rd_data_count)
    );

    // Clock generation (100 MHz)
    always #5 i_wr_clk = ~i_wr_clk;

    // Scoreboard
    reg[DATA_WIDTH:0] write_count;
    reg[DATA_WIDTH:0] read_count;

    // Reset task
    task reset_fifo;
    begin
        i_rstn   = 0;
        i_wr_en = 0;
        i_rd_en = 0;
        i_wr_data = 0;
        repeat (3) @(posedge i_wr_clk);
        i_rstn = 1;
        @(posedge i_wr_clk);
    end
    endtask

    // Write task
    task fifo_write(input [DATA_WIDTH-1:0] data);
    begin
        @(posedge i_wr_clk);
        if (!o_full) begin
            i_wr_en   = 1;
            i_wr_data = data;
            write_count++;
        end else begin
            $display("[%0t] WRITE BLOCKED (FULL)", $time);
        end
        @(posedge i_wr_clk);
        i_wr_en = 0;
    end
    endtask

    // Read task
    task fifo_read;
    begin
        @(posedge i_wr_clk);
        if (!o_empty) begin
            i_rd_en = 1;
            read_count++;
        end else begin
            $display("[%0t] READ BLOCKED (EMPTY)", $time);
        end
        @(posedge i_wr_clk);
        i_rd_en = 0;
    end
    endtask

    // Main test sequence
    initial begin
        // Init
        i_wr_clk = 0;
        write_count = 0;
        read_count  = 0;

        // Reset
        reset_fifo();

        // Check empty after reset
        if (!o_empty)
            $error("FIFO not empty after reset");
        else
            $display("FIFO succesfully reset");

        // Fill FIFO
        $display("---- Filling FIFO ----");
        repeat (DEPTH) begin
            fifo_write(write_count + 1);
        end

        if (!o_full)
            $error("FIFO not full after %0d writes", DEPTH);

        // Extra write (should be blocked)
        fifo_write(64'hDEADBEEF);

        // Check count
        if (wr_data_count != DEPTH)
            $error("Incorrect wr_data_count: %0d", wr_data_count);

        // Read half FIFO
        $display("---- Reading half FIFO ----");
        repeat (DEPTH/2) begin
            fifo_read();
        end

        if (o_full)
            $error("FIFO still full after reads");

        // Simultaneous read + write
        $display("---- Simultaneous Read/Write ----");
        @(posedge i_wr_clk);
        i_wr_en   = 1;
        i_wr_data = 64'hAAAA;
        i_rd_en   = 1;
        @(posedge i_wr_clk);
        i_wr_en   = 0;
        i_rd_en   = 0;

        // Drain FIFO
        $display("---- Draining FIFO ----");
        while (!o_empty) begin
            fifo_read();
        end

        if (!o_empty)
            $error("FIFO not empty after drain");

        // Extra read (should be blocked)
        fifo_read();

        // Final count check
        if (wr_data_count != 0 || rd_data_count != 0)
            $error("Count not zero at end");

        $display("---- TEST PASSED ----");
        $finish;
    end

    initial begin
        $dumpfile("tb_sync.vcd");
        $dumpvars(0, tb_sync_fifo);
    end


endmodule