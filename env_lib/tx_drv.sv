class uart_tx_driver;

	virtual uart_if.tx_drv vif;

	uart_trans data2duv;

	mailbox #(uart_trans) gen2txdr;

	int baud_cycles;

	function new( virtual uart_if.tx_drv vif,
    			mailbox #(uart_trans) gen2txdr,
			int baud_cycles);
		this.vif= vif;
		this.gen2txdr= gen2txdr;
		this.baud_cycles=baud_cycles;
	endfunction

// RESET TASK
	virtual task reset_dut();
		begin
			@(posedge vif.clk);
           		vif.rst   <= 1'b1;
            		vif.newd  <= 1'b0;
            		vif.dintx <= 8'h00;

          		repeat(baud_cycles)
                	@(posedge vif.clk);
		
            		vif.rst <= 1'b0;

            $display("TX DRIVER RESET COMPLETED");
			repeat(baud_cycles)
                	@(posedge vif.clk);
        	end
	endtask
	
	virtual task drive();
		

		if(data2duv.rst)
			begin
				$display(" %0t [TX DRIVER]: MID-TEST RESET",$time);
				vif.rst<=1'b1;
				vif.newd<=1'b0;
				repeat(baud_cycles)
                			@(posedge vif.clk);
				vif.rst<=1'b0;
				repeat(baud_cycles)
                			@(posedge vif.clk);
			end


		@(posedge vif.clk);
		#1;
		vif.newd  <= 1'b1;
		vif.dintx <= data2duv.dintx;

		if(data2duv.newd)
			begin
				$display("[%0t][TX_DRIVER] HOLDING NEWD HIGH FOR %0d BAUD CYCLES",$time,data2duv.newd_hold_cycles);

				repeat(data2duv.newd_hold_cycles*baud_cycles)
                			@(posedge vif.clk);
					#1;
					vif.newd  <= 1'b0;

				fork
					begin:wait_donetx
					@(posedge vif.donetx);
					$display("\t %0t [TX_DRIVER] : DONETX RECIEVED",$time);
					end

					begin:timeout_tx
					repeat(20)
						begin
							repeat(baud_cycles)
                					@(posedge vif.clk);
						end
					$display( "\t %0t [TX_DRIVER] : WARNING !!!!! DONETX timeout",$time);
					end
				join_any
				disable fork;

				repeat(baud_cycles)
                		@(posedge vif.clk);
			end

		else
		begin
			repeat(baud_cycles)
      				@(posedge vif.clk);
			#1;
			vif.newd <= 1'b0;
		end
	endtask

	virtual task start();
		fork
			reset_dut();
			forever
			begin
				gen2txdr.get(data2duv);
				data2duv.display("FROM TX DRIVER");
				drive();
			end
		join_none
	endtask

endclass
