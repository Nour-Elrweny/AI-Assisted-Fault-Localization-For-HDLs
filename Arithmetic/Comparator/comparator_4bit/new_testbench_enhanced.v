`timescale 1ns / 1ps

module testbench;

// === Global Sync Signal ===
reg llm_go_signal = 1;


  reg [3:0] A;          // Input A (4 bits)
  reg [3:0] B;          // Input B (4 bits)
  wire A_greater;       
  wire A_equal;         
  wire A_less;          
  integer i;            
  integer error = 0;    

  comparator_4bit uut (
    .A(A),
    .B(B),
    .A_greater(A_greater),
    .A_equal(A_equal),
    .A_less(A_less)
  );


  initial begin

    for (i = 0; i < 100; i = i + 1) begin
      // Generate random 4-bit inputs
      A = $random % 16;
      B = $random % 16;

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
        integer k;

    // 1. DECLARE VARIABLES FIRST (Top of block)


    // 2. THEN WAIT for original tests
    wait(llm_go_signal == 1);

    $display("LLM_TEST: Starting deterministic mutation tests...");

    // 3. THEN execute logic
    
    // --- Equality Checks (Targeting A_equal) ---
    // Test 0: Zeros (Boundary Min)
    A = 4'h0; B = 4'h0; #10;
    // Test 1: Max Values (Boundary Max)
    A = 4'hF; B = 4'hF; #10;
    // Test 2: Alternating Pattern 1 (Bit-level independence)
    A = 4'hA; B = 4'hA; #10;
    // Test 3: Alternating Pattern 2
    A = 4'h5; B = 4'h5; #10;

    // --- Greater Than Checks (Targeting A_greater) ---
    // Test 4: Min + 1 > Min (Boundary)
    A = 4'h1; B = 4'h0; #10;
    // Test 5: Max > Max - 1 (Boundary)
    A = 4'hF; B = 4'hE; #10;
    // Test 6: Max > Min (Extreme)
    A = 4'hF; B = 4'h0; #10;
    // Test 7: Mid Range Transition
    A = 4'h8; B = 4'h7; #10;

    // --- Less Than Checks (Targeting A_less / Borrow Logic) ---
    // Test 8: Min < Min + 1 (Boundary)
    A = 4'h0; B = 4'h1; #10;
    // Test 9: Max - 1 < Max (Boundary)
    A = 4'hE; B = 4'hF; #10;
    // Test 10: Min < Max (Extreme)
    A = 4'h0; B = 4'hF; #10;
    // Test 11: Mid Range Transition
    A = 4'h7; B = 4'h8; #10;

    // --- Bit-Level & Walking 1s (Targeting Stuck-at & Coupling) ---
    // Walking 1s on A, B=0
    A = 4'h1; B = 4'h0; #10;
    A = 4'h2; B = 4'h0; #10;
    A = 4'h4; B = 4'h0; #10;
    A = 4'h8; B = 4'h0; #10;

    // Walking 1s on B, A=15 (Targeting Subtraction/Borrow Logic)
    // 15 - 1 = 14 (No Borrow)
    A = 4'hF; B = 4'h1; #10;
    // 15 - 2 = 13
    A = 4'hF; B = 4'h2; #10;
    // 15 - 4 = 11
    A = 4'hF; B = 4'h4; #10;
    // 15 - 8 = 7
    A = 4'hF; B = 4'h8; #10;

    // --- Specific Mutation Targets ---
    // Operator Replacement (+ instead of -)
    // A=1, B=1. A-B=0 (Eq). A+B=2 (Gt).
    A = 4'h1; B = 4'h1; #10;
    
    // Bitwise Operator Replacement (& instead of -)
    // A=3 (0011), B=1 (0001). A-B=2. A&B=1.
    A = 4'h3; B = 4'h1; #10;
    
    // Borrow Logic Stress (Ripple Carry)
    // A=8 (1000), B=1 (0001) -> 7 (0111). Ripples 3 bits.
    A = 4'h8; B = 4'h1; #10;
    
    // Underflow Check
    // A=0, B=1 -> Underflow (Borrow=1, Diff=1111)
    A = 4'h0; B = 4'h1; #10;

    // 4. Handover
    $display("LLM_TEST: Tests Finished. Handing over to Original TB...");
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