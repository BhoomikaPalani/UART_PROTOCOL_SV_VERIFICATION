class uart_gen;

	uart_trans gen_trans;
	uart_trans data2send;

	mailbox #(uart_trans) gen2txdr;
	mailbox #(uart_trans) gen2rxdr;

	function new(mailbox#(uart_trans)gen2txdr,
		     mailbox#(uart_trans)gen2rxdr);
		this.gen2txdr=gen2txdr;
		this.gen2rxdr=gen2rxdr;
		this.gen_trans=new;
	endfunction

	virtual task start();
		fork
		begin
			for(int i = 0;i<no_of_transactions;i++)
			begin
				assert(gen_trans.randomize());
				gen_trans.newd=1'b1;
				data2send = new gen_trans;
				$display("%t from generator....................",$time);
				data2send.display("FROM GENERATOR");
				gen2txdr.put(data2send);
				gen2rxdr.put(data2send);
			end
		end
		join_none
	endtask

endclass
