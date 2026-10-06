class uart_sb;

	uart_trans tx_data;
	uart_trans rx_data;

	static int tx_verified=0;
	static int rx_verified=0;	
	static int total_verified = 0;

	int expected_tx;
	int expected_rx;

	event DONE;

	mailbox #(uart_trans) txmon2sb;
	mailbox #(uart_trans) rxmon2sb;

	function new(  mailbox #(uart_trans) txmon2sb,
    			mailbox #(uart_trans) rxmon2sb);

		this.txmon2sb = txmon2sb;
		this.rxmon2sb = rxmon2sb;
		expected_tx=no_of_transactions;
		expected_rx=no_of_transactions;
	endfunction

	//////// TX CHECKING LOGIC   ///////////////

	virtual task tx_check();
		forever
		begin
			txmon2sb.get(tx_data);
			$display("***********************************************");
			$display(" \t TX SCOREBOARD");
			$display("***********************************************");
			$display("\t INPUT dintx data = %08b",tx_data.dintx);
			$display("SERIAL RECONSTRUCTED: tx data = %08b",tx_data.tx);
			if(tx_data.dintx==tx_data.tx)
				begin
					$display("TX DATA MATCHED SUCCESSFULLY!!!");
				end
			else
				begin
					$display("FAILED: TX DATA MISMATCHED ");end
			$display("***********************************************");
			tx_verified++;
			total_verified++;

			if((tx_verified >= expected_tx) && (rx_verified >= expected_rx))
         			begin
				$display("--------------->>>>>>>>>>>>>>donecheck_tx_logic");
            				->DONE;	
				end
		end
	endtask

	//////// RX CHECKING LOGIC   ///////////////

	virtual task rx_check();
		forever
		begin
			rxmon2sb.get(rx_data);
			$display("***********************************************");
			$display(" \t RX SCOREBOARD");
			$display("***********************************************");
			$display("\t INPUT serial rx data = %08b",rx_data.rx);
			$display("\t DUT doutrx data = %08b",rx_data.doutrx);
			if(rx_data.rx==rx_data.doutrx)
				begin
					$display("RX DATA MATCHED SUCCESSFULLY!!!");
				end
			else
				begin
					$display("FAILED: RX DATA MISMATCHED ");					 end
			$display("***********************************************");
			rx_verified++;
			total_verified++;

			if((tx_verified >= expected_tx) && (rx_verified >= expected_rx))
         			begin
					$display("------->>>>.done_triggered_rx_logic----");	
            				->DONE;
				end
		end
	endtask

	virtual task start();
		fork
			tx_check();
			rx_check();
    
		join_none
		$display("ooooouuuuuuuuuttttttttttttooooooffffffffssssssssssssbbbbbbb");
	endtask

	virtual function void report();
	begin
	$display("============================================");
	$display("UART SCOREBOARD REPORT");
	$display("============================================");
	$display("EXPECTED TX COUNT = %0d",expected_tx);
	$display("EXPECTED RX COUNT = %0d",expected_rx);
	$display("TX VERIFIED COUNT = %0d",tx_verified);
	$display("RX VERIFIED COUNT = %0d",rx_verified);
	$display("TOTAL VERIFIED    = %0d",total_verified);
	$display("============================================");
	end
   	endfunction

endclass
