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
    
    // Test procedure
    initial begin
        // Create VCD file for GTKWave
        $dumpfile("vending_machine_fixed.vcd");
        $dumpvars(0, tb_vending_machine_fixed);
        
        // Initialize all signals at time 0
        clk = 0;
        reset = 1;        // Start with reset active
        quarter = 0;
        half = 0;
        dollar = 0;
        select_coke = 0;
        select_pepsi = 0;
        select_water = 0;
        cancel = 0;
        
        // Display header
        $display("==========================================================");
        $display("VENDING MACHINE FSM TESTBENCH");
        $display("==========================================================");
        $display("Time\tState\tBalance\tAction");
        $display("==========================================================");
        
        // Hold reset for 20ns to initialize everything
        #20;
        $display("%0t\t%d\t$%0.2f\tReset released", 
                 $time, state_display, balance/100.0);
        
        // Release reset
        reset = 0;
        #10;
        
        // TEST 1: Insert 2 quarters ($0.50)
        $display("\n--- TEST 1: Insert 2 quarters ---");
        quarter = 1; #10; quarter = 0; #10;
        $display("%0t\t%d\t$%0.2f\tQuarter inserted", 
                 $time, state_display, balance/100.0);
        
        quarter = 1; #10; quarter = 0; #10;
        $display("%0t\t%d\t$%0.2f\tQuarter inserted", 
                 $time, state_display, balance/100.0);
        
        // TEST 2: Insert $1.00 more (total $1.50 - enough for Coke)
        $display("\n--- TEST 2: Insert dollar for Coke ---");
        dollar = 1; #10; dollar = 0; #10;
        $display("%0t\t%d\t$%0.2f\tDollar inserted", 
                 $time, state_display, balance/100.0);
        
        // Select Coke
        $display("\n--- TEST 3: Select Coke ---");
        select_coke = 1; #10; select_coke = 0; #20;
        $display("%0t\t%d\t$%0.2f\tCoke selected - Dispensing", 
                 $time, state_display, balance/100.0);
        $display("Change: $%0.2f", change/100.0);
        
        // Wait a bit
        #30;
        
        // TEST 4: Test cancel functionality
        $display("\n--- TEST 4: Test Cancel ---");
        reset = 1; #20; reset = 0; #10;
        $display("%0t\t%d\t$%0.2f\tReset complete", 
                 $time, state_display, balance/100.0);
        
        // Insert some coins
        quarter = 1; #10; quarter = 0; #10;
        $display("%0t\t%d\t$%0.2f\tQuarter inserted", 
                 $time, state_display, balance/100.0);
        
        half = 1; #10; half = 0; #10;
        $display("%0t\t%d\t$%0.2f\tHalf dollar inserted", 
                 $time, state_display, balance/100.0);
        
        // Cancel transaction
        $display("\n--- TEST 5: Cancel transaction ---");
        cancel = 1; #10; cancel = 0; #20;
        $display("%0t\t%d\t$%0.2f\tTransaction cancelled", 
                 $time, state_display, balance/100.0);
        
        #30;
        
        $display("\n==========================================================");
        $display("All tests completed!");
        $display("==========================================================");
        
        $finish;
    end
    
    // Monitor state changes
    always @(state_display) begin
        $display("  State changed to %d at time %0t", state_display, $time);
    end

endmodule
