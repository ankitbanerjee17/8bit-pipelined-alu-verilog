`timescale 1ns/1ps

module alu_tb;
    reg        clk, rst;
    reg  [7:0] A, B;
    reg  [2:0] opcode;
    wire [7:0] result;
    wire       carry_out, zero_flag;

    alu_pipeline uut (
        .clk(clk), .rst(rst),
        .A(A), .B(B), .opcode(opcode),
        .result(result),
        .carry_out(carry_out),
        .zero_flag(zero_flag)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
    end

    initial begin
        rst = 1; A = 0; B = 0; opcode = 0;
        #15 rst = 0;

        A = 8'd50;       B = 8'd30;       opcode = 3'b000; #30;
        $display("ADD  50+30   = %0d  (expect 80),   carry=%b", result, carry_out);

        A = 8'd100;      B = 8'd45;       opcode = 3'b001; #30;
        $display("SUB  100-45  = %0d  (expect 55)", result);

        A = 8'b11001100; B = 8'b10101010; opcode = 3'b010; #30;
        $display("AND          = %08b  (expect 10001000)", result);

        A = 8'b11001100; B = 8'b10101010; opcode = 3'b011; #30;
        $display("OR           = %08b  (expect 11101110)", result);

        A = 8'b11001100; B = 8'b10101010; opcode = 3'b100; #30;
        $display("XOR          = %08b  (expect 01100110)", result);

        A = 8'b11110000; B = 8'h00;       opcode = 3'b101; #30;
        $display("NOT          = %08b  (expect 00001111)", result);

        A = 8'b00000001; B = 8'h00;       opcode = 3'b110; #30;
        $display("SHL          = %08b  (expect 00000010)", result);

        A = 8'd255;      B = 8'd1;        opcode = 3'b000; #30;
        $display("OVERFLOW 255+1 = %0d, carry=%b  (expect 0, carry=1)", result, carry_out);

        A = 8'd5;        B = 8'd5;        opcode = 3'b100; #30;
        $display("ZERO FLAG    = %b  (expect 1)", zero_flag);

        #30 $finish;
    end
endmodule
