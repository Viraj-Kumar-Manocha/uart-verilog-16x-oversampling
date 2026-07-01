`timescale 1ns / 1ps

module testbench_uart_transmitter;
reg clk = 1'b0;
reg tx_start = 1'b0;
reg rst=1'b0;
reg tick = 1'b0;
reg [7:0] data_in;
wire out,busy;

uart_tx tb(.clk(clk),.rst(rst),.tick(tick),.tx_start(tx_start),.data_in(data_in),.tx(out),.busy(busy));

always #5 clk = ~clk;

always begin 
    tick = 1'b1;
    #10;
    tick = 1'b0;
    #90;
end
    
initial begin
    rst = 1'b1;
    #50;
    rst = 1'b0;
    
    //first transmission
    tx_start = 1'b1;
    data_in = 8'hA5;
    #10;
    tx_start = 1'b0;
    
    data_in = 8'hF1;  //changing data mid tranmission to check busy and data_reg
    
    #2000;  //waiting
    
    //second transmission 
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    
    #500; //wait, less because checking whether transmission starts when busy
    
    //third transmission
    tx_start = 1'b1;
    data_in = 8'h3C;
    #10;
    tx_start = 1'b0;
    
    #800;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    
    #1000; //wait
    $finish;
end     
endmodule
