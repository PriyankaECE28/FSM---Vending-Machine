`timescale 1ns/1ps

module tb_vending_machine_fixed;
    // Testbench signals
    reg clk;
    reg reset;
    reg quarter;
    reg half;
    reg dollar;
    reg select_coke;
    reg select_pepsi;
    reg select_water;
    reg cancel;
    
    wire dispense_coke;
    wire dispense_pepsi;
    wire dispense_water;
    wire [7:0] change;
    wire [7:0] balance;
    wire [2:0] state_display;
    
    // Clock period
    parameter CLK_PERIOD = 10;
    
    // Instantiate the vending machine
    vending_machine uut (
        .clk(clk),
        .reset(reset),
        .quarter(quarter),
        .half(half),
        .dollar(dollar),
        .select_coke(select_coke),
        .select_pepsi(select_pepsi),
        .select_water(select_water),
        .cancel(cancel),
        .dispense_coke(dispense_coke),
        .dispense_pepsi(dispense_pepsi),
        .dispense_water(dispense_water),
        .change(change),
        .balance(balance),
        .state_display(state_display)
    );
    
    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Test scenario names
    parameter [1:0] TEST_COKE_EXACT = 2'd0;
    parameter [1:0] TEST_COKE_OVERPAY = 2'd1;
    parameter [1:0] TEST_WATER_EXACT = 2'd2;
    parameter [1:0] TEST_CANCEL = 2'd3;
    
    reg [1:0] test_scenario;
    
    // Initialize signals and run tests
    initial begin
        $dumpfile("vending_machine_fixed.vcd");
        $dumpvars(0, tb_vending_machine_fixed);
        
        // Initialize all signals at time 0
        clk = 0;
        reset = 1;        // Active high reset
        quarter = 0;
        half = 0;
        dollar = 0;
        select_coke = 0;
        select_pepsi = 0;
        select_water = 0;
        cancel = 0;
        
        // Display header
        $display("==========================================================");
        $display("VENDING MACHINE FSM TESTBENCH (FIXED)");
        $display("==========================================================");
        $display("Time\tState\tBalance\tAction\t\t\tResult");
        $display("==========================================================");
        
        // Hold reset for 20ns to initialize everything
        #20;
        $display("%0t\t%d\t$%0.2f\tReset complete\t\tInitialized", 
                 $time, state_display, balance/100.0);
        
        // Release reset
        reset = 0;
        #10;
        
        // Now run your test scenarios...
        // [Rest of your test code from original testbench]
        
        // Test Scenario 1: Buy Coke with exact change
        $display("\n[TEST 1] Buying Coke with exact change (6 quarters = $1.50)");
        
        // Insert 6 quarters
        repeat(6) begin
            quarter = 1;
            #10;
            quarter = 0;
            #10;
            $display("%0t\t%d\t$%0.2f\tQuarter inserted\tBalance: $%0.2f", 
                     $time, state_display, balance/100.0, balance/100.0);
        end
        
        // Select Coke
        select_coke = 1;
        #10;
        select_coke = 0;
        #20;
        
        $display("%0t\t%d\t$%0.2f\tDispensing Coke\t\tChange: $%0.2f", 
                 $time, state_display, balance/100.0, change/100.0);
        
        // Wait between tests
        #50;
        
        // Test Scenario 2: Buy Coke with overpayment
        $display("\n[TEST 2] Buying Coke with overpayment ($2.00)");
        
        // Reset for next test
        reset = 1;
        #20;
        reset = 0;
        #10;
        
        // Insert $2.00
        repeat(2) begin
            dollar = 1;
            #10;
            dollar = 0;
            #10;
            $display("%0t\t%d\t$%0.2f\tDollar inserted\t\tBalance: $%0.2f", 
                     $time, state_display, balance/100.0, balance/100.0);
        end
        
        // Select Coke
        select_coke = 1;
        #10;
        select_coke = 0;
        #20;
        
        $display("%0t\t%d\t$%0.2f\tDispensing Coke\t\tChange: $%0.2f", 
                 $time, state_display, balance/100.0, change/100.0);
        
        #50;
        $finish;
    end
    
endmodule
