`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 03:21:44
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(input clk,
               input rst,
               input tick,  //from baud rate generator
               input tx_start, //starts transmission
               input [7:0]data_in, //input data
               
               output reg tx, //serial data output
               output reg busy //if busy = 1, transmission going on, if 0 then idle
    );
//states of fsm: idle,start,data,stop
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

reg [1:0]state;
reg [2:0] data_index;
reg [7:0] data_reg;         //in case data_in changes in between, storing a copy internally

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1'b1;
        busy <= 1'b0;
        data_index <= 3'b000;
    end
    else begin
 
        case (state)
            IDLE: begin
                tx <= 1'b1;
                busy <= 1'b0;
                if (tx_start) begin
                    data_reg <= data_in;
                    state <= START;
                    busy <= 1'b1;
                end
            end
            
            START: begin
                if (tick) begin
                    tx<=1'b0;
                    data_index <= 3'b000;
                    state <= DATA;
                end
            end
            
            DATA: begin
                if (tick) begin
                    tx <= data_reg[data_index];
                    if (data_index == 3'd7) begin
                        state <= STOP;
                    end
                    else begin
                        data_index <= data_index + 1'b1;                        
                    end
                end
            end    
            
            STOP: begin
                if (tick) begin
                    tx <= 1'b1;
                    state <= IDLE;
                    busy <= 1'b0;
                end            
            end        
        endcase            
    end
end                
endmodule
