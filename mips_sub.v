`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:38:03 03/16/2020 
// Design Name: 
// Module Name:    mips_sub 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu(	input [31:0] A, B, 
            input [2:0] F, 
				output reg [31:0] Y, output Zero);
				
	always @ ( * )
		case (F[2:0])
			3'b000: Y <= A & B;
			3'b001: Y <= A | B;
			3'b010: Y <= A + B;
			//3'b011: Y <= 0;  // not used
			3'b011: Y <= A & ~B;
			3'b101: Y <= A + ~B;
			3'b110: Y <= A - B;
			3'b111: Y <= A < B ? 1:0;
			default: Y <= 0; //default to 0, should not happen
		endcase
	
	assign Zero = (Y == 32'b0);
endmodule


module regfile1 (
	input         clk  ,
	//reg read or write
	input         rw   ,
	//addres for rs rd and rt
	input  [ 4:0] addr1,
	input  [ 4:0] addr2,
	input  [ 4:0] addr3,
	//write data at rt value
	input  [31:0] wdata,
	//data at rs and rd
	output reg [31:0] data1,
	output reg [31:0] data2
	
		
	
);

	reg [31:0] regmem[31:0];
//	reg [31:0] data1       ;
//	reg [31:0] data2       ;

	always @(addr1 or regmem[addr1]) begin
		if (0 == addr1) begin
			data1 = 0;
		end else begin
			data1 = regmem[addr1];
		end
	end

	always @(addr2 or regmem[addr2]) begin
		if (0 == addr2) begin
			data2 = 0;
		end else begin
			data2 = regmem[addr2];
		end
	end

	always@ (posedge clk) begin
		if(1'b1 == rw) begin
			regmem[addr3] = wdata;
		end
	end

endmodule


// Left Shift (Multiply by 4)
module sl2(input  [31:0] a,
           output [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

// Sign Extension
module signExt16to32(input [15:0] in, output [31:0] signExtIn);
	
	mux2to1_32bits m1({16'h00000000,in[15:0]},{16'hffffffff,in[15:0]},in[15],signExtIn);
	
endmodule


//state registor to save intermidiate value
module StateReg_32_bit(input clk, input reset, input [31:0] inR, output [31:0] outR);
    d_flip_flop_edge_triggered d0 (clk, reset, inR[0],  outR[0]);
    d_flip_flop_edge_triggered d1 (clk, reset, inR[1],  outR[1]);
    d_flip_flop_edge_triggered d2 (clk, reset, inR[2],  outR[2]);
    d_flip_flop_edge_triggered d3 (clk, reset, inR[3],  outR[3]);
    d_flip_flop_edge_triggered d4 (clk, reset, inR[4],  outR[4]);
    d_flip_flop_edge_triggered d5 (clk, reset, inR[5],  outR[5]);
    d_flip_flop_edge_triggered d6 (clk, reset, inR[6],  outR[6]);
    d_flip_flop_edge_triggered d7 (clk, reset, inR[7],  outR[7]);
	 d_flip_flop_edge_triggered d8 (clk, reset, inR[8],  outR[8]);
	 d_flip_flop_edge_triggered d9 (clk, reset, inR[9],  outR[9]);
	 d_flip_flop_edge_triggered d10 (clk, reset, inR[10],  outR[10]);
    d_flip_flop_edge_triggered d11 (clk, reset, inR[11],  outR[11]);
    d_flip_flop_edge_triggered d12 (clk, reset, inR[12],  outR[12]);
    d_flip_flop_edge_triggered d13 (clk, reset, inR[13],  outR[13]);
    d_flip_flop_edge_triggered d14 (clk, reset, inR[14],  outR[14]);
    d_flip_flop_edge_triggered d15 (clk, reset, inR[15],  outR[15]);
    d_flip_flop_edge_triggered d16 (clk, reset, inR[16],  outR[16]);
    d_flip_flop_edge_triggered d17 (clk, reset, inR[17],  outR[17]);
	 d_flip_flop_edge_triggered d18 (clk, reset, inR[18],  outR[18]);
	 d_flip_flop_edge_triggered d19 (clk, reset, inR[19],  outR[19]);
	 d_flip_flop_edge_triggered d20 (clk, reset, inR[20],  outR[20]);
    d_flip_flop_edge_triggered d21 (clk, reset, inR[21],  outR[21]);
    d_flip_flop_edge_triggered d22 (clk, reset, inR[22],  outR[22]);
    d_flip_flop_edge_triggered d23 (clk, reset, inR[23],  outR[23]);
    d_flip_flop_edge_triggered d24 (clk, reset, inR[24],  outR[24]);
    d_flip_flop_edge_triggered d25 (clk, reset, inR[25],  outR[25]);
    d_flip_flop_edge_triggered d26 (clk, reset, inR[26],  outR[26]);
    d_flip_flop_edge_triggered d27 (clk, reset, inR[27],  outR[27]);
	 d_flip_flop_edge_triggered d28 (clk, reset, inR[28],  outR[28]);
	 d_flip_flop_edge_triggered d29 (clk, reset, inR[29],  outR[29]);
	 d_flip_flop_edge_triggered d30 (clk, reset, inR[30],  outR[30]);
    d_flip_flop_edge_triggered d31 (clk, reset, inR[31],  outR[31]);
endmodule

module d_flip_flop_edge_triggered(input C, input R, input D,output Q);//Q, Qn, C, D);
   //output Q;
   //output Qn;
   //input  C;
   //input  D;
	wire Qn;
   wire   Cn;   // Control input to the D latch.
   wire   Cnn;  // Control input to the SR latch.
   wire   DQ;   // Output from the D latch, inputs to the gated SR latch.
   wire   DQn;  // Output from the D latch, inputs to the gated SR latch.
   
   not(Cn, C);
   not(Cnn, Cn);   
   d_latch dl(DQ, DQn, Cn, D);
   sr_latch_gated sr(Q, Qn, Cnn, DQ, DQn);   
endmodule // d_flip_flop_edge_triggered

module d_latch(Q, Qn, G, D);
   output Q;
   output Qn;
   input  G;   
   input  D;

   wire   Dn; 
   wire   D1;
   wire   Dn1;

   not n1(Dn, D);   
   and a1(D1, G, D);
   and a2(Dn1, G, Dn);   
   nor n2(Qn, D1, Q);
   nor n3(Q, Dn1, Qn);
endmodule // d_latch

module sr_latch_gated(Q, Qn, G, S, R);
   output Q;
   output Qn;
   input  G;   
   input  S;
   input  R;

   wire   S1;
   wire   R1;
   
   and(S1, G, S);
   and(R1, G, R);   
   nor(Qn, S1, Q);
   nor(Q, R1, Qn);
endmodule // sr_latch_gated


// RESETTABLE ENABLED REGISTER 
module StateReg_32_bit_1(input                  clk, reset,
                 input                  en,
                 input      [31:0] d, 
                 output reg [31:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (en)    q <= d;
endmodule

