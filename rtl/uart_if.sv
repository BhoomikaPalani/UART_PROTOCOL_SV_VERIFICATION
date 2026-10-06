//-------------uart interface------------------
 
interface uart_if(input bit clk);
  //logic clk;
  logic rst;
  logic rx;
  logic [7:0] dintx;
  logic newd;
  logic tx;
  logic [7:0] doutrx;
  logic donetx;
  logic donerx;

	modport tx_drv(input clk,donetx,tx,output rst,dintx,newd);
	modport tx_mon(input clk,rst,dintx,newd,tx,donetx);

	modport rx_drv(input clk,donerx,output rx,rst);
	modport rx_mon(input clk,rst,rx,doutrx,donerx);

  
endinterface
