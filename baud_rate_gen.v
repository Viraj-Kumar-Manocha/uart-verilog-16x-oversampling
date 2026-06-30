`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 00:34:28
// Design Name: 
// Module Name: baud_rate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_rate_gen #(parameter CLKS_PER_BIT = 5208) //clks per bit = clk freq./baud rate
                      (input clk,                     //assuming 50 MHZ and 9600 baud rate  
                       input rst,                     //clks per bit ~ 5208 
                       output reg tick
);

localparam WIDTH = $clog2(CLKS_PER_BIT); //ceiling of log base 2, gives max number of registers required
reg [WIDTH-1:0] count; //sets number of registers for count

always @(posedge clk or posedge rst) begin
    if (rst) begin
    count <= 16'h0000;
    tick <= 1'b0;
    end
    else begin
        if (count == CLKS_PER_BIT-1) begin
            tick <= 1'b1;
            count <= 16'h0000;
        end
        else begin
            tick <= 1'b0;
            count <= count + 1'b1;
        end
    end
end    
endmodule
