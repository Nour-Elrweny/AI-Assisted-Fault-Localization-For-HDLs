`timescale 1ns/1ps
module tb_division();

// === Global Sync Signal ===
reg llm_go_signal = 1;


reg [15:0] A;
reg [7:0] B;
wire [15:0] result;
wire [15:0] odd;

integer i; 
integer error = 0; 
reg [15:0] expected_result;
reg [15:0] expected_odd;
initial begin
   for (i = 0; i < 100; i = i + 1) begin
      A = $urandom_range(1'b0, 16'b1111_1111_1111_1111);
      B = $urandom_range(1'b1, 8'b1111_1111);
      expected_result = A/B;
      expected_odd = A%B;
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

      #10; 
      error = (expected_odd != odd || expected_result != result) ? error+1 : error;
      // $display("A = %d, B = %d, Result = %d, odd = %d", A, B, result, odd);
   end
   
   if (error == 0) begin
            $display("===========Your Design Passed===========");
    end
    else begin
    $display("===========Test completed with %d /100 failures===========", error);
    end
    
    $finish;
end

div_16bit uut (.A(A), .B(B), .result(result), .odd(odd));





        ///////////////////added
        integer file_mantra;
        initial begin
          file_mantra = $fopen("output.txt");//added
          $fwrite(file_mantra, "time, ");
      $fwrite(file_mantra, "result,");
      $fwrite(file_mantra, "odd,");

          $fwrite(file_mantra, "\n");//added
          forever begin
            #1
            $fwrite(file_mantra, "%0d, ", $time);
        $fwrite(file_mantra, "%h, ", result);
        $fwrite(file_mantra, "%h, ", odd);

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

    // 3. THEN execute logic
    $display("Starting LLM Deterministic Tests...");

    // --- Basic Sanity Checks ---
    // Simple division: 100 / 10 = 10, rem 0
    A = 16'd100; B = 8'd10; #10;
    
    // Remainder check: 100 / 30 = 3, rem 10
    A = 16'd100; B = 8'd30; #10;
    
    // --- Boundary Values (Min/Max) ---
    // Max A, Max B: 65535 / 255 = 257, rem 0
    A = 16'hFFFF; B = 8'hFF; #10;
    
    // Max A, Min B: 65535 / 1 = 65535, rem 0
    A = 16'hFFFF; B = 8'h01; #10;
    
    // Min A, Max B: 0 / 255 = 0, rem 0
    A = 16'h0000; B = 8'hFF; #10;
    
    // Min A, Min B: 0 / 1 = 0, rem 0
    A = 16'h0000; B = 8'h01; #10;

    // --- Bit Patterns (Entropy & Coupling) ---
    // Alternating patterns to catch bit-coupling faults
    A = 16'hAAAA; B = 8'h55; #10;
    A = 16'h5555; B = 8'hAA; #10;
    
    // All ones vs Alternating
    A = 16'hFFFF; B = 8'hAA; #10;
    
    // --- Power of 2 Divisors (Shift Logic Stress) ---
    // These target mutations where shifts are replaced or offsets are wrong
    A = 16'd4096; B = 8'd2; #10;
    A = 16'd4096; B = 8'd4; #10;
    A = 16'd4096; B = 8'd8; #10;
    A = 16'd4096; B = 8'd16; #10;
    A = 16'd4096; B = 8'd32; #10;
    A = 16'd4096; B = 8'd64; #10;
    A = 16'd4096; B = 8'd128; #10;

    // --- Edge Cases: A near B ---
    // A = B (Result 1, Rem 0)
    A = 16'd200; B = 8'd200; #10;
    
    // A < B (Result 0, Rem A)
    A = 16'd199; B = 8'd200; #10;
    
    // A > B (Result 1, Rem > 0)
    A = 16'd201; B = 8'd200; #10;

    // --- Walking 1s on B (Control Flow/Comparator Stress) ---
    // Ensures every bit of B contributes correctly to the subtraction logic
    A = 16'hFFFF;
    B = 8'h01; #10;
    B = 8'h02; #10;
    B = 8'h04; #10;
    B = 8'h08; #10;
    B = 8'h10; #10;
    B = 8'h20; #10;
    B = 8'h40; #10;
    B = 8'h80; #10;

    // --- Walking 0s on B (Inverse Mask) ---
    B = 8'hFE; #10;
    B = 8'hFD; #10;
    B = 8'hFB; #10;
    B = 8'hF7; #10;
    B = 8'hEF; #10;
    B = 8'hDF; #10;
    B = 8'hBF; #10;
    B = 8'h7F; #10;

    // --- Large Primes/Non-Power-of-2 (Algorithm Stress) ---
    A = 16'd54321; B = 8'd123; #10;
    A = 16'd12345; B = 8'd251; #10;

    // --- High Bit Toggle on A ---
    // Checks if MSB logic/sign extension (if any) is correct
    A = 16'h8000; B = 8'd1; #10;
    A = 16'h8000; B = 8'h80; #10;

    // 4. Cleanup
    $display("LLM Tests Finished. Handing over to Original TB...");
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