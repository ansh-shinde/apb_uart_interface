# APB UART Peripheral (Verilog HDL)

## Overview

This project implements an **AMBA APB-compliant UART peripheral** in Verilog HDL. The design integrates a configurable UART transmitter and receiver with APB slave interface logic, enabling seamless communication between a processor and UART peripheral in an SoC environment.

The UART supports configurable baud rate generation, FIFO buffering, interrupt generation, hardware flow control, and UART error detection.

---

## Features

- AMBA APB Slave Interface
- UART Transmitter and Receiver
- Configurable Control and Status Registers
- Separate TX and RX FIFOs
- Programmable Baud Rate Generator
- RTS/CTS Hardware Flow Control
- RX and TX Interrupt Generation
- Parity Error Detection
- Framing Error Detection
- Overrun Error Detection
- Synthesizable RTL Design
- Verification Testbench with Multiple UART Scenarios

---

## Architecture

```text
                    +--------------------+
                    |      CPU / AHB     |
                    +----------+---------+
                               |
                        +------+------+
                        | AHB-APB     |
                        |   Bridge    |
                        +------+------+
                               |
                         AMBA APB Bus
                               |
            +----------------------------------+
            |          APB UART Slave          |
            |                                  |
            |  +----------------------------+  |
            |  |      APB Register Bank     |  |
            |  +----------------------------+  |
            |                                  |
            |  +------------+ +------------+  |
            |  | UART TX    | | UART RX    |  |
            |  | with FIFO  | | with FIFO  |  |
            |  +------------+ +------------+  |
            |                                  |
            |  +----------------------------+  |
            |  | Interrupt & Flow Control  |  |
            |  +----------------------------+  |
            +----------------------------------+
```

---

## Register Map

| Address | Register | Description |
|----------|----------|-------------|
| `0x00` | Control Register | UART configuration |
| `0x04` | Status Register | Error and status information |
| `0x08` | Baud Register | Baud-rate divisor configuration |
| `0x0C` | TX Data Register | Data to be transmitted |
| `0x10` | RX Data Register | Received data |

---

## Control Register (0x00)

| Bit | Description |
|-----|-------------|
| `[0]` | TX Enable |
| `[8]` | RX Enable |
| `[16]` | Parity Enable |
| `[24]` | Parity Type (`0`: Even, `1`: Odd) |

---

## Status Register (0x04)

| Bit | Description |
|-----|-------------|
| `[0]` | Parity Error |
| `[8]` | Frame Error |
| `[16]` | Overrun Error |
| `[24]` | TX Busy |

---

## APB Interface Signals

| Signal | Direction | Description |
|---------|----------|-------------|
| `PCLK` | Input | APB Clock |
| `PRESET` | Input | Reset |
| `PSEL` | Input | Peripheral Select |
| `PENABLE` | Input | Transfer Enable |
| `PWRITE` | Input | Read/Write Control |
| `PADDR` | Input | Address Bus |
| `PWDATA` | Input | Write Data |
| `PRDATA` | Output | Read Data |
| `PREADY` | Output | Transfer Completion |
| `PSLVERR` | Output | Slave Error Response |

---

## UART Interface Signals

| Signal | Direction | Description |
|---------|----------|-------------|
| `TX` | Output | Serial Transmit Line |
| `RX` | Input | Serial Receive Line |
| `CTS` | Input | Clear To Send |
| `RTS` | Output | Request To Send |

---

## Interrupts

### RX Interrupt (`intrr_rx`)

Generated when the RX FIFO becomes nearly full.

### TX Interrupt (`intrr_tx`)

Generated when the TX FIFO becomes nearly empty.

---

## Hardware Flow Control

The design supports UART hardware flow control using:

- **RTS (Request To Send)**
- **CTS (Clear To Send)**

Transmission is enabled only when:

```text
CTS = 1 AND TX Enable = 1
```

Reception is enabled only when:

```text
RTS = 1 AND RX Enable = 1
```

---

## Error Handling

### Parity Error

Raised when the received parity bit does not match the expected parity.

### Framing Error

Raised when the stop bit is invalid.

### Overrun Error

Raised when new data arrives while the RX FIFO is full.

---

## Verification

The design has been verified using a Verilog testbench covering:

- APB Register Read/Write
- UART Transmission
- UART Reception
- Baud Rate Configuration
- FIFO Operations
- RTS/CTS Flow Control
- Normal UART Frames
- Back-to-Back Frames
- Parity Error Frames
- Framing Error Frames
- Interrupt Generation

---

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave

---

## Simulation

### Compile

```bash
iverilog -o sim *.v tb/tb.v
```

### Run

```bash
vvp sim
```

### View Waveforms

```bash
gtkwave apb_uart.vcd
```

---

## Future Improvements

- APB4 Support
- Configurable FIFO Depth
- DMA Support
- Timeout Interrupt
- Break Detection
- SystemVerilog/UVM Verification

---

## Author

**Ansh Shinde**  
