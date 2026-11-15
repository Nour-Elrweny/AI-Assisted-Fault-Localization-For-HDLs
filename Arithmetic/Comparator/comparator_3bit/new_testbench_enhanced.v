`timescale 1ns / 1ps

module testbench;

// === Global Sync Signal ===
reg llm_go_signal = 1;


  reg [2:0] A;          // Input A (3 bits)
  reg [2:0] B;          // Input B (3 bits)
  wire A_greater;       
  wire A_equal;         
  wire A_less;          
  integer i;            
  integer error = 0;    

  comparator_3bit uut (
    .A(A),
    .B(B),
    .A_greater(A_greater),
    .A_equal(A_equal),
    .A_less(A_less)
  );


  initial begin

    for (i = 0; i < 100; i = i + 1) begin
      // Generate random 3-bit inputs
      A = $random % 8;
      B = $random % 8;

      // Wait for the operation to complete
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

      #10;

      // Calculate expected results
      if ((A > B && !A_greater) || (A == B && !A_equal) || (A < B && !A_less)) begin
        error = error + 1;
        $display("Test failed: A = %b, B = %b, A_greater = %b, A_equal = %b, A_less = %b",
                  A, B, A_greater, A_equal, A_less);
      end
    end

    // Final test result summary
    if (error == 0) begin
      $display("=========== Your Design Passed ===========");
    end
    else begin
      $display("=========== Test completed with %d /100 failures ===========", error);
    end

    $finish;
  end





        ///////////////////added
        integer file_mantra;
        initial begin
          file_mantra = $fopen("output.txt");//added
          $fwrite(file_mantra, "time, ");
      $fwrite(file_mantra, "A_greater,");
      $fwrite(file_mantra, "A_equal,");
      $fwrite(file_mantra, "A_less,");

          $fwrite(file_mantra, "\n");//added
          forever begin
            #1
            $fwrite(file_mantra, "%0d, ", $time);
        $fwrite(file_mantra, "%h, ", A_greater);
        $fwrite(file_mantra, "%h, ", A_equal);
        $fwrite(file_mantra, "%h, ", A_less);

            $fwrite(file_mantra, "\n");
          end
        end
        




// ============================================
// === LLM Enhanced Stimuli (Phase 1) ===
initial begin
    // [Auto-Moved Vars]
        integer i_idx;
        integer j_idx;

    // 1. DECLARE VARIABLES FIRST (Top of block)



    // 2. Stimuli Logic
    // Note: llm_go_signal is initially 1. We run immediately.
    $display("LLM_TEST: Starting deterministic test sequence...");

    // Strategy: Exhaustive testing for 3-bit comparator (8x8 = 64 states)
    // Since the state space is small, exhaustive testing guarantees 
    // killing all logic, operator, and bit-level mutations.
    for (i_idx = 0; i_idx < 8; i_idx = i_idx + 1) begin
        for (j_idx = 0; j_idx < 8; j_idx = j_idx + 1) begin
            A = i_idx;
            B = j_idx;
            #10;
        end
    end

    // 3. Specific Corner Cases & Transitions
    // Target: Maximize signal toggling (0->1 transitions)
    
    // Transition: All Zeros -> All Ones
    A = 3'b000; B = 3'b000; #10;
    A = 3'b111; B = 3'b111; #10;

    // Transition: Alternating Bits (0x2 vs 0x5)
    A = 3'b010; B = 3'b101; #10;
    A = 3'b101; B = 3'b010; #10;

    // Target: Boundary Values (Min vs Max)
    A = 3'b000; B = 3'b111; #10; // 0 < 7
    A = 3'b111; B = 3'b000; #10; // 7 > 0

    // Target: Bit-Select/Pointer Faults (Walking 1s)
    // Ensure each bit of A independently affects the output against B=0
    A = 3'b001; B = 3'b000; #10;
    A = 3'b010; B = 3'b000; #10;
    A = 3'b100; B = 3'b000; #10;

    // Ensure each bit of B independently affects the output against A=0
    A = 3'b000; B = 3'b001; #10;
    A = 3'b000; B = 3'b010; #10;
    A = 3'b000; B = 3'b100; #10;

    // 4. Handover
    $display("LLM_TEST: Sequence completed. Handing over to original TB.");
    llm_go_signal = 0;
end
// ============================================


// === Global Watchdog ===

// === Global Safety Watchdog (Injected) ===
initial begin
    #200000;
    $display("\n[Watchdog] Timeout triggered at %t!", $time);
    if (file_mantra != 0) $fclose(file_mantra);
    $finish;
end

endmodule