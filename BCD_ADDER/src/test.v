//Sojood Asfour 1230298
//sec 2

`timescale 1ns/1ps

module BCD_Adder_Test_All;
  reg clk, rst, cin;
  reg [11:0] A, B; // 3-digit BCD input
  wire [11:0] Sum_Ripple, Sum_Cla, Sum_Expected;
  wire Cout_Ripple, Cout_Cla, Cout_Expected;

  integer i, errors_ripple, errors_cla;

  //Instantiateof Ripple-Carry BCD Adder
  BCD_Adder_ndigit_Ripple #(3) ripple_adder (clk, rst , cin, A, B, Sum_Ripple, Cout_Ripple);

  //Instantiate Of CLA BCD Adder
  BCD_Adder_ndigit_Cla #(3) cla_adder (clk, rst , cin, A, B, Sum_Cla, Cout_Cla);

  //Instantiate of Behavioral BCD Adder
  BCD_Adder_ndigit_Behavioral #(3) behavioral_adder (clk, rst , cin, A, B, Sum_Expected,Cout_Expected);

  //Clock generation
  initial clk = 0;
  always #10 clk = ~clk;

  //BCD Generator: each digit 0–9
  function [11:0] generate_valid_bcd;
    reg [3:0] d0, d1, d2;
    begin
      d0 = $urandom_range(0, 9);
      d1 = $urandom_range(0,9);
      d2 = $urandom_range(0,9);
      generate_valid_bcd = {d2, d1, d0};
    end
  endfunction

  //Main Test Process
  initial begin
    $display("Starting Simulation\n");
    errors_ripple = 0;
    errors_cla = 0;

    rst = 1; cin = 0; A = 0; B = 0;
    #25; rst = 0;

    for (i = 0; i < 20; i = i + 1) begin
      A = generate_valid_bcd();
      B = generate_valid_bcd();
      cin = $urandom_range(0, 1);

      @(posedge clk);
      #30;

      //Check Ripple adder
      if (Sum_Ripple !== Sum_Expected || Cout_Ripple !== Cout_Expected) begin
        $display("Ripple Error @ Test %0d", i+1);
        $display("    A     = %0d%0d%0d",A[11:8], A[7:4], A[3:0]);
        $display("    B     = %0d%0d%0d",B[11:8], B[7:4], B[3:0]);
        $display("    Cin   = %b", cin);
        $display("    Ripple: Sum = %0d, Cout = %b", Sum_Ripple, Cout_Ripple);
        $display("    Expect: Sum = %0d, Cout = %b\n", Sum_Expected, Cout_Expected);
        errors_ripple = errors_ripple + 1;
      end  
	  
	else begin
		$display("Ripple Passed: A=%0d%0d%0d B=%0d%0d%0d Cin=%b ==> Sum=%0d%0d%0d Cout=%b",
          A[11:8], A[7:4], A[3:0], B[11:8], B[7:4], B[3:0], cin, Sum_Ripple[11:8], Sum_Ripple[7:4], Sum_Ripple[3:0],  Cout_Ripple);
      end

      //CLA test
      if (Sum_Cla !== Sum_Expected || Cout_Cla !== Cout_Expected) begin
        $display("CLA Error @ Test %0d", i+1);
        $display("    A     = %0d", A);
        $display("    B     = %0d", B);
        $display("    Cin   = %b", cin);
        $display("    CLA   : Sum = %0d, Cout = %b", Sum_Cla, Cout_Cla);
        $display("    Expect: Sum = %0d, Cout = %b\n", Sum_Expected, Cout_Expected);
        errors_cla = errors_cla + 1;
      end 
	else begin
        $display("CLA Passed: A=%0d%0d%0d B=%0d%0d%0d Cin=%b ==> Sum=%0d%0d%0d Cout=%b",
		A[11:8], A[7:4], A[3:0], B[11:8], B[7:4], B[3:0], cin, Sum_Cla[11:8], Sum_Cla[7:4], Sum_Cla[3:0], Cout_Cla);
		$display("Expected output: A=%0d%0d%0d B=%0d%0d%0d Cin=%b ==> Sum=%0d%0d%0d Cout=%b\n",
          A[11:8], A[7:4], A[3:0], B[11:8], B[7:4], B[3:0], cin, Sum_Expected[11:8], Sum_Expected[7:4], Sum_Expected[3:0], Cout_Expected);
      end
    end

    $display("\nTEST COMPLETE");
    $display("Ripple Errors: %0d", errors_ripple);
    $display("CLA Errors   : %0d", errors_cla);
    $finish;
  end
endmodule