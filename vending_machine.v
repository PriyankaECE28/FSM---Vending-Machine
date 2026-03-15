module vending_machine (
    input clk,
    input reset,
    input quarter,
    input half,
    input dollar,
    input select_coke,
    input select_pepsi,
    input select_water,
    input cancel,
    
    output reg dispense_coke,
    output reg dispense_pepsi,
    output reg dispense_water,
    output reg [7:0] change,
    output reg [7:0] balance,
    output reg [2:0] state_display
);

// State encoding
parameter IDLE = 3'd0;
parameter BALANCE_25 = 3'd1;
parameter BALANCE_50 = 3'd2;
parameter BALANCE_75 = 3'd3;
parameter BALANCE_100 = 3'd4;
parameter DISPENSE = 3'd5;
parameter RETURN = 3'd6;

reg [2:0] state, next_state;
reg [7:0] current_balance;
reg [1:0] product; // 00: coke, 01: pepsi, 10: water

// State register with reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        current_balance <= 8'd0;
        product <= 2'b00;
    end else begin
        state <= next_state;
        
        // Update balance
        if (quarter) current_balance <= current_balance + 8'd25;
        else if (half) current_balance <= current_balance + 8'd50;
        else if (dollar) current_balance <= current_balance + 8'd100;
        else if (cancel || (next_state == DISPENSE)) current_balance <= 8'd0;
        
        // Store product selection
        if (select_coke) product <= 2'b00;
        else if (select_pepsi) product <= 2'b01;
        else if (select_water) product <= 2'b10;
    end
end

// Next state logic
always @(*) begin
    next_state = state;
    dispense_coke = 0;
    dispense_pepsi = 0;
    dispense_water = 0;
    change = 8'd0;
    
    case (state)
        IDLE: begin
            if (quarter) next_state = BALANCE_25;
            else if (half) next_state = BALANCE_50;
            else if (dollar) next_state = BALANCE_100;
        end
        
        BALANCE_25: begin
            if (quarter) next_state = BALANCE_50;
            else if (half) next_state = BALANCE_75;
            else if (dollar) next_state = BALANCE_100;
            else if (cancel) next_state = RETURN;
            else if (select_water && current_balance >= 100) next_state = DISPENSE;
            else if ((select_coke || select_pepsi) && current_balance >= 150) next_state = DISPENSE;
        end
        
        BALANCE_50: begin
            if (quarter) next_state = BALANCE_75;
            else if (half) next_state = BALANCE_100;
            else if (dollar) next_state = BALANCE_100;
            else if (cancel) next_state = RETURN;
            else if (select_water && current_balance >= 100) next_state = DISPENSE;
            else if ((select_coke || select_pepsi) && current_balance >= 150) next_state = DISPENSE;
        end
        
        BALANCE_75: begin
            if (quarter) next_state = BALANCE_100;
            else if (half) next_state = BALANCE_100;
            else if (dollar) next_state = BALANCE_100;
            else if (cancel) next_state = RETURN;
            else if (select_water && current_balance >= 100) next_state = DISPENSE;
            else if ((select_coke || select_pepsi) && current_balance >= 150) next_state = DISPENSE;
        end
        
        BALANCE_100: begin
            if (quarter) next_state = BALANCE_100;
            else if (half) next_state = BALANCE_100;
            else if (dollar) next_state = BALANCE_100;
            else if (cancel) next_state = RETURN;
            else if (select_water && current_balance >= 100) next_state = DISPENSE;
            else if ((select_coke || select_pepsi) && current_balance >= 150) next_state = DISPENSE;
        end
        
        DISPENSE: begin
            if (product == 2'b00) dispense_coke = 1;
            else if (product == 2'b01) dispense_pepsi = 1;
            else dispense_water = 1;
            
            if (product == 2'b10) change = current_balance - 100;
            else change = current_balance - 150;
            
            next_state = RETURN;
        end
        
        RETURN: begin
            next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

// Output assignments
always @(*) begin
    balance = current_balance;
    state_display = state;
end

endmodule
