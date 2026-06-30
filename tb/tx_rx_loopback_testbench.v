`timescale 1ns / 1ps

module tx_rx_loopback_testbench;
reg clk = 1'b0;
reg rst = 1'b1;
wire tick_tx,tick_rx;
//clk freq. = 1 MHZ , baud rate = 9600 , clks per bit ~ 104 , for 16x clks per bit ~ 7
//clk time period = 1000 ns
baud_rate_gen_16x #(.CLKS_PER_BIT(104)) brg2(.clk(clk),.rst(rst),.tick(tick_rx));
reg [3:0] tick_cnt;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        tick_cnt <= 4'b0000;
    end
    else if(tick_rx) begin
        if (tick_cnt == 4'd15) begin
            tick_cnt <= 4'd0;
        end
        else begin
            tick_cnt <= tick_cnt + 1;
        end
    end
end
assign tick_tx = tick_rx && (tick_cnt == 4'd8);
         

reg tx_start;
reg [7:0] data_in;
wire transmission;
wire busy,data_valid;
wire [7:0] data_out;

uart_tx tx0(.clk(clk),.rst(rst),.tick(tick_tx),.tx_start(tx_start),.data_in(data_in),.tx(transmission),.busy(busy));
uart_rx rx0(.clk(clk),.rst(rst),.tick(tick_rx),.rx(transmission),.data_out(data_out),.data_valid(data_valid));

reg [7:0] expected_data;

always #500 clk = ~clk;

initial begin
    #200;
    rst = 1'b0;
    tx_start = 1'b1;
    data_in = 8'hA4;
    wait (busy == 1'b1);
    tx_start = 1'b0;
    wait (busy == 1'b0);
    expected_data = data_in;

    tx_start = 1'b1;
    data_in = 8'hc5;
    wait(busy == 1'b1);
    tx_start = 1'b0;
    wait(busy == 1'b0);
    expected_data = data_in;


    tx_start = 1'b1;
    data_in = 8'hF1;
    wait(busy ==1'b1);
    tx_start = 1'b0;
    wait(busy == 1'b0);
    expected_data = data_in;
    
    tx_start = 1'b1;
    data_in = 8'h67;
    wait(busy==1'b1);
    tx_start = 1'b0;
    wait(busy == 1'b0);
    expected_data = data_in;
end   

always @(posedge data_valid) begin
    if (data_out != expected_data) begin
        $display ("FAIL : expected %h , output %h at time %0t",expected_data,data_out,$time);
    end
    else begin
        $display ("PASS : expected %h , output %h at time %0t",expected_data,data_out,$time);
    end
end
endmodule
    
