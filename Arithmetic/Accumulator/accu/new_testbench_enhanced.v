`timescale  1ns / 1ps

module tb_valid_ready;

// === Global Sync Signal ===
reg llm_go_signal = 1;



parameter PERIOD  = 10;
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [7:0]  data_in                       = 0 ;
reg   valid_in                             = 0 ;

wire  valid_out                              ;
wire  [9:0]  data_out                       ;


initial begin
    forever #(PERIOD/2)  clk=~clk;
end

initial begin
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

    #(PERIOD*2) rst_n  =  1;
end

accu  uut (
    .clk                     ( clk             ),
    .rst_n                   ( rst_n           ),
    .data_in                 ( data_in   [7:0] ),
    .valid_in                ( valid_in        ),

    .valid_out               ( valid_out       ),
    .data_out                ( data_out  [9:0] )
);

initial begin
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

    #(PERIOD*1+0.01); 
    #(PERIOD)   data_in = 8'd1;valid_in = 1;
    #(PERIOD)   data_in = 8'd2;
    #(PERIOD)   data_in = 8'd3;
    #(PERIOD)   data_in = 8'd14;

    #(PERIOD)   data_in = 8'd5;
    #(PERIOD)   data_in = 8'd2;
    #(PERIOD)   data_in = 8'd103;
    #(PERIOD)   data_in = 8'd4;

    #(PERIOD)   data_in = 8'd5;
    #(PERIOD)   data_in = 8'd6;
    #(PERIOD)   data_in = 8'd3;
    #(PERIOD)   data_in = 8'd54;
    #(PERIOD*2);
    $finish;
end

reg [9:0] result [0:2];
initial begin
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

    result[0] = 9'd20;
    result[1] = 9'd114;
    result[2] = 9'd68;
end

integer i;
integer casenum = 0;
integer error = 0;

initial begin
    wait(llm_go_signal == 0); // [Auto] Handover from LLM to Original TB

    for (i = 0; i < 15; i = i + 1) begin
        #((PERIOD) * 1);         
        if (valid_out) begin
            error = (data_out == result[casenum]) ? error : error + 1;
            casenum = casenum + 1;
        end        
    end
    if(error==0 && casenum==3)
	begin
		$display("===========Your Design Passed===========");
        end
	else
	begin
		$display("===========Error===========");
	end
    $finish;
end






        ///////////////////added
        integer file_mantra;
        initial begin
          file_mantra = $fopen("output.txt");//added
          $fwrite(file_mantra, "time, ");
      $fwrite(file_mantra, "valid_out,");
      $fwrite(file_mantra, "data_out  [9:0],");

          $fwrite(file_mantra, "\n");//added
          forever begin
            #1
            $fwrite(file_mantra, "%0d, ", $time);
        $fwrite(file_mantra, "%h, ", valid_out);
        $fwrite(file_mantra, "%h, ", data_out  [9:0]);

            $fwrite(file_mantra, "\n");
          end
        end
        




// ============================================
// === LLM Enhanced Stimuli (Phase 1) ===
initial begin
    // [Auto-Moved Vars]
        integer i;
        reg [7:0] pattern_val;

    // 1. DECLARE VARIABLES FIRST (Top of block)



    // 2. THEN WAIT for original tests
    wait(llm_go_signal == 1);

    // 3. THEN execute logic
    $display("LLM: Starting Mutation Tests...");

    // Initialize Inputs
    rst_n = 0;
    valid_in = 0;
    data_in = 8'h00;

    // Apply Reset
    repeat(5) @(posedge clk);
    rst_n = 1;
    repeat(2) @(posedge clk);

    // ---------------------------------------------------------
    // Test Case 1: Basic Accumulation (1, 2, 3, 4 -> Sum 10)
    // Targets: Basic adder logic, count increments
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'd1;
    @(posedge clk);
    valid_in = 1; data_in = 8'd2;
    @(posedge clk);
    valid_in = 1; data_in = 8'd3;
    @(posedge clk);
    valid_in = 1; data_in = 8'd4;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0;
    
    repeat(3) @(posedge clk); // Wait for processing

    // ---------------------------------------------------------
    // Test Case 2: Accumulator Reset Check (5, 5, 5, 5 -> Sum 20)
    // Targets: 'count == 0' load logic vs add logic. 
    // If mutation causes add instead of load at count 0, result will be 10+20=30.
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'd5;
    @(posedge clk);
    valid_in = 1; data_in = 8'd5;
    @(posedge clk);
    valid_in = 1; data_in = 8'd5;
    @(posedge clk);
    valid_in = 1; data_in = 8'd5;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0;

    repeat(3) @(posedge clk);

    // ---------------------------------------------------------
    // Test Case 3: Interrupted Stream (Hold State)
    // Targets: Enable signals, sensitivity lists, state retention
    // Sequence: 10, 20 ... PAUSE ... 30, 40 -> Sum 100
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'd10;
    @(posedge clk);
    valid_in = 1; data_in = 8'd20;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0; // Pause
    repeat(2) @(posedge clk);
    @(posedge clk);
    valid_in = 1; data_in = 8'd30;
    @(posedge clk);
    valid_in = 1; data_in = 8'd40;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0;

    repeat(3) @(posedge clk);

    // ---------------------------------------------------------
    // Test Case 4: Max Value / Saturation (All 1s)
    // Targets: Bit width mismatches, overflow handling
    // Sequence: 255, 255, 255, 255 -> Sum 1020 (0x3FC)
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'hFF;
    @(posedge clk);
    valid_in = 1; data_in = 8'hFF;
    @(posedge clk);
    valid_in = 1; data_in = 8'hFF;
    @(posedge clk);
    valid_in = 1; data_in = 8'hFF;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0;

    repeat(3) @(posedge clk);

    // ---------------------------------------------------------
    // Test Case 5: Back-to-Back Packets (Throughput)
    // Targets: 'ready_add' logic, pipeline bubbles, valid_out timing
    // Packet A: 1,1,1,1. Packet B: 2,2,2,2.
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'd1;
    @(posedge clk);
    valid_in = 1; data_in = 8'd1;
    @(posedge clk);
    valid_in = 1; data_in = 8'd1;
    @(posedge clk);
    valid_in = 1; data_in = 8'd1; // End Packet A
    @(posedge clk);
    valid_in = 1; data_in = 8'd2; // Start Packet B immediately
    @(posedge clk);
    valid_in = 1; data_in = 8'd2;
    @(posedge clk);
    valid_in = 1; data_in = 8'd2;
    @(posedge clk);
    valid_in = 1; data_in = 8'd2;
    @(posedge clk);
    valid_in = 0; data_in = 8'd0;

    repeat(5) @(posedge clk);

    // ---------------------------------------------------------
    // Test Case 6: Reset Mid-Operation
    // Targets: Asynchronous reset logic
    // ---------------------------------------------------------
    @(posedge clk);
    valid_in = 1; data_in = 8'hAA;
    @(posedge clk);
    valid_in = 1; data_in = 8'h55;
    @(posedge clk);
    rst_n = 0; // Assert Reset
    @(posedge clk);
    rst_n = 1; valid_in = 0; data_in = 0;
    repeat(3) @(posedge clk);

    // 4. Cleanup / Handover
    $display("LLM: Tests Finished. Handing over to Original TB...");
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