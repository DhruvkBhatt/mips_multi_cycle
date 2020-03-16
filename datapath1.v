`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:37:35 03/16/2020 
// Design Name: 
// Module Name:    datapath1 
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
module datapath1(input         clk, reset,
                input         pcen, irwrite, regwrite,
                input         alusrca, iord, memtoreg, regdst,
                input  [1:0]  alusrcb,
					 input  [1:0]  pcsrc, 
                input  [2:0]  alucontrol,
                output [5:0]  op, funct,
                output        zero,
                output [31:0] adr, writedata, 
                input  [31:0] readdata);

  // Internal signals of the datapath module

  wire [4:0]  writereg;
  wire [31:0] pcnext, pc;
  wire [31:0] instr, data, srca, srcb;
  wire [31:0] a;
  wire [31:0] aluresult, aluout;
  wire [31:0] signimm;   // the sign-extended immediate
  wire [31:0] signimmsh;	// the sign-extended immediate shifted left by 2
  wire [31:0] wd3, rd1, rd2;

  // op and funct fields to controller
  assign op = instr[31:26];
  assign funct = instr[5:0];

  // datapath
  and a1(pcen1,reset,pcen);
  and a2(irwrite1,reset,irwrite);
  StateReg_32_bit_1 pcreg(clk, reset, pcen, pcnext, pc);

  mux2to1_32bits    adrmux(pc>>2, aluout, iord, adr);
  StateReg_32_bit_1 instrreg(clk, reset, irwrite, readdata, instr);
  StateReg_32_bit datareg(clk, reset, readdata, data); 

  mux2to1_5bits  regdstmux(instr[20:16], instr[15:11], regdst, writereg);
  mux2to1_32bits wdmux(aluout, data, memtoreg, wd3);
  regfile1       rf(clk, regwrite, instr[25:21], instr[20:16], 
                   writereg, wd3, rd1, rd2);
  signExt16to32       se(instr[15:0], signimm);
  sl2           immsh(signimm, signimmsh);
  StateReg_32_bit areg(clk, reset, rd1, a);
  StateReg_32_bit breg(clk, reset, rd2, writedata);
  mux2to1_32bits srcamux(pc, a, alusrca, srca);
  mux4to1_32bits srcbmux(writedata, 32'b100, signimm, signimmsh,
                        alusrcb, srcb);
  alu           alu(srca, srcb, alucontrol,
                    aluresult, zero);
  StateReg_32_bit alureg(clk, reset, aluresult, aluout);
  //assign aluresult1=aluresult>>2;
  //assign aluout1=aluout>>2;
  mux4to1_32bits pcmux(aluresult, aluout, 
                      {pc[31:28], instr[25:0],2'b00},32'd0, pcsrc, pcnext);
  //assign pcnext=pcnext<<2;
  
endmodule


