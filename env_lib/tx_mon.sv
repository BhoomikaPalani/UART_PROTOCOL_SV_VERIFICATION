class uart_tx_mon;

    virtual uart_if.tx_mon vif;

    uart_trans mon_data;
    uart_trans data2sb;

    mailbox #(uart_trans) mon2sb;

    int baud_cycles;

    function new(
        virtual uart_if.tx_mon vif,
        mailbox #(uart_trans) mon2sb,
        int baud_cycles
    );

        this.vif         = vif;
        this.mon2sb      = mon2sb;
        this.baud_cycles = baud_cycles;

    endfunction


    virtual task monitor();

        bit [7:0] sampled_tx;

        begin

            // WAIT FOR START BIT
            @(negedge vif.tx iff vif.rst==0);

            $display("TX MONITOR START BIT DETECTED");

            // move to middle of START bit
            repeat(baud_cycles/2)
                @(posedge vif.clk);

            // validate start bit
            if(vif.tx != 1'b0)
            begin
                $display("FALSE START BIT DETECTED");
                return;
            end

            // CAPTURE INPUT SIDE
            mon_data = new();

            mon_data.rst   = vif.rst;
            mon_data.newd  = vif.newd;
            mon_data.dintx = vif.dintx;

            // move to middle of DATA BIT0
            repeat(baud_cycles)
                @(posedge vif.clk);

            // SAMPLE 8 DATA BITS
            for(int i=0; i<8; i++)
            begin

                #1;
                sampled_tx[i] = vif.tx;

                $display("tx_monitor: serial bit[%0d]=%0b",i, sampled_tx[i]);

                repeat(baud_cycles)
                    @(posedge vif.clk);

            end

            mon_data.tx = sampled_tx;

            // STOP BIT CHECK
            if(vif.tx == 1'b1)
                $display("TX STOP BIT DETECTED");
            else
                $display("TX STOP BIT ERROR");

            // WAIT FOR DONETX
            wait(vif.donetx==1'b1);

            mon_data.donetx = vif.donetx;

            mon_data.display("FROM TX MONITOR");

        end

    endtask


    virtual task start();

        fork

            forever
            begin

                monitor();

                // PROPER OBJECT COPY
                data2sb = new();

                data2sb.rst     = mon_data.rst;
                data2sb.newd    = mon_data.newd;
                data2sb.dintx   = mon_data.dintx;
                data2sb.tx      = mon_data.tx;
                data2sb.donetx  = mon_data.donetx;

                mon2sb.put(data2sb);

            end

        join_none

    endtask

endclass
