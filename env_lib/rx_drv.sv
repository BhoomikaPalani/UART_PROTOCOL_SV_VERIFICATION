class uart_rx_driver;

	virtual uart_if.rx_drv vif;

	uart_trans data2duv;

	mailbox #(uart_trans) gen2rxdr;

	int baud_cycles;

	function new(  virtual uart_if.rx_drv vif,
   			mailbox #(uart_trans) gen2rxdr,
    			int baud_cycles);

    		this.vif= vif;
		this.gen2rxdr= gen2rxdr;
		this.baud_cycles= baud_cycles;
	endfunction

	task reset_rx();
	begin

		$display("[%0t][RX_DRIVER] RESET STARTED",$time);

		// UART idle state
		vif.rx <= 1'b1;

		// wait for reset deassertion
		if(vif.rst)
		begin
			@(negedge vif.rst);
		end

		// wait one baud period after reset
		repeat(baud_cycles)
			@(posedge vif.clk);

		$display("[%0t][RX_DRIVER] RESET COMPLETED",$time);

	end

	endtask
			
	virtual task drive_rx(bit [7:0] data);
		begin
			$display("[%0t][RX_DRIVER] DRIVING DATA = %0h",$time,data);

			vif.rx <= 1'b1;

			repeat(baud_cycles)
				@(posedge vif.clk);
			#1;

      			vif.rx <= 1'b0; //start bit
			$display("[%0t][RX_DRIVER] START BIT",$time);

      			repeat(baud_cycles)
        			@(posedge vif.clk);

      				for(int i = 0; i < 8; i++) //8 bit data sending serially
      				begin
					#1;
        				vif.rx <= data[i];
					$display("[%0t][RX_DRIVER] bit[%0d] = %0b",$time,i,data[i]);
        				repeat(baud_cycles)
          					@(posedge vif.clk);
      		
		end

	repeat(baud_cycles)
          					@(posedge vif.clk);

			#1;
			vif.rx <= 1'b1;  //stop bit
			$display("[%0t][RX_DRIVER] STOP BIT",$time);

 			repeat(baud_cycles)
        			@(posedge vif.clk);

			//----------------------------------------------------
		// WAIT FOR DONERX
		//----------------------------------------------------

		fork

			begin
				if(!vif.donerx)
				@(posedge vif.donerx);

				$display("[%0t][RX_DRIVER] DONERX RECEIVED",$time);
			end

			begin
				repeat(20*baud_cycles)
					@(posedge vif.clk);

				$display("[%0t][RX_DRIVER] WARNING : DONERX TIMEOUT",$time);
			end

		join_any

		disable fork;



		//----------------------------------------------------
		// INTER FRAME GAP for multi transfer
		//----------------------------------------------------

		repeat(2*baud_cycles)
			@(posedge vif.clk);

    		end
	endtask

	virtual task start();
		fork
			begin
			wait(vif.rst==1);
			reset_rx();
      			forever
      				begin	
        				gen2rxdr.get(data2duv);
       					data2duv.display("FROM RX DRIVER");
        				drive_rx(data2duv.rx);
      				end
			end

    		join_none
	endtask

endclass
