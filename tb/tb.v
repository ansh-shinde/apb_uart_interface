module test;

reg preset,
    penable,
    pwrite,
    psel,
    pclk,
    rx,
    cts;

reg [4:0]paddr;
reg [31:0]pwdata;

wire pready,
     rts,
     tx,
     intrr_tx,
     intrr_rx,
     pslverr;

wire [31:0]prdata;

apb_uart dut(
    .preset(preset),
    .pclk(pclk),
    .penable(penable),
    .pwrite(pwrite),
    .psel(psel),
    .paddr(paddr),
    .pwdata(pwdata),
    .pready(pready),
    .pslverr(pslverr),
    .prdata(prdata),
    .rx(rx),
    .intrr_tx(intrr_tx),
    .intrr_rx(intrr_rx),
    .cts(cts),
    .rts(rts),
    .tx(tx)
);

always #5 pclk = ~pclk;

//------------------------------------------------------------------------------
// Rx Bit Task
//------------------------------------------------------------------------------

task send_bit;
input bit_val;
begin
    rx = bit_val;
    #4210;
end
endtask

//------------------------------------------------------------------------------
// UART Frame Task
//------------------------------------------------------------------------------

task send_uart_frame;
input [7:0] data;
input parity;
input stop;
integer i;
begin
    if(rts) begin
        send_bit(0);

        for(i=0;i<8;i=i+1)
            send_bit(data[i]);

        send_bit(parity);
        send_bit(stop);
        #4210;
    end
end
endtask

//------------------------------------------------------------------------------
// APB Transaction Task
//------------------------------------------------------------------------------

task push;
    input [4:0] address;
    input [31:0] data;
    input rd_wr;
begin

    // Setup phase
    @(posedge pclk);
    psel    = 1'b1;
    penable = 1'b0;
    pwrite  = rd_wr;
    paddr   = address;
    pwdata  = data;

    // Access phase
    @(posedge pclk);
    penable = 1'b1;

    // Wait one cycle
    @(posedge pclk);

    // Idle phase
    psel    = 1'b0;
    penable = 1'b0;

end
endtask

initial begin
    pclk     = 0;
    preset   = 0;
    penable  = 0;
    pwrite   = 0;
    psel     = 0;
    rx       = 1;
    cts      = 1;
    paddr    = 5'h00;
    pwdata   = 32'h00000000;

    $dumpfile("apb_uart.vcd");
    $dumpvars(0,test);
    $dumpvars(0,dut.regfile[0]);
    $dumpvars(0,dut.regfile[1]);
    $dumpvars(0,dut.regfile[2]);
    $dumpvars(0,dut.regfile[3]);
    $dumpvars(0,dut.regfile[4]);
    $dumpvars(0,dut.regfile[5]);
    $dumpvars(0,dut.regfile[6]);
    $dumpvars(0,dut.regfile[7]);

    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[0]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[1]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[2]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[3]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[4]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[5]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[6]);
    $dumpvars(0,dut.transmitter.dat.fifo.dat.str.regfile[7]);

    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[0]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[1]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[2]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[3]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[4]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[5]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[6]);
    $dumpvars(0,dut.receiver.dat.fifo.dat.str.regfile[7]);
    #4000000 $finish;
end

initial begin

    #22 preset = 1;
    #20 preset = 0;

    //----------------------------------------------------------------------
    // APB WRITES
    //----------------------------------------------------------------------

    push(5'h15,32'h01010101,1'b1); // invalid address

    push(5'h00,32'h01010101,1'b1); // config

    #4 $display("config : en = %b | tx/rx = %b | parity_en = %b | odd/even = %b | time : %d ",
        dut.regfile[0][0],
        dut.regfile[0][8],
        dut.regfile[0][16],
        dut.regfile[0][24],
        $time);

    push(5'h08,32'h1B2,1'b1); // baud

    #4 $display("baud : div = %d | time = %d ",
        dut.regfile[2][8:0],$time);

    push(5'h0C,32'h11,1'b1);
    push(5'h0C,32'h22,1'b1);
    push(5'h0C,32'h33,1'b1);
    push(5'h0C,32'h44,1'b1);
    push(5'h0C,32'h55,1'b1);
    push(5'h0C,32'h66,1'b1);
    push(5'h0C,32'h77,1'b1);

    //----------------------------------------------------------------------
    // APB READ
    //----------------------------------------------------------------------

    push(5'h10,32'h00,1'b0);

    //----------------------------------------------------------------------
    // UART RX TESTS
    //----------------------------------------------------------------------

    send_uart_frame(8'h11,1,1);
    send_uart_frame(8'hA5,1,1);
    send_uart_frame(8'h55,0,1); // parity error
    send_uart_frame(8'h33,1,0); // framing error
    send_uart_frame(8'h77,1,1);
    send_uart_frame(8'h88,1,1);
    send_uart_frame(8'h99,1,1);

end

endmodule
