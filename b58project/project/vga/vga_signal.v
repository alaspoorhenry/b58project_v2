module vga_signal

    (
        input wire go,
        input wire del,
        input wire clk, reset,
        //input wire ps2d, ps2c,               // ps2 data and clock lines
        output wire [7:0] scan_code,         // scan_code received from keyboard to process
        output wire scan_code_ready,         // signal to outer control system to sample scan_code
        output wire del_code_ready,         // signal to outer control system to sample scan_code
        output wire letter_case_out,          // output to determine if scan code is converted to lower or upper ascii code for a key
        output wire [2:0] state_out          // output to determine if scan code is converted to lower or upper ascii code for a key
    );
    
    // constant declarations
    localparam  BREAK    = 8'hf0, // break code
                SHIFT1   = 8'h12, // first shift scan
                SHIFT2   = 8'h59, // second shift scan
                CAPS     = 8'h58; // caps lock

    // FSM symbolic states
    localparam [4:0]    idle          = 3'b001, // idle, process lower case letters
                        input_press       = 3'b000, // ignore repeated scan code after break code -F0- reeived
                        input_press_wait              = 3'b010, // process uppercase letters for shift key held
						
                        del_press = 3'b011, // check scan code after F0, either idle or go back to uppercase
                        del_press_wait           = 3'b100; // process uppercase letter after capslock button pressed
/*
                        ignore_caps_break  = 3'b101; // check scan code after F0, either ignore repeat, or decrement caps_num
						*/
                     
               
    // internal signal declarations
    reg [2:0] state_reg, state_next;           // FSM state register and next state logic
    wire [7:0] scan_out;                       // scan code received from keyboard
    reg got_code_tick;                         // asserted to write current scan code received to FIFO
    reg del_tick;                         // asserted to write current scan code received to FIFO
    reg go_time;                         // asserted to write current scan code received to FIFO
    wire scan_done_tick;                       // asserted to signal that ps2_rx has received a scan code
    reg letter_case;                           // 0 for lower case, 1 for uppercase, outputed to use when converting scan code to ascii
    reg [7:0] shift_type_reg, shift_type_next; // register to hold scan code for either of the shift keys or caps lock
    reg [1:0] caps_num_reg, caps_num_next;     // keeps track of number of capslock scan codes received in capslock state (3 before going back to lowecase state)
   
    // instantiate ps2 receiver
    //ps2_rx ps2_rx_unit (.clk(clk), .reset(reset), .rx_en(1'b1), .ps2d(ps2d), .ps2c(ps2c), .rx_done_tick(scan_done_tick), .rx_data(scan_out));
    
    // FSM stat, shift_type, caps_num register 
    always @(posedge clk)
    begin: clocker
            state_reg      <= state_next;
            shift_type_reg <= shift_type_next;
            caps_num_reg   <= caps_num_next;
    end
            
    //FSM next state logic
    always @(negedge clk)
    begin
       
        // defaults
        //got_code_tick   = 1'b0;
        del_tick        = 1'b0;
        letter_case     = 1'b0;
        caps_num_next   = caps_num_reg;
        shift_type_next = shift_type_reg;
        state_next      = state_reg;
       
        case(state_reg)
            
            // state to process lowercase key strokes, go to uppercase state to process shift/capslock
            idle:
            begin
                if (~go)
                    begin                                  // else if code is break code
                    state_next <= input_press;
                    got_code_tick <= 1'b1;                                // go to ignore_break state 
                    end
		else
		    got_code_tick <= 1'b0;                                                          // else if code is none of the above...
                                                                             // assert got_code_tick to write scan_out to FIFO
            end
            // state to ignore repeated scan code after break code FO received in lowercase state
            input_press:
            begin                                            // if scan code received, 
                    state_next <= input_press_wait;  
                    got_code_tick <= 1'b0;                                                         // go back to lowercase state
            end
            input_press_wait:
            begin
                if (go)                                  // if scan code received, 
                    state_next <= idle;    
                    got_code_tick <= 1'b0;                                                       // go back to lowercase state
            end
        endcase
    end
    
    // output, route letter_case to output to use during scan to ascii code conversion
    assign letter_case_out = letter_case; 
    
    // output, route got_code_tick to out control circuit to signal when to sample scan_out 
	 /*go_time = 1'b0;
	 always @(negedge go)
	 begin
		if (~go)
			go_time = 1'b1;
		else
			go_time = 1'b0;
	 end
	 */
    assign scan_code_ready = got_code_tick;
    assign del_code_ready = del_tick;
    // route scan code data out
    assign scan_code = scan_out;
   assign state = state_reg;
    
endmodule
