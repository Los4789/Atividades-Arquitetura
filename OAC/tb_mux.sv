`timescale 1ns/1ps

module tb_mux;
  logic [31:0] a, b, c, d;
  logic Sel1, Sel2;
  logic [31:0] f;
  logic [2:0] count;

  mux dut (.f(f), .a(a), .b(b), .c(c), .d(d), .Sel1(Sel1), .Sel2(Sel2) );

  logic [1:0] SelAll;
  assign {Sel2, Sel1} = SelAll;

  initial begin
    //Valores fáceis de ver em hexadecimal
    a = 32'hAAAA_AAAA;
    b = 32'hBBBB_BBBB;
    c = 32'hCCCC_CCCC;
    d = 32'hDDDD_DDDD;

    $display(" Tempo | Sel2 Sel1 |       Saida f (Hexadecimal)");
    $monitor("%4t ns |   %b    %b   | 0x%h", $time, Sel2, Sel1, f);

    for (count = 0; count < 4; count++) begin
      SelAll = count[1:0]; // Atribui os 2 bits menos significativos de count
      #10;
    end

    $display("\n");
    $stop;
  end

endmodule: tb_mux