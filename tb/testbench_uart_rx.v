`timescale 1ns / 1ps

module testbench_uart_rx;
reg clk = 1'b0;
reg rst = 1'b1;
reg rx = 1'b1;
wire tick;
integer i = 0;
reg [7:0] data_in=8'hA5;

wire [7:0] data_out;
wire data_valid;

baud_rate_gen_16x #(.CLKS_PER_BIT(160)) test(.clk(clk),.rst(rst),.tick(tick));

uart_rx uut(.clk(clk),.rst(rst),.tick(tick),.rx(rx),.data_out(data_out),.data_valid(data_valid));

parameter BIT_TIME = 1600;
always #5 clk = ~ clk;

initial begin
    #50;
    rst = 1'b0;
    #1000;
    rx = 1'b0;
    #(BIT_TIME);
    for (i=0;i<8;i=i+1) begin
            rx = data_in[i];
            #(BIT_TIME);
    end
    rx = 1'b1;
    #5000;
    
    rx = 1'b0;
    #(BIT_TIME);
    data_in = 8'hC3;
    for (i=0;i<8;i=i+1) begin
        rx = data_in[i];
        #(BIT_TIME);
    end
    rx = 1'b1;
    #5000;
    
    rx=1'b0;
    #(BIT_TIME);
    data_in = 8'hf1;
    for (i=0;i<8;i=i+1) begin
        rx = data_in[i];
        #(BIT_TIME);
    end  
    rx=1'b0;
    #20000; 
      //not making rx = 1'b1 for checking error correctly shows
    $finish;
    end
endmodule
