module addsub(Control, A, Bus, G);
	input [15:0] A, Bus;
	input [2:0]Control;
	output reg [15:0] G;
	
	always @ (*)
	begin
		case (Control)
			3'b000 : G[15:0] <= (A[15:0] + Bus[15:0]); 
			3'b001 : G <= (A[15:0] - Bus[15:0]);
			3'b010 : G <= (A[15:0] & Bus[15:0]);
			3'b011 : 
			begin
			if(A[15:0]<Bus[15:0])
				G[15:0] <= 16'b1111111111111111;
			else
				G[15:0] <= 16'b0000000000000000;
			end
			3'b100: G <= A[15:0]<<Bus[15:0];
			3'b101: G <= A[15:0]>>Bus[15:0];
		endcase
	end
endmodule