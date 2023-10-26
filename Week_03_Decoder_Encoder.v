module test(x, D, en);  // The Decoder Fast Version

    input[2:0]     x ;
    
    input          en ;
	 output[7:0]     D ;


    assign D = (en)? 1'b1 << x : 8'h00 ;
    
endmodule
