`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:39:08 03/16/2020 
// Design Name: 
// Module Name:    mem 
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
module mem(input         clk, we,
           input  [31:0] a, wd,
           output [31:0] rd);

  reg  [31:0] RAM[199:0];

  initial
    begin
      $readmemh("mipstest.s",RAM);
    end

  assign rd = RAM[a[31:0]]; // word aligned

  always @(posedge clk)
    if (we)
      RAM[a[31:0]] <= wd;
endmodule
