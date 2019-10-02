module mux(Control, MEM, DIN, R0, R1, R2, R3, R4, R5, R6, R7 , G, BusWires);
	input [15:0] DIN, MEM;
	input [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	input [15:0]G;
	output reg [15:0]BusWires;

	input [10:0]Control; //0-7> R-out, 8> G-out, 9> DIN-out 

	always @ (Control or DIN)
	begin
		case (Control)
		  11'b00000000001: BusWires <= MEM;
		  11'b00000000010: BusWires <= DIN;
      11'b00000000100: BusWires <= G;
      11'b00000001000: BusWires <= R7;
      11'b00000010000: BusWires <= R6;
      11'b00000100000: BusWires <= R5;
      11'b00001000000: BusWires <= R4;
      11'b00010000000: BusWires <= R3;
      11'b00100000000: BusWires <= R2;
      11'b01000000000: BusWires <= R1;
      11'b10000000000: BusWires <= R0;
		endcase
	end
endmodule