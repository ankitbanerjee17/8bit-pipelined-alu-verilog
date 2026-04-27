module alu_pipeline (
    input        clk,
    input        rst,
    input  [7:0] A,
    input  [7:0] B,
    input  [2:0] opcode,
    output reg [7:0] result,
    output reg       carry_out,
    output reg       zero_flag
);
    // Operation codes
    parameter ADD = 3'b000;
    parameter SUB = 3'b001;
    parameter AND = 3'b010;
    parameter OR  = 3'b011;
    parameter XOR = 3'b100;
    parameter NOT = 3'b101;
    parameter SHL = 3'b110;
    parameter SHR = 3'b111;

    // CLA adder outputs
    wire [7:0] add_result, sub_result;
    wire       add_carry, sub_borrow;
    wire [7:0] B_neg;

    // Two's complement for subtraction
    assign B_neg = ~B + 1;

    // Two CLA instances: one for ADD, one for SUB
    cla_adder adder_inst (
        .A(A), .B(B), .Cin(1'b0),
        .Sum(add_result), .Cout(add_carry)
    );
    cla_adder subber_inst (
        .A(A), .B(B_neg), .Cin(1'b0),
        .Sum(sub_result), .Cout(sub_borrow)
    );

    // ---- PIPELINE STAGE 1 REGISTER ----
    reg [7:0] stage1_result;
    reg       stage1_carry;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stage1_result <= 8'b0;
            stage1_carry  <= 1'b0;
        end else begin
            case (opcode)
                ADD: begin stage1_result <= add_result; stage1_carry <= add_carry;  end
                SUB: begin stage1_result <= sub_result; stage1_carry <= sub_borrow; end
                AND: begin stage1_result <= A & B;      stage1_carry <= 1'b0;       end
                OR:  begin stage1_result <= A | B;      stage1_carry <= 1'b0;       end
                XOR: begin stage1_result <= A ^ B;      stage1_carry <= 1'b0;       end
                NOT: begin stage1_result <= ~A;         stage1_carry <= 1'b0;       end
                SHL: begin stage1_result <= A << 1;     stage1_carry <= A[7];       end
                SHR: begin stage1_result <= A >> 1;     stage1_carry <= A[0];       end
                default: begin stage1_result <= 8'b0;  stage1_carry <= 1'b0;       end
            endcase
        end
    end

    // ---- PIPELINE STAGE 2 REGISTER (output) ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= 8'b0;
            carry_out <= 1'b0;
            zero_flag <= 1'b0;
        end else begin
            result    <= stage1_result;
            carry_out <= stage1_carry;
            zero_flag <= (stage1_result == 8'b0);
        end
    end

endmodule
