`timescale 1ns/1ps
module tb_division();

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
        


endmodule