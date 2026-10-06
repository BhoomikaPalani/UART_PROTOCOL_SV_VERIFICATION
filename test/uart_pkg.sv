package uart_pkg;

	int no_of_transactions = 1;

	`include "uart_trans.sv"
	`include "uart_gen.sv"
	`include "tx_drv.sv"
	`include "rx_drv.sv"
	`include "tx_mon.sv"
	`include "rx_mon.sv"
	`include "uart_sb.sv"
	`include "env.sv"
	`include "test.sv"

endpackage
