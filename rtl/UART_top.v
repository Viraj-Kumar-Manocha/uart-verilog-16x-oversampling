`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 02:26:46
// Design Name: 
// Module Name: UART_top
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


module UART_top(
    input clk,
    input rst,
    input tx_start,
    input [7:0] data_in,
    input rx,
    output tx,
    output busy,
    output [7:0] data_out,
    output data_valid
);

wire tick;

baud_rate_gen_16x #(.CLKS_PER_BIT(104)) brg (
    .clk(clk),
    .rst(rst),
    .tick(tick)
);

uart_tx tx_inst (
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .tx_start(tx_start),
    .data_in(data_in),
    .tx(tx),
    .busy(busy)
);

uart_rx rx_inst (
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .rx(rx),
    .data_out(data_out),
    .data_valid(data_valid)
);

endmodule
