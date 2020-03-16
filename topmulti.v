`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:36:25 03/16/2020 
// Design Name: 
// Module Name:    topmulti 
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
module topmulti(input         clk, reset, 
                output [31:0] writedata, adr, 
                output        memwrite);

  wire [31:0] readdata;
  
  // instantiate processor and memory
  mips mips(clk, reset, adr, writedata, memwrite, readdata);
  mem mem(clk, memwrite, adr, writedata, readdata);

endmodule

