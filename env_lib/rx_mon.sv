class uart_rx_mon;

	virtual uart_if.rx_mon vif;
	uart_trans mon_data;
	uart_trans data2sb;

	int baud_cycles;

	mailbox #(uart_trans) mon2sb;

	function new (	virtual uart_if.rx_mon vif,
    			mailbox #(uart_trans) mon2sb,
			int baud_cycles);

    		this.vif= vif;
		this.mon2sb = mon2sb;
		this.baud_cycles=baud_cycles;
		this.mon_data = new();

	endfunction

	virtual task monitor();
	bit[7:0] sampled_rx;
		begin
			@(negedge vif.rx iff vif.rst==0)
			$display("[%0t] [RX MONITOR]:  START BIT DETECTED",$time);

			

			if(vif.rx !=1'b0)
				begin
				$display("[%0t][RX_MONITOR] FALSE START BIT",$time);
				return;
				end

				repeat(baud_cycles+baud_cycles/2)
					@(posedge vif.clk);


			for(int i=0;i<8;i++)
				begin
				#1;
				sampled_rx[i]=vif.rx;
				$display("[%t][rx_monitor]:---> serial bit[%0d]=%0b",$time,i,vif.rx);

				repeat(baud_cycles)
				@(posedge vif.clk);
				end
			
			#1;
			if(vif.rx==1'b1)
				$display("[%t][rx_monitor]:rx stop bit detected",$time);
			else
				$display("[%t][rx_monitor]:rx stop bit error occured",$time);

			wait(vif.donerx==1'b1);
			#1;
			mon_data.rx=sampled_rx;
			mon_data.doutrx=vif.doutrx;
			mon_data.donerx=vif.donerx;

			$display("\t [%t] [RX_MONITOR] serial rx reconstructed data= %b",$time,sampled_rx);
			$display("\t [%t] [RX_MONITOR] dut doutrx data= %b",$time,vif.doutrx);

			mon_data.display("FROM RX_MONITOR");
	end
	endtask

	virtual task start();
	fork
		forever
      		begin
			monitor();
			data2sb = new();
			data2sb.rx      = mon_data.rx;
			data2sb.doutrx  = mon_data.doutrx;
			data2sb.donerx  = mon_data.donerx;
        		mon2sb.put(data2sb);
      		end
    	join_none

	endtask

endclass
