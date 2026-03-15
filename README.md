🏭 FSM-Based Vending Machine Controller
A complete Finite State Machine (FSM) implementation of a vending machine controller using Verilog HDL. This project demonstrates the practical application of FSM design in digital systems, including coin handling, product dispensing, and change calculation.

📋 Project Description
This project implements a fully functional vending machine controller using Finite State Machine methodology. The design accepts multiple coin types, tracks the current balance, allows product selection, dispenses products when sufficient payment is received, and returns change when overpaid. The FSM handles various scenarios including exact payment, overpayment, and transaction cancellation.

Key Features:
Multiple Coin Acceptance: Quarter ($0.25), Half Dollar ($0.50), Dollar ($1.00)
Multiple Products: Coke ($1.50), Pepsi ($1.50), Water ($1.00)
Smart Functionality: Exact payment, change return, cancel transaction
Real-time Balance Tracking: 8-bit register for current balance
Synchronous Design: Positive edge-triggered with active-high reset

🎯 Finite State Machine Design
State Diagram
                    ┌─────────────┐
                    │    IDLE     │
                    │   (0¢)      │
                    └──────┬──────┘
                           │ Coin Inserted
                           ↓
                    ┌─────────────┐
                    │  BALANCE_25 │◄─────┐
                    │   (25¢)     │      │
                    └──────┬──────┘      │
                           │ Coin        │ Coin
                           ↓             │
                    ┌─────────────┐      │
                    │  BALANCE_50 │──────|
                    │   (50¢)     │
                    └──────┬──────┘
                           │ Coin
                           ↓
                    ┌─────────────┐
                    │  BALANCE_75 │
                    │   (75¢)     │
                    └──────┬──────┘
                           │ Coin
                           ↓
                    ┌─────────────┐
                    │ BALANCE_100 │
                    │   ($1.00)   │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
         Select       Select        Cancel
         Water      Coke/Pepsi        │
         ($1.00)     ($1.50)          │
              ↓            ↓            ↓
        ┌─────────┐  ┌─────────┐  ┌─────────┐
        │DISPENSE │  │DISPENSE │  │ RETURN  │
        │ Water   │  │ Coke/   │  │ CHANGE  │
        └────┬────┘  │ Pepsi   │  └────┬────┘
             │       └────┬────┘       │
             └────────────┼────────────┘
                          ↓
                    ┌─────────────┐
                    │    IDLE     │
                    └─────────────┘

State Encoding :-
State	           Value	            Description
IDLE	           3'b000	            Waiting for coins
BALANCE_25	     3'b001	            $0.25 inserted
BALANCE_50	     3'b010	            $0.50 inserted
BALANCE_75	     3'b011	            $0.75 inserted
BALANCE_100	     3'b100	            $1.00 inserted
DISPENSE	       3'b101	            Dispensing product
RETURN	         3'b110	            Returning change

🛠️ Tools Required
Icarus Verilog - for simulation
GTKWave - for waveform viewing
Yosys - for synthesis and gate-level netlist generation
