`timescale 1ns / 1ps

module uart_rx(input clk,
               input rst,
               input tick,
               input rx,
               
               output reg [7:0] data_out,
               output reg data_valid
    );

localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

reg [1:0] state;
reg [2:0] bit_index;
reg [7:0] data_reg;

reg [3:0] tick_count;

reg rx_d;                                 //this part is important for loopback
wire start_edge;                          //it detects the start edge of transmission and not just any zero
always @(posedge clk) begin
    rx_d <= rx;
end
assign start_edge = (rx_d == 1'b1) && (rx == 1'b0);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_valid <= 1'b0;
        state <=IDLE;
        bit_index <= 3'b000;
        tick_count <= 0;
    end
    else begin
        case(state)
        
            IDLE: begin
                data_valid <= 1'b0;
                 if (start_edge) begin
                    tick_count <= 4'd0;
                    state <= START;
                 end
            end
            
            START: begin
                if (tick) begin
                    if (tick_count == 4'd7) begin
                        if (rx == 1'b0) begin
                            tick_count <= 4'b0000;
                            bit_index <= 3'b000; 
                            state <= DATA;
                        end
                        else begin
                            state <= IDLE;  //false start, to avoid noise
                        end
                    end
                    else begin
                        tick_count <= tick_count + 4'b0001;
                    end
                end        
            end
            
            DATA: begin
                if(tick) begin
                    if (tick_count == 4'd15) begin
                        if (bit_index == 3'd7) begin
                            tick_count <= 4'b0000;
                            data_reg[bit_index] <= rx;
                            state <= STOP;
                        end
                        else begin
                            tick_count <= 4'd0;
                            data_reg[bit_index] <= rx;
                            bit_index <= bit_index +1;
                        end
                    end
                    else begin
                        tick_count <= tick_count + 1;
                    end
                end 
            end
            
            STOP: begin
                if(tick) begin
                    if (tick_count == 4'd15) begin
                        if (rx == 1'b1) begin
                            data_out <= data_reg;
                            data_valid <= 1'b1; 
                            state <= IDLE; 
                        end
                        else begin
                            data_valid <= 1'b0; //framing error,data recieved is incorrect because idle not 1                      
                        end
                        tick_count <= 4'd0;
                        bit_index <= 3'd0;
                        state <= IDLE;
                    end
                    else begin
                        tick_count <= tick_count + 1;
                    end
                end
            end    
        endcase
    end
end                                      
endmodule
