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

always #5 pclk= ~pclk;

task push;
    input [4:0]address;
    input [31:0]data;
    begin
        paddr=address;
        pwdata=data;
    end
endtask

initial begin
    pclk=0;
    preset=0;
    penable=0;
    pwrite=0;
    psel=0;
    rx=0;
    cts=1;
    paddr=6'h00;
    pwdata=32'h00000000;
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
   #400000 $finish;
end

initial begin
    #22 preset=1;
    #20 preset=0;
    #20 psel=1; 
    #20 penable=1;
    #10 pwrite=1;
    #20 push(5'h15,32'h01010101); // invalid address 
    #20 push(5'h00,32'h01010101); // en=1, tx/rx=1(tx on), parity_en=1, odd/even=1
    #4 $display("config : en = %b | tx/rx = %b | parity_en = %b | odd/even = %b | time : %d ",dut.regfile[0][0],dut.regfile[0][8],dut.regfile[0][16],dut.regfile[0][24],$time);
    #17 push(5'h08,32'h1B2);      // baud rate set to 115200
    #4 $display("baud : div = %d | time = %d ",dut.regfile[3][8:0],$time);
    #15  push(5'h0C,32'h11);       // data for transmission
    #10  push(5'h0C,32'h22);
    #10  push(5'h0C,32'h33);
    #10  push(5'h0C,32'h44);
    #10  push(5'h0C,32'h55);
    #10  push(5'h0C,32'h66);
    #10  push(5'h0C,32'h77);
    #20   penable=0;

end
    

endmodule


