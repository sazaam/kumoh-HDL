module TrafficLightController(clk, standby, test, 
	G1Y1, R1G2, Y2R2, 
	G1en, Y1en, R1en,
	G2en, Y2en, R2en) ;

	///////////////////////////////////// I/O
	input 		clk, standby, test ;
	output[6:0] G1Y1, R1G2, Y2R2 ;
	output 		G1en, Y1en, R1en,
					G2en, Y2en, R2en ;
	
	///////////////////////////////////// COLOR CHANGES & STATES
	reg[6:0]		G1Y1, R1G2, Y2R2 ;
	reg	 		G1en, Y1en, R1en,
					G2en, Y2en, R2en ;
	
	parameter	YY=3'b000, RY=3'b001, GR=3'b010, YR=3'b011, RG=3'b100 ;
	reg[2:0] 	state=YY ;
	
	
	
	
	
	///////////////////////////////////// TIME CONTROL
	reg 			clk1Hz, clk100Hz ;
	integer 		cnt1Hz, cnt100Hz ;
	parameter 	RGTime=10, RYTime=3, GRTime=15, YRTime=3, TESTTime = 2 ;
	integer 		TimeCnt, onTime ;
	
	
	
	////////////////////////////////////// DISPLAY
	reg[6:0]		G1=7'b0000000, Y1=7'b0000000, R1=7'b0000000 ;
	reg[6:0]		G2=7'b0000000, Y2=7'b0000000, R2=7'b0000000 ;
	
	//////////////////////////////////////////////////////////////// END SETTINGS
	
	
	
	/////////////////////  TIME CLOCKS CONTROL
	always @(posedge clk) begin
		if(cnt1Hz >= 499999) begin
			cnt1Hz <= 0 ;
			clk1Hz <= ~clk1Hz ;
		end else
			cnt1Hz <= cnt1Hz + 1 ;
		
		if(cnt100Hz >= 4999) begin
			cnt100Hz <= 0 ;
			clk100Hz <= ~clk100Hz ;
		end else
			cnt100Hz <= cnt100Hz + 1 ;
	end
	/////////////////////  END TIME CLOCKS CONTROL
	
	
	task state_change( input s) ;
		begin
			state <= s;
			TimeCnt <= 0 ;
			onTime <= 0;
		end
	endtask
	
	task state_check_and_change( input s) ;
		begin
			if(TimeCnt >= onTime) begin
				state_change(s) ;
			end
		end
	endtask
	
	task increment();
		begin
			TimeCnt <= TimeCnt + 1 ;
		end
	endtask
	
	task state_ensure( input isTest, input s) ;
		begin
			onTime = isTest ?  TESTTime :
						s == RY ? RYTime :
						s == GR ? GRTime :
						s == YR ? YRTime :
									 RGTime ;
		end
	endtask
	
	
	always @(posedge clk1Hz or posedge standby) begin
		
		if(standby) begin /// KILL ALL STATE LOGIC IF ON STANDBY
			// i-e RESET ALL
			state_change(YY);
		end else
			
			case(state)
				RY:begin
				
					state_ensure(test, state) ;
					increment() ;
					state_check_and_change(GR);
					
				end
				GR:begin
					state_ensure(test, state) ;
					increment() ;
					state_check_and_change(YR);
				end
				
				YR: begin
					state_ensure(test, state) ;
					increment() ;
					state_check_and_change(RG);
				end
				RG:begin
					state_ensure(test, state) ;
					increment() ;
					state_check_and_change(RY);
				end
				
			endcase
			
		
		
	end
	
	
	
	//////////////////// FND
	//////// DISPLAY
	always @(state) begin
		case(state)
			
			RY:begin
				R1 <= 7'b1111110 ; Y1 <= 7'b0000000 ; G1 <= 7'b0000000 ;
				R2 <= 7'b0000000 ; Y2 <= 7'b1111110 ; G2 <= 7'b0000000 ;
			end
			
			GR:begin
				R1 <= 7'b0000000 ; Y1 <= 7'b0000000 ; G1 <= 7'b1111110 ;
				R2 <= 7'b1111110 ; Y2 <= 7'b0000000 ; G2 <= 7'b0000000 ;
			end
			
			YR:begin
				R1 <= 7'b0000000 ; Y1 <= 7'b1111110 ; G1 <= 7'b0000000 ;
				R2 <= 7'b1111110 ; Y2 <= 7'b0000000 ; G2 <= 7'b0000000 ;
			
			end
			
			RG:begin
				R1 <= 7'b1111110 ; Y1 <= 7'b0000000 ; G1 <= 7'b0000000 ;
				R2 <= 7'b0000000 ; Y2 <= 7'b0000000 ; G2 <= 7'b1111110 ;
			
			end
			// YY
			default: begin
				R1 <= 7'b0000000 ; Y1 <= 7'b1111110 ; G1 <= 7'b0000000 ;
				R2 <= 7'b0000000 ; Y2 <= 7'b1111110 ; G2 <= 7'b0000000 ;
			end
		endcase
	
	end
	
	//////// SWITCH
	always @(clk100Hz or G1, Y1, R1, G2, Y2, R2) begin
		
		if(clk100Hz) begin
		
			G1en <= 1'b0 ; Y1en <= 1'b1 ; R1en <= 1'b0 ;
			G2en <= 1'b1 ; Y2en <= 1'b0 ; R2en <= 1'b1 ;
			
			G1Y1 <= G1 ;
			R1G2 <= R1 ;
			Y2R2 <= Y2 ;
			
		end else begin
			
			G1en <= 1'b1 ; Y1en <= 1'b0 ; R1en <= 1'b1 ;
			G2en <= 1'b0 ; Y2en <= 1'b1 ; R2en <= 1'b0 ;
			
			G1Y1 <= Y1 ;
			R1G2 <= G2 ;
			Y2R2 <= R2 ;
			
		
		end
		
	end
	//////////////////// END FND
	
	
	

endmodule
