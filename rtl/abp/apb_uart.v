module apb_uart( 
    input            preset,
    input            pclk,
    // APB control signals
    input            penable,
    input            pwrite,
    input            psel,
    // APB addess and data
    input  [5:0]    paddr,
    input  [31:0]   pwdata,
    // APB response signals
    output  reg         pready,
    output  reg         pslverr,
    output  reg [31:0]  prdata,
    // UART signals
    input           rx,
    input           cts,
    output   reg    rts,
    output          tx
);
    // 8 registers of 32 bit width
    // address range 0x00 - 0x1F
    // byte addressable memory 
    // control_reg: 0x00
    // status_reg : 0x04
    // baud_reg   : 0x08
    // data_reg_tx: 0x0C
    // data_reg_rx: 0x10
    reg [31:0]regfile[7:0];

    // For byte addressable memory
    wire [2:0]reg_no;
    integer i;

    
    wire parity_err, 
         frame_err, 
         overrun_err, 
         busy_tx;

    wire nr_full_tx,
         nr_empty_tx,
         full_tx,
         nr_full_rx,
         nr_empty_rx;

    wire [8:0]baud_uart;

    wire [7:0] data_out_rx,
               data_in_tx;

    wire parity_en_uart,
         parity_odd_uart,
         enable_uart,
         tx_rx_mode;

    top_tx transmitter(
           .clk(pclk),
           .wr(pwrite),
           .en(penable),
           .rst(preset),
           .tx(tx),
           .full(full_tx),
           .nr_full(nr_full_tx),
           .parity_en(parity_en_uart),
           .parity_odd(parity_odd_uart),
           .nr_empty(nr_empty_tx),
           .div(baud_uart),
           .data_in(data_in_tx) 
    );

    top_rx receiver(
             .clk(pclk),
             .rst(preset),
             .en(penable),
             .rx(rx),
             .parity_en(parity_en_uart),
             .parity_odd(parity_odd_uart),
             .div(baud_uart),
             .data_out(data_out_rx),
             .frame_error(frame_err),
             .parity_error(parity_err),
             .nr_full(nr_full_rx),
             .nr_empty(nr_empty_rx),
             .overrun_error(overrun_err)
            );

    assign reg_no=paddr[5:2];

//=====================================================================================
// this block checks if preset is on and resets
// if psel is active then read/write takes place depending on pwrite
// before setting pready checks if tx fifo is nearly full to stop and
// wait for tx to finish transmitting
//======================================================================================

    always@(posedge pclk or posedge preset)begin  
        if (preset) begin
            for(i=0;i<8;i=i+1)begin
                regfile[i]<=32'b0;
                pready<=0;
                pslverr<=0;
            end
        end
        else if (psel && (paddr<=5'h13) begin
            if(!nr_full_tx)begin
            pready<=1;
            pslverr<=0;
            if (psel && penable && pwrite) begin
                regfile[reg_no]<=pwdata;
                pready<=1;
            end
            else if(psel && penable && !pwrite)begin
                prdata<=regfile[reg_no];
                pready<=1;
            end
            end
            else pready<=0;
        end
        else if (psel && !((paddr<=5'h13)) begin
            pready<=0;
            pslverr<=1;
        end
        end


//============================================================================================
// This block connects the regs to ports of Uart tx and rx through wires 
//=============================================================================================

    assign  enable_uart     = regfile[0][0]; 
    assign  tx_rx_mode      = regfile[0][8]; 
    assign  parity_en_uart  = regfile[0][16]; 
    assign  parity_odd_uart = regfile[0][24]; 
    assign  baud_uart       = regfile[3][8:0]; 
    assign  data_in_tx      = regfile[4][7:0]; 

    always@(posedge pclk)begin
        if (psel && penable) begin
            regfile[1][0]     = parity_err;
            regfile[1][8]     = frame_err;
            regfile[1][16]    = overrun_err;
            regfile[1][24]    = busy_tx;
            regfile[5][7:0]   = data_out_rx;
        end
    end


//======================================================================================================
// This block checks the near full of receiver and generates request to send
//========================================================================================================

    always@(posedge pclk or posedge preset)begin
        if (preset) begin
            rts<=0;
        end
        else if (penable) begin
            if (nr_full_rx) begin
                rts=0;
            end
            else rts=1;
        end
    end


endmodule
