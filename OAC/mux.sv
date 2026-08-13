module mux
  (
    output logic [31:0] f,
    input  logic [31:0] a, b, c, d,
    input  logic Sel1, Sel2
  ); 
  
  wire [1:0] sel = {Sel2, Sel1};
  
  assign f = (sel == 2'b00) ? a :
             (sel == 2'b01) ? b :
             (sel == 2'b10) ? c : d;

endmodule