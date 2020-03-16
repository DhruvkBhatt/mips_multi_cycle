`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:36:49 03/16/2020 
// Design Name: 
// Module Name:    mips 
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
module mips(input         clk, reset,
            output [31:0] adr, writedata,
            output        memwrite,
            input  [31:0] readdata);

  wire        zero, pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst;
  wire [1:0]  alusrcb;
  wire [1:0]  pcsrc;
  wire [2:0]  alucontrol;
  wire [5:0]  op, funct;

  // The control unit receives the current instruction from the datapath and tells the
  // datapath how to execute that instruction.
  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol);

  // The datapath operates on words of data. It
  // contains structures such as memories, registers, ALUs, and multiplexers.
  // MIPS is a 32-bit architecture, so we will use a 32-bit datapath. 
  datapath1 dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata);
endmodule

// The main controller produces multiplexer select and register enable
// signals for the datapath. The select signals are MemtoReg, RegDst,
// IorD, PCSrc, ALUSrcB, and ALUSrcA. The enable signals are IRWrite,
// MemWrite, PCWrite, Branch, and RegWrite.
module controller(input        clk, reset,
                  input  [5:0] op, funct,
                  input        zero,
                  output       pcen, memwrite, irwrite, regwrite,
                  output       alusrca, iord, memtoreg, regdst,
                  output [1:0] alusrcb,
						output [1:0] pcsrc,
                  output [2:0] alucontrol);

  wire [1:0] aluop;
  wire       branch, pcwrite;

  // Main Decoder and ALU Decoder subunits.
  maindec md(clk, reset, op,
             pcwrite, memwrite, irwrite, regwrite,
             alusrca, branch, iord, memtoreg, regdst, 
             alusrcb, pcsrc, aluop);
  aludec  ad(funct, aluop, alucontrol);

  assign pcen = pcwrite | (branch & zero);

endmodule

// The controller receives the current instruction from the datapath
// and tell the datapath how to execute that instruction.
module maindec(input        clk, reset, 
               input  [5:0] op, 
               output       pcwrite, memwrite, irwrite, regwrite,
               output       alusrca, branch, iord, memtoreg, regdst,
               output [1:0] alusrcb, 
					output [1:0] pcsrc,   
               output [1:0] aluop); 

  // FSM States
  parameter   FETCH   			= 5'b00000; // State 0
  parameter   DECODE  			= 5'b00001; // State 1
  parameter   MEMADR  			= 5'b00010;	// State 2
  parameter   MEMRD   			= 5'b00011;	// State 3
  parameter   MEMWB   			= 5'b00100;	// State 4
  parameter   MEMWR   			= 5'b00101;	// State 5
  parameter   EXECUTE 			= 5'b00110;	// State 6
  parameter   ALUWRITEBACK 	= 5'b00111;	// State 7
  parameter   BRANCH   			= 5'b01000;	// State 8
  parameter   ADDIEXECUTE		= 5'b01001;	// State 9
  parameter   ADDIWRITEBACK	= 5'b01010;	// state a
  parameter   JUMP    			= 5'b01011;	// State b

  // MIPS Instruction Opcodes
  parameter   LW      = 6'b100011;	// load word lw
  parameter   SW      = 6'b101011;	// store word sw
  parameter   RTYPE   = 6'b000000;	// R-type
  parameter   BEQ     = 6'b000100;	// branch if equal beq
  parameter   ADDI    = 6'b001000;	// add immidiate addi
  parameter   J       = 6'b000010;	// jump j

  reg [4:0]  state, nextstate;
  reg [16:0] controls;

  // state register
  always @(posedge clk or posedge reset)			
    if(reset) state <= FETCH;
    else state <= nextstate;

  // next state logic
  always @( * )
    case(state)
      FETCH:   nextstate <= DECODE;	// if current state is fetch then goto decode state
      DECODE:  case(op)					//if decoode then genrate the nextstate based on opcode
                 LW:      nextstate <= MEMADR;	//if Lw instruction then go to Mem Address state
                 SW:      nextstate <= MEMADR;	//if sw instruction then go to Mem Address state
                 RTYPE:   nextstate <= EXECUTE;	//if R-type instruction then execute
                 BEQ:     nextstate <= BRANCH;	//if Beq instruction then branch
                 ADDI:    nextstate <= ADDIEXECUTE;	//if Addi instruction then AddExecutable
                 J:       nextstate <= JUMP;		//if J instruction then go to jump
                 default: nextstate <= FETCH;  // if any other instruction then goto fetch should never happen
               endcase
      MEMADR:  case(op)	// if current instruction is lw or sw 
                 LW:      nextstate <= MEMRD;	//if LW instruction then go to memory read state
                 SW:      nextstate <= MEMWR;	//if SW instruction then go to memory write state
                 default: nextstate <= FETCH; // should never happen(go to featch state)
               endcase
      MEMRD:   nextstate <= MEMWB;		//if LW instruction then goto MemwR state 
      MEMWB:   nextstate <= FETCH;		//if SW instruction then goto fetch state
      MEMWR:   nextstate <= FETCH;		//if mem WB then nextinstuction fetch
      EXECUTE: nextstate <= ALUWRITEBACK;	//If Execute state of R-type then goto to Aluwriteback state
      ALUWRITEBACK: nextstate <= FETCH;	//if Aluwriteback state then go to the fetch state
      BRANCH:   nextstate <= FETCH;			//if branch then go to fetch state
      ADDIEXECUTE:  nextstate <= ADDIWRITEBACK;	//if Addi execute state then goto the Addi write back state
      ADDIWRITEBACK:  nextstate <= FETCH;	//if Addi write back state then goto fetch state 
      JUMP:    nextstate <= FETCH;	// if jump then goto the fetch state
      default: nextstate <= FETCH;  // should never happen
    endcase

  // output logic
  assign {pcwrite, memwrite, irwrite, regwrite, 
          alusrca, branch, iord, memtoreg, regdst, 
          alusrcb, pcsrc, 
			 aluop} = controls;

  always @( * )
    case(state)
      FETCH:          controls <= 19'b1010_00000_0100_00;	//Controls for fetch
      DECODE:         controls <= 19'b0000_00000_1100_00;	//Controls for decode
      MEMADR:         controls <= 19'b0000_10000_1000_00;	//Controls for memaddress
      MEMRD:          controls <= 19'b0000_00100_0000_00;	//Controls for memread
      MEMWB:          controls <= 19'b0001_00010_0000_00;	//Controls for memread data
      MEMWR:          controls <= 19'b0100_00100_0000_00;	//Controls for memwrite
      EXECUTE:        controls <= 19'b0000_10000_0000_10;	//Controls for execute state
      ALUWRITEBACK:   controls <= 19'b0001_00001_0000_00;	//Controls for alu writeback
      BRANCH:         controls <= 19'b0000_11000_0001_01;	//Controls for branch
      ADDIEXECUTE:    controls <= 19'b0000_10000_1000_00;	//Controls for addi execute
      ADDIWRITEBACK:  controls <= 19'b0001_00000_0000_00;	//Controls for alu writeback
      JUMP:           controls <= 19'b1000_00000_0010_00;   //Controls for jump
      default:        controls <= 19'b0000_xxxxx_xxxx_xx;	// should never happen
    endcase
endmodule

module aludec(input      [5:0] funct,
              input      [1:0] aluop,
              output reg [2:0] alucontrol);

    always @( * )
    case(aluop)
      3'b000: alucontrol <= 3'b010;  // alu control signal for add
      3'b001: alucontrol <= 3'b010;  // alu control signal for sub
      // RTYPE instruction use the 6-bit funct field of instruction to specify ALU operation
      3'b010: case(funct)           //based on func select the signal
          6'b100000: alucontrol <= 3'b010; // Alu control signal for ADD
          6'b100010: alucontrol <= 3'b110; // Alu control signal for SUB
          6'b100100: alucontrol <= 3'b000; // Alu control signal for AND
          6'b100101: alucontrol <= 3'b001; // Alu control signal for OR
          6'b101010: alucontrol <= 3'b111; // Alu control signal for SLT
          default:   alucontrol <= 3'bxxx; // ???
        endcase
		default: alucontrol <= 3'bxxx; // ???
    endcase
endmodule




