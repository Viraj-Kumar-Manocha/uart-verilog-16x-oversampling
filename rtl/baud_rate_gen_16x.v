`timescale 1ns / 1ps

module baud_rate_gen_16x #(parameter CLKS_PER_BIT = 5208)
                        (input clk,
                         input rst,
                         output reg tick);
  localparam CLKS_PER_TICK = (CLKS_PER_BIT+8) /16; //if directly divide by 16 it truncates,but now it rounds off                        
localparam WIDTH = $clog2(CLKS_PER_TICK);
reg [WIDTH-1:0]count;

always @(posedge clk or posedge rst)  begin                        
    if(rst) begin
        count <= 0;
        tick <= 1'b0;
    end
    else begin
        if (count == CLKS_PER_TICK-1) begin
            count <=0;
            tick <=1'b1;
        end
        else begin
            count <= count + 1;
            tick <= 1'b0;
        end
    end
end
endmodule
