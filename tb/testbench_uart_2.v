`timescale 1ns / 1ps

module testbench_uart_2;
reg clk = 1'b0;
reg rst = 1'b1;
wire tick_tx, tick_rx;

//clk freq. = 1 MHZ , baud rate = 9600 , clks per bit ~ 104 , for 16x clks per bit ~ 7
//clk time period = 1000 ns
baud_rate_gen_16x #(.CLKS_PER_BIT(104)) brg2(.clk(clk), .rst(rst), .tick(tick_rx));

reg [3:0] tick_cnt;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tick_cnt <= 4'b0000;
    end
    else if (tick_rx) begin
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
wire busy, data_valid;
wire [7:0] data_out;

uart_tx tx0(.clk(clk), .rst(rst), .tick(tick_tx), .tx_start(tx_start), .data_in(data_in), .tx(transmission), .busy(busy));
uart_rx rx0(.clk(clk), .rst(rst), .tick(tick_rx), .rx(transmission), .data_out(data_out), .data_valid(data_valid));

reg [7:0] expected_data;
integer pass_count = 0;
integer fail_count = 0;
integer total_bytes = 10000;   // change this to test more/fewer bytes
integer i;

always #500 clk = ~clk;   // 1 MHz clock (1000 ns period)

reg [7:0] expected_queue[0:10239];   // store up to 10240 expected bytes
integer send_idx = 0;
integer check_idx = 0;
integer pass_count = 0;
integer fail_count = 0;
integer total_bytes = 200;
integer i;

initial begin
    #200;
    rst = 1'b0;

    for (i = 0; i < total_bytes; i = i + 1) begin
        data_in = $random;
        expected_queue[send_idx] = data_in;   // store, don't overwrite a single reg
        send_idx = send_idx + 1;
        tx_start = 1'b1;
        wait (busy == 1'b1);
        tx_start = 1'b0;
        wait (busy == 1'b0);
    end

    #120000000;
    $display("=================================");
    $display("TOTAL BYTES SENT : %0d", total_bytes);
    $display("PASS             : %0d", pass_count);
    $display("FAIL             : %0d", fail_count);
    $display("SUCCESS RATE     : %.2f%%", (pass_count * 100.0) / (pass_count + fail_count));
    $display("=================================");
    $finish;
end

always @(posedge data_valid) begin
    if (data_out != expected_queue[check_idx]) begin
        fail_count = fail_count + 1;
        $display("FAIL : expected %h , output %h at time %0t", expected_queue[check_idx], data_out, $time);
    end
    else begin
        pass_count = pass_count + 1;
        $display("PASS : expected %h , output %h at time %0t", expected_queue[check_idx], data_out, $time);
    end
    check_idx = check_idx + 1;
end

endmodule
