module ff_sync #(parameter DATA_WIDTH = 4)(

    input clk, rstn,
    input [DATA_WIDTH-1 : 0] i_data,
    output [DATA_WIDTH-1 : 0] o_data

);

    reg [DATA_WIDTH-1 : 0] f1, f2;

    always @(posedge clk or negedge rstn) begin

        if(!rstn) begin
            f1 <= 0;
            f2 <= 0; 
        end
        else begin
            f1 <= i_data;
            f2 <= f1;
        end

    end

    assign o_data = f2;

endmodule //ff_sync