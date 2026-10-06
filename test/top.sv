`timescale 1ns/1ps

module top();

	import uart_pkg::*;

	parameter CLK_FREQ  = 1000000;
	parameter BAUD_RATE = 9600;
	localparam CLKCOUNT = CLK_FREQ / BAUD_RATE;

	reg clk = 0;
	always #500 clk = ~clk;

	uart_if vif(clk);
	
	//test class handles are declared
	test t_h;
	reset_test reset_test_h;
	reset_transfer_test reset_transfer_test_h;
	multi_transfer_test multi_transfer_test_h;
	newd_high_10_uclk_test newd_test_h;
	done_sig_test done_sig_test_h;
	all_zero_test all_zero_test_h;
	all_one_test all_one_test_h;
	
	uart_top #(.clk_freq (CLK_FREQ),.baud_rate(BAUD_RATE)) 
		DUV (.clk (vif.clk),
    		     .rst (vif.rst),
		     .rx (vif.rx),
    		     .dintx (vif.dintx),
    		     .newd (vif.newd),
    		     .tx (vif.tx),
    		     .doutrx (vif.doutrx),
    		     .donetx (vif.donetx),
    		     .donerx (vif.donerx)
  		   );

	int baud_cycles;

	initial
		baud_cycles = CLKCOUNT;

	  initial
  		begin
		$display("the baud_cycles value is : %0d",baud_cycles);

    		if($test$plusargs("TEST1"))
    			begin
      				t_h = new(vif,vif,vif,vif,baud_cycles);
				no_of_transactions = 1;
				t_h.build();
				t_h.run();
			
				wait(t_h.env_h.sb_h.DONE.triggered);
				#1000;
   				$finish;
			end

		// RESET TEST //------------------------------------------------------ 
		else if($test$plusargs("RESET_TEST"))
			 begin 
				reset_test_h = new(vif,vif,vif,vif,baud_cycles);
				 no_of_transactions = 1;
				 reset_test_h.build(); 
				reset_test_h.run();
				 #1000;
				 $finish;
			 end

		// RESET_TRANSFER_TEST //------------------------------------------
		else if($test$plusargs("RESET_TRANSFER_TEST"))
				begin

   				reset_transfer_test_h =new(vif,vif,vif,vif,baud_cycles);
   				no_of_transactions = 5;
				$display("no of trans: %0d",no_of_transactions);
   				reset_transfer_test_h.build();
   				reset_transfer_test_h.run();
				#1000;
   				$finish;
				end

		// MULTIPLE TRANSFER TEST//----------------------
	
		else if($test$plusargs("TEST5"))

			begin
   			multi_transfer_test_h = new(vif,vif,vif,vif,baud_cycles);
   			no_of_transactions = 5;
   			multi_transfer_test_h.build();
   			multi_transfer_test_h.run();
   			//wait(multi_transfer_test_h.env_h.sb_h.DONE.triggered);
   			#1000;
   			$finish;
			end


		// NEWD_HIGH_10_UCLK_CYCLE_TEST //------------------------------
		else if($test$plusargs("NEWD_HIGH_TEST"))
				begin

   				newd_test_h =new(vif,vif,vif,vif,baud_cycles);
  			 	no_of_transactions = 1;
 			  	newd_test_h.build();
 			  	newd_test_h.run();
 			  	#1000;
  			 	$finish;

				end

		
		//DONE SIGNAL CHECK TEST//--------------------------
		else if($test$plusargs("DONE_SIG_TEST"))
			begin
			done_sig_test_h = new(vif,vif,vif, vif,baud_cycles);
  			 no_of_transactions = 1;
   			$display("no_of_transactions = %0d",no_of_transactions);
   			done_sig_test_h.build();
   			done_sig_test_h.run();
   			#3000;
   			$finish;
			end

		//CORNER CASE: ALL ZEROES TEST//--------------------------
		else if($test$plusargs("ALL_ZERO_TEST"))
			begin
			all_zero_test_h = new(vif,vif,vif, vif,baud_cycles);
  			 no_of_transactions = 15;
   			$display("no_of_transactions = %0d",no_of_transactions);
   			all_zero_test_h.build();
   			all_zero_test_h.run();
   			#3000;
   			$finish;
			end

		//CORNER CASE: ALL ONES TEST//--------------------------
		else if($test$plusargs("ALL_ONES_TEST"))
			begin
			all_one_test_h = new(vif,vif,vif, vif,baud_cycles);
  			 no_of_transactions = 1;
   			$display("no_of_transactions = %0d",no_of_transactions);
   			all_one_test_h.build();
   			all_one_test_h.run();
   			#3000;
   			$finish;
			end


				
end

endmodule
