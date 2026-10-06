class uart_trans;

	 bit newd;
	rand bit [7:0] dintx; //input data signal for the tx 

	rand bit [7:0] rx; //input data signal for the rx

	bit rst;
	bit [7:0]tx; //output data signal from the tx
	bit [7:0] doutrx;  //output signal from the rx

 	bit donetx;
	bit donerx;
	
	int newd_hold_cycles;

	constraint VALID_TX_DATA {dintx inside {[8'h00:8'hFF]};}

	//constraint VALID_NEWD {newd dist {1 := 80,0 := 20};}

	constraint VALID_RX_DATA {rx inside {[8'h00:8'hFF]};}

	function new();
		newd_hold_cycles=2;
	endfunction

	function void display(input string str);

	$display("--------------------------------------------");
        $display(" %s ",str);
        $display("--------------------------------------------");
	$display(" \t reset   = %0b ",rst);
	$display(" \t newd   = %0b ",newd);
	$display(" \t dintx  =%0h ",dintx);
	$display(" \t tx = %0b",tx);
        $display(" \t donetx  = %0b ",donetx);
	$display(" \t rx  = %0h ",rx);
	$display(" \t doutrx  = %0h ",doutrx);
        $display(" \t donerx  = %0b ",donerx);
        $display(" \t newd_hold_cycles  = %0d ",newd_hold_cycles);
	$display("--------------------------------------------");

   endfunction

endclass
