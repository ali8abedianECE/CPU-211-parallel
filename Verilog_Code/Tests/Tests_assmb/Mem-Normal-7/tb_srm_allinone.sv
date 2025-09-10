
`timescale 1ns/1ns

`ifndef DUT_MODULE
  `define DUT_MODULE lab7bonus_top
`endif

`ifndef MEM_ARRAY_PATH
  `define MEM_ARRAY_PATH tb_all.DUT.MEM.mem
`endif

module tb_all;
  logic        CLOCK_50 = 0;
  logic [3:0]  KEY = 4'b1111;
  logic [9:0]  SW  = 10'd0;
  wire  [9:0]  LEDR;

  `DUT_MODULE DUT(
    .CLOCK_50 (CLOCK_50),
    .KEY      (KEY),
    .SW       (SW),
    .LEDR     (LEDR)
  );

  // 50 MHz
  always #10 CLOCK_50 = ~CLOCK_50;

  // Config (can be overridden with +FIRST= +LAST= +SWVAL= +MAXCYCLES=)
  int unsigned FIRST = 0;
  int unsigned LAST  = 23;
  int unsigned MAXCYCLES = 200_000;
  int unsigned swval = 0;

  // Book-keeping
  int pass_count = 0;
  int fail_count = 0;

  task automatic hard_reset();
    KEY[1] = 1'b0;
    repeat (5) @(negedge CLOCK_50);
    KEY[1] = 1'b1;
  endtask

  task automatic load_program(string fname);
    $display("[ALL] Loading %s", fname);
    $readmemb(fname, `MEM_ARRAY_PATH);
  endtask

  function automatic bit wait_for_halt(output int unsigned cycles);
    bit halted = 0;
    cycles = 0;
    do begin
      @(negedge CLOCK_50);
      cycles++;
      halted = (LEDR[8] === 1'b1);
      if (cycles == MAXCYCLES) return 0;
    end while (!halted);
    return 1;
  endfunction

  task automatic check_pc_stable(int hold_cycles = 6);
    logic [15:0] pc0, pc1;
    pc0 = DUT.CPU.PC;
    repeat (hold_cycles) begin
      @(negedge CLOCK_50);
      pc1 = DUT.CPU.PC;
      if (pc1 !== pc0) begin
        $error("[ALL] PC moved while HALTed: %h -> %h", pc0, pc1);
      end
    end
  endtask

  initial begin
    string fname;
    int unsigned cycles;

    void'($value$plusargs("FIRST=%d", FIRST));
    void'($value$plusargs("LAST=%d",  LAST));
    void'($value$plusargs("SWVAL=%d", swval));
    void'($value$plusargs("MAXCYCLES=%d", MAXCYCLES));

    SW = swval[9:0];

    $display("[ALL] Range FIRST=%0d LAST=%0d  SWVAL=%0d  MAXCYCLES=%0d", FIRST, LAST, swval, MAXCYCLES);

    for (int i = FIRST; i <= LAST; i++) begin
      fname = $sformatf("data%0d.txt", i);

      int fh = $fopen(fname, "r");
      if (fh == 0) begin
        $display("[ALL] SKIP %s (not found)", fname);
        continue;
      end
      $fclose(fh);

      load_program(fname);

      hard_reset();

      if (!wait_for_halt(cycles)) begin
        $display("[ALL][FAIL] %s : TIMEOUT (>%0d cycles) without HALT", fname, MAXCYCLES);
        fail_count++;
        continue;
      end

      if (LEDR[8] !== 1'b1) begin
        $display("[ALL][FAIL] %s : HALT LEDR[8] not asserted at halt", fname);
        fail_count++;
        continue;
      end

      check_pc_stable();

      hard_reset();
      repeat (2) @(negedge CLOCK_50);
      if (LEDR[8] !== 1'b0) begin
        $display("[ALL][FAIL] %s : HALT LEDR[8] did not clear after reset", fname);
        fail_count++;
        continue;
      end

      $display("[ALL][PASS] %s : cycles=%0d", fname, cycles);
      pass_count++;
    end

    $display("[ALL] SUMMARY: PASS=%0d  FAIL=%0d", pass_count, fail_count);
    if (fail_count == 0) $display("[ALL] OK");
    $finish;
  end
endmodule
