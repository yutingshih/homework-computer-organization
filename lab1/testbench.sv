// Copyright (c) 2020 Sonal Pinto
// SPDX-License-Identifier: Apache-2.0


module tb_core_ut;

/*
For this test suite, the memory is limited to 4KB (1024 words)
The results will be stored in the .data section starting at 960 (0x3C0, word 240)
*/

import kronos_types::*;
import rv32_assembler::*;

logic clk;
logic rstz;
logic [31:0] instr_addr;
logic [31:0] instr_data;
logic instr_req;
logic instr_ack;
logic [31:0] data_addr;
logic [31:0] data_rd_data;
logic [31:0] data_wr_data;
logic [3:0] data_mask;
logic data_wr_en;
logic data_req;
logic data_ack;

logic run;

kronos_core #(
  .FAST_BRANCH   (1)
) u_dut (
  .clk               (clk            ),
  .rstz              (rstz           ),
  .instr_addr        (instr_addr     ),
  .instr_data        (instr_data     ),
  .instr_req         (instr_req      ),
  .instr_ack         (instr_ack & run),
  .data_addr         (data_addr      ),
  .data_rd_data      (data_rd_data   ),
  .data_wr_data      (data_wr_data   ),
  .data_mask         (data_mask      ),
  .data_wr_en        (data_wr_en     ),
  .data_req          (data_req       ),
  .data_ack          (data_ack       ),
  .software_interrupt(1'b0           ),
  .timer_interrupt   (1'b0           ),
  .external_interrupt(1'b0           )
);

`define REG u_dut.u_if.u_rf.REG

logic [31:0] mem_addr;
logic [31:0] mem_wdata;
logic [31:0] mem_rdata;
logic mem_en, mem_wren;
logic [3:0] mem_mask;

spsram32_model #(.WORDS(4096)) u_mem (
  .clk  (~clk     ),
  .addr (mem_addr ),
  .wdata(mem_wdata),
  .rdata(mem_rdata),
  .en   (mem_en   ),
  .wr_en(mem_wren ),
  .mask (mem_mask )
);

// Data has Priority
always_comb begin
  mem_en = instr_req || data_req;
  mem_wren = data_wr_en;

  mem_addr = 0;
  mem_addr = data_req ? data_addr : instr_addr;

  instr_data = mem_rdata;
  data_rd_data = mem_rdata;

  mem_wdata = data_wr_data;
  mem_mask = data_req ? data_mask : 4'hF;
end

always_ff @(posedge clk) begin
  instr_ack <= instr_req & ~data_req & run;
  data_ack <= data_req;
end

default clocking cb @(posedge clk);
  default input #10ps output #10ps;
  input instr_req, instr_addr, instr_ack;
  output negedge run;
endclocking

// ============================================================

initial begin

    clk = 0;
    rstz = 0;

    run = 0;

    fork 
      forever #1ns clk = ~clk;
    join_none

    ##4 rstz = 1;
    run = 1;
end
initial begin
    logic [31:0] PROGRAM [$];
    instr_t instr;
    int index, addr;
    int data;
    int n;
    int r_exp, r_got;

    // Bootloader -------------------------
    // Load text
    $readmemh("add.mem", u_mem.MEM);
    
    // ABI --------------------------------
    `REG[x0] = 0;
    // Setup Return Address (ra/x1)
    `REG[x1] = 944;

    // Store while(1); at 944
    // 944 = 0x3B0, word 236
    u_mem.MEM[944>>2] = rv32_jal(x0, 0); // j 1b

    // Setup Frame Pointer (s0/x8)
    `REG[x8] = 0;

    // Setup Stack Pointer (sp/x2) to the end of the memory (4KB), 0x1000
    `REG[x2] = 4096;

    // Setup Function Argument - "n" - at a0 (x10)
    /*n = $urandom_range(1,31);
    $display("\n\nARG: n = %0d", n);
    `REG[x10] = n;*/

    // Run
    $display("\n\nEXEC\n\n");
    fork 
      begin
        @(cb) cb.run <= 1;
      end

      forever @(cb) begin
        if (instr_req && instr_ack) begin
          addr = cb.instr_addr;
          instr = u_mem.MEM[addr>>2];
          //$display("[%0d] ADDR=%0d, INSTR=%h", index, addr, instr);
          if (instr == 32871) begin
            $display("a2=%0d, a3=%0d",`REG[x12],`REG[x13]);
          end
          index++;
          if (addr == 944) begin
            cb.run <= 0;
            $display("a2=%0d, a3=%0d",`REG[x12],`REG[x13]);
            break;
          end
        end
      end
    join
    $display("\n\n");

    //-------------------------------
    // check
    //r_exp = 2**10;
    //r_got = u_mem.MEM[960>>2];
    //$display("RESULT: %d vs %d", r_exp, r_got);
    //assert(r_exp == r_got);

    ##64;
    $stop;
end

endmodule