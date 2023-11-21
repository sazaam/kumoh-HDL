module ParityChecker(data_in, parityCheck);
	parameter n = 8;
	input[n:0] data_in;
	output parityCheck;
	
	reg parityCheck;
	
	task parity;
		
		input 	[n:0] 	inp;
		output 				out;
		begin
		out = ^data_in;
		end
	endtask 
	
	always @(data_in) begin
		parity(data_in, parityCheck);
	end

endmodule
