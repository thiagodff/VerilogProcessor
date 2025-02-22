module proc (mem, DIN, Resetn, Clock, Run, Done, BusWires, addr, save);
	input [15:0] DIN;
	input [15:0] mem;
	input Resetn, Clock, Run;
	output reg Done, save;
	output wire [15:0] BusWires;
	output reg [15:0] addr;
	wire [9:0] IR;
	reg IRin;
	reg [2:0]ControlULA;
	wire [3:0] I;
	wire [7:0] Xreg, Yreg;
	wire [1:0] Tstep_Q;

	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G, Gout;
	reg [7:0] Rin;
	reg Ain, Gin, Lin;
	reg [9:0] Control;
	
	initial
	begin
		Done = 1'b0;
	end
	
	addsub ula(ControlULA, A, BusWires, G);

	regn mR0(BusWires, Rin[7], Clock, R0);
	regn mR1(BusWires, Rin[6], Clock, R1);
	regn mR2(BusWires, Rin[5], Clock, R2);
	regn mR3(BusWires, Rin[4], Clock, R3);
	regn mR4(BusWires, Rin[3], Clock, R4);
	regn mR5(BusWires, Rin[2], Clock, R5);
	regn mR6(BusWires, Rin[1], Clock, R6);
	regn mR7(BusWires, Rin[0], Clock, R7);
	regn mG(G, Gin, Clock, Gout);
	regn mA(BusWires, Ain, Clock, A);
	regn ADDR(BusWires, Lin, Clock, addr);

	IRn mIR(DIN[9:0], IRin, Clock, IR); // Each instruction can be encoded and stored in the IR

	mux Multiplexers(Control, DIN, R0, R1, R2, R3, R4, R5, R6, R7 , Gout, BusWires);

	wire Clear = ~Resetn | Done;
	upcount Tstep (Clear, Clock, Tstep_Q);
	assign I = IR[3:0];
	dec3to8 decX (IR[6:4], 1'b1, Xreg);
	dec3to8 decY (IR[9:7], 1'b1, Yreg);
	
	always @(Tstep_Q or I or Xreg or Yreg)
	begin
		if (Run == 1)
		begin
			Done = 1'b0;
			Control = 10'b0000000000;
			Rin= 8'b00000000;
			IRin= 1'b0;
			Gin = 1'b0;
			Ain = 1'b0;
			case (Tstep_Q)
				2'b00: // store DIN in IR in time step 0
				begin
					IRin = 1'b1;
				end
				2'b01: //define signals in time step 1
				begin
					case (I)
						4'b0000: //mv
						begin
							Control = {Yreg, 3'b000}; //mux libera o valor em Y
							Rin = Xreg; //X ativa a escrita
							Done = 1'b1; //finalizado
						end
						4'b0001: //mvi
						begin
							Control= {8'b0, 3'b010}; //mux libera a proxima entrada
							IRin= 1'b0;	//o próximo valor não é uma instrução
						end
						4'b0010: //add
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b000; //ula vai fazer soma
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b0011: //sub
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b001; //ula vai fazer subtracao
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b0100: //and
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b010; //ula vai fazer and bit a bit
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b0101: //slt
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b011; //ula vai comparar X<Y
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b0110: //sll
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b100; //ula vai dar shift X<<Y
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b0111: //srl
						begin
							Control = {Xreg, 3'b000}; //salva X no registrador A
							ControlULA = 3'b101; //ula vai dar shift X>>Y
							Ain = 1'b1; //registrador A ativa escrita
						end
						4'b1000: //ld
						begin
						  Control = {Yreg, 3'b000};
						  Lin = 1'b1;
						end
					endcase
				end
				2'b10: //define signals in time step 2
				case (I)
					4'b0000: //mv
					begin

					end
					4'b0001: //mvi
					begin
						Rin = Xreg; //X ativa a escrita
						Done = 1'b1; //finalizado
					end
					4'b0010: //add
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da vai ser salvo
					end
					4'b0011: //sub
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da ULA vai ser salvo
					end
					4'b0100: //and
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da ULA vai ser salvo
					end
					4'b0101: //slt
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da ULA vai ser salvo
					end
					4'b0110: //sll
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da ULA vai ser salvo
					end
					4'b0111: //srl
					begin
						Control = {Yreg, 3'b000}; //mux libera Y para a ULA
						Gin = 1'b1; //resultado da ULA vai ser salvo
					end
					4'b1000: //ld
					begin
					  //stall
					end
				endcase
				2'b11: //define signals in time step 3
				case (I)
					4'b0010: //add
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg; //ativa escrita em X
						Done= 1'b1;
					end
					4'b0011: //sub
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg;  //ativa escrita em X
						Done= 1'b1;
					end
					4'b0100: //and
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg;  //ativa escrita em X
						Done= 1'b1;
					end
					4'b0101: //slt
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg;  //ativa escrita em X
						Done= 1'b1;
					end
					4'b0110: //sll
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg;  //ativa escrita em X
						Done= 1'b1;
					end
					4'b0111: //srl
					begin
						Control = 10'b00000000100; //mux libera G
						Rin = Xreg;  //ativa escrita em X
						Done= 1'b1;
					end
					4'b1000: //ld
					begin
					  Control = 11'b00000000001;
					  Rin = Xreg;
					end
				endcase
			endcase
		end
	end
	//regn reg_0 (BusWires, Rin[0], Clock, R0);
	//... instantiate other registers and the adder/subtracter unit
	//... define the bus
endmodule