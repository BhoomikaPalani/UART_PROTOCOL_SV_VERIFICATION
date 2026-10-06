class test;

	virtual uart_if.tx_drv txdrv_if;
	virtual uart_if.rx_drv rxdrv_if;
	virtual uart_if.tx_mon txmon_if;
	virtual uart_if.rx_mon rxmon_if;

	uart_env env_h;

	int baud_cycles;

	uart_trans custom_trans;

	function new(   virtual uart_if.tx_drv txdrv_if,
    			virtual uart_if.rx_drv rxdrv_if,
    			virtual uart_if.tx_mon txmon_if,
    			virtual uart_if.rx_mon rxmon_if,
    			int baud_cycles);
		this.txdrv_if = txdrv_if;
		this.rxdrv_if = rxdrv_if;
		this.txmon_if = txmon_if;
		this.rxmon_if = rxmon_if;
		this.baud_cycles = baud_cycles;
	endfunction

	virtual task build();
		env_h = new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);

	endtask

	virtual task run();
		if(custom_trans!=null)
			env_h.custom_trans=custom_trans;
		env_h.run();
	endtask

endclass


//==============================================================
// RESET TEST_CASE
//==============================================================

class reset_test extends test;

	function new(	virtual uart_if.tx_drv txdrv_if,
               		virtual uart_if.rx_drv rxdrv_if,
                	virtual uart_if.tx_mon txmon_if,
                	virtual uart_if.rx_mon rxmon_if,
                	int baud_cycles);

			super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);
	endfunction

	virtual task build();
		super.build();
	endtask

	virtual task run();

		//-----------ASSERT THE RESET ------------
      		txdrv_if.rst <= 1'b1;
		rxdrv_if.rst <= 1'b1;

      		// --------WAIT UART CLOCK CYCLES -----------

      		repeat(baud_cycles*2)
         		@(posedge txdrv_if.clk);

      		// -------------DEASSERT RESET -----------------
   
      		txdrv_if.rst <= 1'b0;
      		rxdrv_if.rst <= 1'b0;

      		//--------- WAIT FOR UART FSM TO SETTLE-----------

      		repeat(baud_cycles*2)
         	@(posedge txdrv_if.clk);

     		 // -----------CHECK DUT OUTPUTS-------------------
 
      		if(txmon_if.tx == 1'b1)
         		$display("%t [RESET_TESTCASE]: TX LINE HIGH AFTER RESET",$time);
      		else
        	 	$display("%t [RESET_TESTCASE]:ERROR!!! TX LINE NOT HIGH",$time);


     		 if(txmon_if.donetx == 1'b0)
         		$display("%t [RESET_TESTCASE]: DONETX LOW AFTER RESET",$time);
     		 else
         		$display("%t [RESET_TESTCASE]: ERROR!!! DONETX SHOULD BE LOW",$time);


      		if(rxmon_if.donerx == 1'b0)
         		$display("%t [RESET_TESTCASE]: DONERX LOW AFTER RESET",$time);
      		else
         		$display("%t [RESET_TESTCASE]: DONERX SHOULD BE LOW",$time);


      		if(rxmon_if.doutrx == 8'h00)
         		$display("%t [RESET_TESTCASE]: RXDATA RESET SUCCESS",$time);
      		else
         		$display("%t [RESET_TESTCASE]: RXDATA NOT RESET",$time);

      		super.run();

   	endtask

endclass

/////////////////////////////////////////////////////////////////////////////

//    RESET_TRANSFER_TEST CASE

////////////////////////////////////////////////////////////////////////////

class reset_transfer_test extends test;

	function new(    virtual uart_if.tx_drv txdrv_if,
     			 virtual uart_if.rx_drv rxdrv_if,
     			 virtual uart_if.tx_mon txmon_if,
     			 virtual uart_if.rx_mon rxmon_if,
     			 int baud_cycles);

      		super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if, baud_cycles);
	 endfunction

	virtual task run();

      		$display("[%0t][RESET_TRANSFER_TEST] STARTED",$time);
      
		fork
         		env_h.run();
      		join_none

      		//------------- We wait few baud cycles so UART starts sending bits
	      	repeat(baud_cycles * 4)
         		@(posedge txdrv_if.clk);

      		$display("[%0t][RESET_TRANSFER_TEST] ASSERTING RESET DURING TRANSFER",$time);

	      //----------- ASSERT RESET --------------
     		 txdrv_if.rst <= 1'b1;
     		 rxdrv_if.rst <= 1'b1;

	      //---------- HOLD RESET --------------
      		repeat(baud_cycles * 2)
         		@(posedge txdrv_if.clk);

    	      //------------ CHECK DUT OUTPUTS --------------------
   
      		if(txdrv_if.tx == 1'b1)
         		$display("[%0t][RESET_TRANSFER_TEST] TX RETURNED TO IDLE",$time);
      		else
        		$display("[%0t][RESET_TRANSFER_TEST] ERROR : TX NOT IDLE",$time);

      		if(rxdrv_if.donerx == 1'b0)
         		$display("[%0t][RESET_TRANSFER_TEST] RX RESET SUCCESS",$time);
     		 else
         		$display("[%0t][RESET_TRANSFER_TEST] ERROR : DONERX HIGH",$time);

  
      		//----------------- DEASSERT RESET ----------------
      		txdrv_if.rst <= 1'b0;
      		rxdrv_if.rst <= 1'b0;

      		$display("[%0t][RESET_TRANSFER_TEST] RESET DEASSERTED",$time);

	      //------------ WAIT FEW CLOCKS ----------------
        	repeat(baud_cycles * 5)
         		@(posedge txdrv_if.clk);

      		$display("[%0t][RESET_TRANSFER_TEST] TEST COMPLETED",$time);

   	endtask

endclass

/////////////////////////////////////////////////////////////////////////////

//    MULTI_TRANSFER_TEST CASE

////////////////////////////////////////////////////////////////////////////

class multi_transfer_test extends test;

	function new(    virtual uart_if.tx_drv txdrv_if,
     			 virtual uart_if.rx_drv rxdrv_if,
     			 virtual uart_if.tx_mon txmon_if,
     			 virtual uart_if.rx_mon rxmon_if,
     			 int baud_cycles);

      		super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if, baud_cycles);
	 endfunction

	virtual task build();
		super.build();
	endtask

	virtual task run();

      		$display("[%0t][MULTI_TRANSFER_TEST] STARTED",$time);
      
		super.run();

		wait(env_h.sb_h.DONE.triggered);
      		$display("[%0t][MULTI_TRANSFER_TEST] TEST COMPLETED",$time);

   	endtask

endclass

////////////////////////////////////////////////////////////////////////////

//=========================================================
// TRANSACTION EXTENSION FOR NEWD HIGH FOR 10 UCLK
//=========================================================

class newd_high_10_uclk_trans extends uart_trans;

  	function new();
		super.new();
		newd_hold_cycles=10;
	endfunction

endclass

//////////////////////////////////////////////////////////

// NEWD_HIGH_10_UCLK TEST_CASE

/////////////////////////////////////////////////////////

class newd_high_10_uclk_test extends test;

	newd_high_10_uclk_trans trans_h;

   	function new(  	virtual uart_if.tx_drv txdrv_if,
      			virtual uart_if.rx_drv rxdrv_if,
      			virtual uart_if.tx_mon txmon_if,
      			virtual uart_if.rx_mon rxmon_if,
      			int baud_cycles);

     	 	super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);
	endfunction

	virtual task build();
		super.build();
	endtask

   	virtual task run();

      		$display("[%0t][NEWD_HIGH_TEST] STARTED",$time);
			
		trans_h=new();
		custom_trans=trans_h;

         	super.run();
		wait(env_h.sb_h.DONE.triggered);

    	      	//------------EXTRA WAIT -------------------------
      		repeat(baud_cycles * 2)
         		@(posedge txdrv_if.clk);

     		 $display("[%0t][NEWD_HIGH_TEST] TEST COMPLETED",$time);

   	endtask

endclass

//////////////////////////////////////////////////////////

// DONE SIGNAL TESTCASE

///////////////////////////////////////////////////////////

class done_sig_test extends test;

	function new(  virtual uart_if.tx_drv txdrv_if,
      			virtual uart_if.rx_drv rxdrv_if,
      			virtual uart_if.tx_mon txmon_if,
      			virtual uart_if.rx_mon rxmon_if,
      			int baud_cycles);

      		super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);

  	 endfunction

 	virtual task build();
      		super.build();
   	endtask

	virtual task run();

      		$display("[%0t][DONE_SIG_TEST] STARTED",$time);
      		fork
         		env_h.run();
      		join_none

      		// -------------- WAIT FOR DONETX ASSERTION ----------
      		
		@(posedge txmon_if.donetx);
      			$display("[%0t][DONE_SIG_TEST] DONETX ASSERTED",$time);

      		// ----------- CHECK AFTER 1 UART CLOCK ------------
		repeat(baud_cycles)
         		@(posedge txdrv_if.clk);
			#1;

      		if(txmon_if.donetx == 1'b0)
         		$display("[%0t][DONE_SIG_TEST] DONETX ONE-CYCLE PULSE PASS",$time);
      		else
         		$display("[%0t][DONE_SIG_TEST] ERROR : DONETX STUCK HIGH",$time);

      		//---------- WAIT FOR DONERX ASSERTION -------------

      		@(posedge rxmon_if.donerx);
      			$display("[%0t][DONE_SIG_TEST] DONERX ASSERTED",$time);

	      // ---------- CHECK AFTER 1 UART CLOCK ---------------
        	repeat(baud_cycles*2)
		 	@(posedge txdrv_if.clk);
			#1;

      		if(rxmon_if.donerx == 1'b0)
         		$display("[%0t][DONE_SIG_TEST] DONERX ONE-CYCLE PULSE PASS", $time);
      		else
         		$display("[%0t][DONE_SIG_TEST] ERROR : DONERX STUCK HIGH",$time);

      		//----------- EXTRA WAIT -----------------------
	      repeat(10)
         		@(posedge txdrv_if.clk);
      			$display("[%0t][DONE_SIG_TEST] COMPLETED",$time);

  	 endtask

endclass


//=========================================================
// TRANSACTION CLASS EXTENDED FOR ALL_ZEROES
//=========================================================

class all_zero_trans extends uart_trans;

	constraint all_zero_c{dintx==8'h00;
				rx==8'h00;}

  	function new();
		super.new();
	endfunction

endclass

//////////////////////////////////////////////////////////

// ALL_ZEROES TEST_CASE

/////////////////////////////////////////////////////////

class all_zero_test extends test;

	all_zero_trans trans_z;

   	function new(  	virtual uart_if.tx_drv txdrv_if,
      			virtual uart_if.rx_drv rxdrv_if,
      			virtual uart_if.tx_mon txmon_if,
      			virtual uart_if.rx_mon rxmon_if,
      			int baud_cycles);

     	 	super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);
	endfunction

	virtual task build();
		super.build();
	endtask

   	virtual task run();

      		$display("[%0t][ALL_ZEROES_TEST] STARTED",$time);
			
		trans_z=new();
		custom_trans=trans_z;

         	super.run();
		wait(env_h.sb_h.DONE.triggered);

      		repeat(10)
         		@(posedge txdrv_if.clk);

     		 $display("[%0t][ALL_ZEROES_TEST] TEST COMPLETED",$time);

   	endtask

endclass

//////////////////////////////////////////////////////////

//=========================================================
// TRANSACTION CLASS EXTENDED FOR ALL_ONES
//=========================================================

class all_one_trans extends uart_trans;

	constraint all_one_c{dintx==8'hff;
				rx==8'hff;}

  	function new();
		super.new();
	endfunction

endclass

//////////////////////////////////////////////////////////

// ALL_ONES TEST_CASE

/////////////////////////////////////////////////////////

class all_one_test extends test;

	all_one_trans trans_o;

   	function new(  	virtual uart_if.tx_drv txdrv_if,
      			virtual uart_if.rx_drv rxdrv_if,
      			virtual uart_if.tx_mon txmon_if,
      			virtual uart_if.rx_mon rxmon_if,
      			int baud_cycles);

     	 	super.new(txdrv_if,rxdrv_if,txmon_if,rxmon_if,baud_cycles);
	endfunction

	virtual task build();
		super.build();
	endtask

   	virtual task run();

      		$display("[%0t][ALL_ONES_TEST] STARTED",$time);
			
		trans_o=new();
		custom_trans=trans_o;

         	super.run();
		wait(env_h.sb_h.DONE.triggered);

      		repeat(10)
         		@(posedge txdrv_if.clk);

     		 $display("[%0t][ALL_ONES_TEST] TEST COMPLETED",$time);

   	endtask

endclass

//////////////////////////////////////////////////////////


