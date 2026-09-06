# UART Transmitter and Receiver Design in Verilog

## Overview

This repository presents the RTL design and simulation-based verification of a UART (Universal Asynchronous Receiver/Transmitter) communication system implemented using Verilog HDL.

The project consists of independently developed UART Transmitter and Receiver modules. The design supports 8-bit serial communication with start-bit detection, parity handling, stop-bit processing, and transmission/reception completion signaling.

The modules are implemented using Finite State Machines (FSMs) and verified using dedicated Verilog testbenches in ModelSim.

---

## Design Specifications

| Parameter | Specification |
|---|---|
| System Clock | 3.125 MHz |
| Baud Rate | Approximately 115200 bps |
| Data Width | 8 bits |
| Start Bit | 1 |
| Parity Bit | 1 |
| Stop Bit | 1 |
| Bit Timing | 27 Clock Cycles |
| Design Methodology | FSM-Based RTL Design |

The UART bit timing is based on:

```text
3.125 MHz / 115200 bps ≈ 27 clock cycles per bit
```

---

## UART Frame Format

```text
Start Bit | 8-bit Data | Parity Bit | Stop Bit
    0     |    D[7:0]  |      P     |    1
```

---

## UART Transmitter

The UART Transmitter converts 8-bit parallel input data into a serial UART data stream.

### Inputs

| Signal | Description |
|---|---|
| `clk_3125` | 3.125 MHz system clock |
| `parity_type` | Selects the parity type |
| `tx_start` | Initiates data transmission |
| `data[7:0]` | 8-bit input data |

### Outputs

| Signal | Description |
|---|---|
| `tx` | Serial UART transmission output |
| `tx_done` | Indicates completion of transmission |

### Operation

The transmitter is implemented using the following FSM:

```text
IDLE → START_BIT → DATA_BITS → PARITY_BIT → STOP_BIT
```

The transmission process consists of:

1. Waiting for the `tx_start` signal.
2. Generating the start bit.
3. Serially transmitting the 8-bit input data.
4. Generating the parity bit.
5. Generating the stop bit.
6. Asserting `tx_done` after completion of the UART frame.

The transmitter supports parity selection through the `parity_type` input.

---

## UART Receiver

The UART Receiver reconstructs 8-bit parallel data from the incoming serial UART stream.

### Inputs

| Signal | Description |
|---|---|
| `clk_3125` | 3.125 MHz system clock |
| `rx` | Serial UART receive input |

### Outputs

| Signal | Description |
|---|---|
| `rx_msg[7:0]` | Received 8-bit data |
| `rx_parity` | Received parity bit |
| `rx_complete` | Indicates completion of data reception |

### Operation

The receiver is implemented using the following FSM:

```text
INIT → IDLE → START → DATA → PARITY → STOP
```

The receiver performs the following operations:

- Detects the incoming start bit.
- Validates the start bit using mid-bit sampling.
- Receives and reconstructs the 8-bit serial data.
- Captures the received parity bit.
- Verifies the parity of the received data.
- Generates the `rx_complete` signal after processing the received frame.

If a parity mismatch is detected, the receiver outputs:

```text
8'h3F
```

which corresponds to the ASCII character `?`.

---

## Verification

The UART Transmitter and Receiver were verified independently using dedicated Verilog testbenches.

The verification environment performs:

- Generation of the 3.125 MHz simulation clock.
- File-based test data input using `data.txt`.
- UART frame generation and validation.
- Serial data verification.
- Parity verification.
- `tx_done` signal verification.
- `rx_complete` signal verification.
- Automatic error detection and counting.

Expected outputs are compared with the actual DUT outputs throughout the simulation.

The final verification result is written to:

```text
results.txt
```

The simulation reports either:

```text
No Errors
```

or:

```text
Errors
```

based on the verification results.

---


## Tools Used

- Verilog HDL
- Intel Quartus Prime Lite 20.1
- ModelSim Intel FPGA Edition

---

## Key Concepts Demonstrated

- UART Communication Protocol
- Finite State Machine Design
- RTL Design using Verilog
- Serial Data Transmission and Reception
- Baud-Rate Timing
- Start-Bit Detection
- Mid-Bit Sampling
- Parity Generation and Verification
- Self-Checking Testbenches
- File-Based Simulation
- Automated Error Detection

---

## Results

The UART Transmitter and Receiver were implemented and verified through simulation-based testing.

The verification environment evaluates UART frame generation, serial data transfer, parity handling, timing behavior, and completion signals using automated comparison between expected and actual outputs.

---

## Author

**P. Bhavitha**  
B.Tech, Electronics and Communication Engineering  
PDPM IIITDM Jabalpur
