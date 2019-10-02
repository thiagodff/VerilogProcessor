module processor(SW, Clock, Done, BusWires);
	
	input [17:0]SW;// 0-15 DIN, 16 Resetn, 17 Run
	input Clock;
	output Done;
	output [15:0]BusWires;
	reg [15:0]mem[15:0];
	
	reg[15:0] addr, memData;
	reg save;
  initial
	begin
	  save = 1'b0;
		mem[3] = 16'b0000000000000100;
		addr = 16'b0000000000000000;
		memData = 16'b0000000000000000;
	end
	
	proc i9_9900k(memData[15:0], SW[15:0], SW[16], Clock, SW[17], Done, BusWires, addr, save);
  
	always @ (posedge Clock)
	begin
	  if (save) // (save == 0) ? LD:SD
		  memData <= mem[addr];
		else
		  mem[addr] = BusWires;
	end
	
endmodule
