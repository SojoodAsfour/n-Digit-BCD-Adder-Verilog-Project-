//Sojood Asfour 1230298
//sec 2

// 1-bit full adder constructed from basic logic gates
// Computes sum and carry-out for inputs a, b, and carry-in (cin)
module full_adder(input a, b, cin, output sum, cout);
  wire and_ab, and_bcin, and_acin; 

  // sum = a XOR b XOR cin
  xor #(15) u1(sum, cin, a, b); // 15 ns 

  // carry = (a AND b) OR (b AND cin) OR (a AND cin)
  and #(11) u3(and_ab, a, b);   // 11 ns
  and #(11) u4(and_bcin, b, cin);
  and #(11) u5(and_acin, a, cin);
  or #(11) u6(cout, and_ab, and_bcin, and_acin); // 11 ns
endmodule

// 4-bit adder built using four 1-bit full adders
// Adds two 4-bit inputs x and y with a carry-in and produces a 4-bit sum and carry-out
module adder4_bit(input cin, input [3:0] x, y, output cout, output [3:0] sum);
  wire [4:0] c;
  assign c[0] = cin;
  assign cout = c[4];
  genvar i;
  generate 
    for (i = 0; i <= 3; i = i + 1) begin : addbit
      full_adder adder (.a(x[i]), .b(y[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
    end
  endgenerate
endmodule 

// 1-digit BCD adder using the 4-bit adder
module BCD1_digit(input cin, input [3:0] A, B, output cout, output [3:0] sum);
  wire [3:0] S, final_sum;
  wire coutadd1, OutputCarry, dummy_cout;  

  // First 4-bit addition
  adder4_bit adder1(.cin(cin), .x(A), .y(B), .cout(coutadd1), .sum(S));  

  // Check if correction is needed: S > 9 or coutadd1 = 1;
  wire and23, and13;
  and #(11) u1(and13, S[1], S[3]);
  and #(11) u2(and23, S[2], S[3]);
  or #(11) u3(OutputCarry, and13, and23, coutadd1);   

  // Add 6 (0110) if correction is needed
  wire [3:0] checkS;
  assign checkS = OutputCarry ? 4'b0110 : 4'b0000;
  adder4_bit adder2(.cin(0), .x(S), .y(checkS), .cout(dummy_cout), .sum(final_sum));

  assign sum = final_sum;
  assign cout = OutputCarry;
endmodule 

// n-digit BCD adder (Ripple-Carry based) with clocked input/output registers
// Implements a multi-digit BCD adder by cascading 1-digit BCD adders
// Synchronous design with reset and clock to register inputs and outputs
module BCD_Adder_ndigit_Ripple #(parameter n = 3)(input clk, rst, cin, input [4*n-1:0] A, B, output reg [4*n-1:0] Sum, output reg Cout);
  reg [4*n-1:0] A_reg, B_reg;
  reg Cin_reg;
  wire [4*n-1:0] sum;
  wire [n:0] Carry;

  assign Carry[0] = Cin_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      A_reg <= 0;
      B_reg <= 0;
      Cin_reg <= 0;
    end else begin
      A_reg <= A;
      B_reg <= B;
      Cin_reg <= cin;
    end
  end

  genvar i;
  generate
    for (i = 0; i < n; i = i + 1) begin : bcd_1digit
      BCD1_digit bcd (.cin(Carry[i]), .A(A_reg[4*i+3:4*i]), .B(B_reg[4*i+3:4*i]), .cout(Carry[i+1]), .sum(sum[4*i+3:4*i]));
    end
  endgenerate

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Sum <= 0;
      Cout <= 0;
    end else begin
      Sum <= sum;
      Cout <= Carry[n];
    end
  end
endmodule  

// 4-bit Carry Look-Ahead Adder (CLA)
// Computes sum and carry-out faster using generate/propagate logic instead of ripple-carry
// Includes logic for computing intermediate carry signals C1 to C3
module Carry_LA_4bit(input [3:0] A, B, input cin, output [3:0] Sum, output Cout);
  wire [3:0] G, P, C;
  assign C[0] = cin;
  genvar i;
  generate
    for(i = 0; i < 4; i++) begin: GP_signal
      and #(11) (G[i], A[i], B[i]);
      xor #(15) (P[i], A[i], B[i]);
    end
  endgenerate
  wire p0_cin, p1_g0, p1_p0_cin, p2_g1, p2_p1_g0, p2_p1_p0_cin, p3_g2, p3_p2_g1, p3_p2_p1_g0, p3_p2_p1_p0_cin;
  and #(11) (p0_cin, P[0], cin);
  or #(11) (C[1], G[0], p0_cin);
  and #(11) (p1_g0, P[1], G[0]);
  and #(11) (p1_p0_cin, P[1], P[0], cin);
  or #(11) (C[2], G[1], p1_g0, p1_p0_cin);
  and #(11) (p2_g1, P[2], G[1]);
  and #(11) (p2_p1_g0, P[2], P[1], G[0]);
  and #(11) (p2_p1_p0_cin, P[2], P[1], P[0], cin);
  or #(11) (C[3], G[2], p2_g1, p2_p1_g0, p2_p1_p0_cin);
  and #(11) (p3_g2, P[3], G[2]);
  and #(11) (p3_p2_g1, P[3], P[2], G[1]);
  and #(11) (p3_p2_p1_g0, P[3], P[2], P[1], G[0]);
  and #(11) (p3_p2_p1_p0_cin, P[3], P[2], P[1], P[0], cin);
  or #(11) (Cout, G[3], p3_g2, p3_p2_g1, p3_p2_p1_g0, p3_p2_p1_p0_cin);
  generate
    for (i = 0; i < 4; i++) begin : generate_sum
      xor #(15) (Sum[i], P[i], C[i]);
    end
  endgenerate
endmodule

// 1-digit BCD adder using Carry Look-Ahead Adder for both normal and correction additions
// Performs initial sum using CLA, applies BCD correction if needed using a second CLA
module ClA_BCD_1digit(input Cin, input [3:0] A, B, output Cout, output [3:0] Sum);
  wire [3:0] sum_adder1, final_sum;
  wire cout_adder1, output_carry, dummy_cout;

  Carry_LA_4bit add1(.A(A), .B(B), .cin(Cin), .Sum(sum_adder1), .Cout(cout_adder1));

  wire and13, and23;
  and #(11)(and13, sum_adder1[1], sum_adder1[3]);
  and #(11)(and23, sum_adder1[2], sum_adder1[3]);
  or #(11)(output_carry, and13, and23, cout_adder1);

  wire [3:0] check_sum1;
  assign check_sum1 = output_carry ? 4'b0110 : 4'b0000;
  Carry_LA_4bit add2(.A(sum_adder1), .B(check_sum1), .cin(1'b0), .Sum(final_sum), .Cout(dummy_cout));

  assign Sum = final_sum;
  assign Cout = output_carry;
endmodule

// n-digit BCD adder using Carry Look-Ahead Adders
// Structurally builds a multi-digit BCD adder using CLA-based 1-digit BCD adders
// Registers inputs and outputs using clock and reset for synchronous operation
module BCD_Adder_ndigit_Cla #(parameter n = 3)(input clk, rst, cin, input [4*n-1:0] A, B, output reg [4*n-1:0] Sum, output reg Cout);
  reg [4*n-1:0] A_reg, B_reg;
  reg Cin_reg;
  wire [4*n-1:0] sum;
  wire [n:0] Carry;

  assign Carry[0] = Cin_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      A_reg <= 0;
      B_reg <= 0;
      Cin_reg <= 0;
    end else begin
      A_reg <= A;
      B_reg <= B;
      Cin_reg <= cin;
    end 
  end 

  genvar i;
  generate
    for (i = 0; i < n; i++) begin : bcd_1digit
      ClA_BCD_1digit bcd (.Cin(Carry[i]), .A(A_reg[4*i+3:4*i]), .B(B_reg[4*i+3:4*i]), .Cout(Carry[i+1]), .Sum(sum[4*i+3:4*i]));
    end
  endgenerate  

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Sum <= 0;
      Cout <= 0;
    end 
  	else begin
      Sum <= sum;
      Cout <= Carry[n];
  	 end
	end		 
endmodule 

module BCD_Adder_ndigit_Behavioral #(parameter n = 3)(input clk, rst, cin, input [4*n-1:0] A, B, output reg [4*n-1:0] Sum, output reg Cout);

  integer i;
  reg [4:0] temp;
  reg [3:0] a_digit, b_digit;
  reg carry;
  reg [4*n-1:0] next_Sum;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      Sum  <= 0;
      Cout <= 0;
    end else begin
      carry = cin;
      next_Sum = 0;

      for (i = 0; i < n; i = i + 1) begin
        // Extract digit i from A and B using shift
        a_digit = (A >> (i * 4)) & 4'b1111;
        b_digit = (B >> (i * 4)) & 4'b1111;

        temp = a_digit + b_digit + carry;

        if (temp > 9) begin
          temp = temp + 6;
          carry = 1;
        end else begin
          carry = 0;
        end

        // Store result in correct place using shift
        next_Sum = next_Sum | (temp[3:0] << (i * 4));
      end

      Sum  <= next_Sum;
      Cout <= carry;
    end
  end

endmodule
