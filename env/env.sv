class uart_env;

	virtual uart_if.tx_drv txdrv_if;
	virtual uart_if.rx_drv rxdrv_if;
	virtual uart_if.tx_mon txmon_if;
	virtual uart_if.rx_mon rxmon_if;

	mailbox #(uart_trans) gen2txdr = new();
	mailbox #(uart_trans) gen2rxdr = new();
	mailbox #(uart_trans) txmon2sb = new();
	mailbox #(uart_trans) rxmon2sb = new();

	uart_gen gen_h;
	uart_tx_driver txdr_h;
	uart_rx_driver rxdr_h;
	uart_tx_mon txmon_h;
	uart_rx_mon rxmon_h;
	uart_sb  sb_h;

	int baud_cycles;

	uart_trans custom_trans;

	function new(   virtual uart_if.tx_drv txdrv_if,
			virtual uart_if.rx_drv rxdrv_if,
			virtual uart_if.tx_mon txmon_if,
			virtual uart_if.rx_mon rxmon_if,
    			int baud_cycles);

    		this.txdrv_if = txdrv_if;
		this.rxdrv_if   = rxdrv_if;
		this.txmon_if   = txmon_if;
		this.rxmon_if   = rxmon_if;
		this.baud_cycles = baud_cycles;
	endfunction

	virtual task build();
		gen_h= new(gen2txdr, gen2rxdr);
		if(custom_trans!=null)
			gen_h.gen_trans=custom_trans;
		txdr_h= new(txdrv_if, gen2txdr,baud_cycles);
		rxdr_h= new(rxdrv_if, gen2rxdr, baud_cycles);
		txmon_h= new(txmon_if, txmon2sb,baud_cycles);
		rxmon_h= new(rxmon_if, rxmon2sb,baud_cycles);
		sb_h= new(txmon2sb, rxmon2sb);
		sb_h.expected_tx=no_of_transactions;
		sb_h.expected_rx=no_of_transactions;
	endtask

	virtual task start();
		gen_h.start();
		txdr_h.start();
		rxdr_h.start();
		txmon_h.start();
		rxmon_h.start();
		sb_h.start();
		endtask

	virtual task stop();
		
		wait(sb_h.DONE.triggered);

	endtask

	virtual task run();
		build();
		start();
		stop();
		sb_h.report();
	endtask

endclass
