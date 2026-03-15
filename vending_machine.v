/**
 * Finite State Machine for a Vending Machine
 */

module vending_machine (
    input clk,                    // Clock signal
    input reset,                  // Reset signal
    input quarter,                 // 0.25 coin inserted
    input half,                    // 0.50 coin inserted
    input dollar,                  // 1.00 coin inserted
    input select_coke,             // Select Coke button
    input select_pepsi,            // Select Pepsi button
    input select_water,            // Select Water button
    input cancel,                   // Cancel transaction
    
    output reg dispense_coke,      // Dispense Coke signal
    output reg dispense_pepsi,     // Dispense Pepsi signal
    output reg dispense_water,     // Dispense Water signal
    output reg [7:0] change,       // Change amount (in cents)
    output reg [7:0] balance,      // Current balance (in cents)
    output reg [2:0] state_display  // Current state for display
);

// State encoding (One-hot encoding for easier synthesis)
parameter [4:0] IDLE        = 5'b00001;
parameter [4:0] BALANCE_25  = 5'b00010;
parameter [4:0] BALANCE_50  = 5'b00100;
parameter [4:0] BALANCE_75  = 5'b01000;
parameter [4:0] BALANCE_100 = 5'b10000;
parameter [4:0] BALANCE_125 = 5'b00001;  // Additional states for higher balances
parameter [4:0] BALANCE_150 = 5'b00010;
parameter [4:0] BALANCE_175 = 5'b00100;
parameter [4:0] BALANCE_200 = 5'b01000;

// Additional states for product selection
parameter [4:0] DISPENSE    = 5'b10000;
parameter [4:0] RETURN_CHANGE = 5'b00001;

// State and next state registers
reg [4:0] current_state, next_state;

// Coin values in cents
parameter QUARTER_VAL = 25;
parameter HALF_VAL = 50;
parameter DOLLAR_VAL = 100;

// Product prices in cents
parameter COKE_PRICE = 150;
parameter PEPSI_PRICE = 150;
parameter WATER_PRICE = 100;

// Internal signals
wire coin_inserted;
reg [7:0] current_balance;
reg product_selected;
reg [1:0] selected_product;  // 00: Coke, 01: Pepsi, 10: Water

// Coin insertion detection
assign coin_inserted = quarter | half | dollar;

// Sequential logic for state transitions
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        current_balance <= 0;
        selected_product <= 2'b00;
    end else begin
        current_state <= next_state;
        
        // Update balance based on coin insertion
        if (coin_inserted && !cancel) begin
            if (quarter) current_balance <= current_balance + QUARTER_VAL;
            if (half) current_balance <= current_balance + HALF_VAL;
            if (dollar) current_balance <= current_balance + DOLLAR_VAL;
        end else if (cancel || product_selected) begin
            current_balance <= 0;  // Reset balance after cancel or purchase
        end
        
        // Store product selection
        if (select_coke) selected_product <= 2'b00;
        else if (select_pepsi) selected_product <= 2'b01;
        else if (select_water) selected_product <= 2'b10;
    end
end

// Combinational logic for next state and outputs
always @(*) begin
    // Default values
    next_state = current_state;
    dispense_coke = 0;
    dispense_pepsi = 0;
    dispense_water = 0;
    change = 0;
    product_selected = 0;
    
    case (current_state)
        IDLE: begin
            if (quarter) next_state = BALANCE_25;
            else if (half) next_state = BALANCE_50;
            else if (dollar) next_state = BALANCE_100;
            else if (cancel) next_state = IDLE;
        end
        
        BALANCE_25: begin
            if (quarter) next_state = BALANCE_50;
            else if (half) next_state = BALANCE_75;
            else if (dollar) next_state = BALANCE_125;
            else if (select_water && current_balance >= WATER_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                selected_product = 2'b10;
            end
            else if ((select_coke || select_pepsi) && current_balance >= COKE_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                if (select_coke) selected_product = 2'b00;
                else selected_product = 2'b01;
            end
            else if (cancel) next_state = RETURN_CHANGE;
        end
        
        BALANCE_50: begin
            if (quarter) next_state = BALANCE_75;
            else if (half) next_state = BALANCE_100;
            else if (dollar) next_state = BALANCE_150;
            else if (select_water && current_balance >= WATER_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                selected_product = 2'b10;
            end
            else if ((select_coke || select_pepsi) && current_balance >= COKE_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                if (select_coke) selected_product = 2'b00;
                else selected_product = 2'b01;
            end
            else if (cancel) next_state = RETURN_CHANGE;
        end
        
        BALANCE_75: begin
            if (quarter) next_state = BALANCE_100;
            else if (half) next_state = BALANCE_125;
            else if (dollar) next_state = BALANCE_175;
            else if (select_water && current_balance >= WATER_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                selected_product = 2'b10;
            end
            else if ((select_coke || select_pepsi) && current_balance >= COKE_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                if (select_coke) selected_product = 2'b00;
                else selected_product = 2'b01;
            end
            else if (cancel) next_state = RETURN_CHANGE;
        end
        
        BALANCE_100: begin
            if (quarter) next_state = BALANCE_125;
            else if (half) next_state = BALANCE_150;
            else if (dollar) next_state = BALANCE_200;
            else if (select_water && current_balance >= WATER_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                selected_product = 2'b10;
            end
            else if ((select_coke || select_pepsi) && current_balance >= COKE_PRICE) begin
                next_state = DISPENSE;
                product_selected = 1;
                if (select_coke) selected_product = 2'b00;
                else selected_product = 2'b01;
            end
            else if (cancel) next_state = RETURN_CHANGE;
        end
        
        DISPENSE: begin
            // Dispense selected product
            case (selected_product)
                2'b00: dispense_coke = 1;
                2'b01: dispense_pepsi = 1;
                2'b10: dispense_water = 1;
            endcase
            
            // Calculate change if overpaid
            if (selected_product == 2'b10) // Water
                change = current_balance - WATER_PRICE;
            else // Coke or Pepsi
                change = current_balance - COKE_PRICE;
            
            next_state = RETURN_CHANGE;
        end
        
        RETURN_CHANGE: begin
            // Return to idle after dispensing change
            next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

// Update balance output
always @(*) begin
    balance = current_balance;
end

// State display for debugging
always @(*) begin
    case (current_state)
        IDLE: state_display = 3'd0;
        BALANCE_25: state_display = 3'd1;
        BALANCE_50: state_display = 3'd2;
        BALANCE_75: state_display = 3'd3;
        BALANCE_100: state_display = 3'd4;
        DISPENSE: state_display = 3'd5;
        RETURN_CHANGE: state_display = 3'd6;
        default: state_display = 3'd0;
    endcase
end

endmodule
