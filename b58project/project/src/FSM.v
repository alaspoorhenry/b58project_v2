
module FSM
        (
        input clk,   // CLOCK_50
        input reset, // reset input to reset FSM back to state 1 (S_KEY0)
        input enter, // input for switching states
        output reg [2:0] STATE // outputting state to be used by datapath
        );
	
	reg [2:0] current_state, next_state; 	// regs for storing next_state for loading into current_state on posedge clock

	// initializing state to this value
    initial
    begin
        STATE <= 3'd0;
    end

	// listing out our states (3 flip flops)
	localparam S_START      = 3'd0,
		   S_KEY0 	= 3'd1,
		   S_KEY1 	= 3'd2,
		   S_KEY2 	= 3'd3,
		   S_KEY3 	= 3'd4,
		   S_ENCR 	= 3'd5;


	// state transition "table" given current state
	always@(posedge enter)
	begin: state_table
		case (current_state)
			S_START: next_state =  S_KEY0;
			S_KEY0: next_state = S_KEY1;
			S_KEY1: next_state = S_KEY2;
			S_KEY2: next_state = S_KEY3;
			S_KEY3: next_state = S_ENCR;
         S_ENCR: next_state = S_START;
			default: next_state = S_START;
		endcase
	end


	// assigns state to nothing (???)
	always @(*)
	    begin: enable_signals
		// default to nothing		
		// STATE <= 3'd0;
		case (current_state)
		   default: STATE <= current_state;
		endcase
	    end

	
	always@(posedge clk)
        begin: state_FFs
	    // resets current state to S_START given negative reset value (active low)
	    if(!reset)
			  begin
				  current_state <= S_START;
				  //next_state <= 1'b0;	
			  end
		 else
		// otherwise assign current state to next_state, with next_state assigned in state table above
	        current_state <= next_state;
       end // state_FFS

endmodule

module Datapath
        (
        input [2:0] STATE, // input what the current state is (output of FSM)
        input keyboard_clk, // clock from keyboard so Datapath does function on input from KB
        input [7:0] keyboard_char, // ASCII 8-bit input for character inputted via keyboard
        output reg [7:0] VGA_char, // 8-bit ASCII character output for the VGA to display
        output reg VGA_DISPLAY_CLOCK, // clock for driving the VGA to display

	output [1:0] CIPHER_IDX // keeps track of index of which key to use to encrypt
        );

	reg [31:0] key_reg; // 

	// used to shift cipher key; half the rate of keyboard_clk
	reg CIPHER_SHIFT_CLOCK;
		
	localparam SPC_ASCII_CHAR = 8'd32; // keeps local variable specifically for input of spacebar

	// initializing outputs VGA_char and VGA_DISPLAY_CLOCK to space and 0 respectively
	// also initializing CIPHER_SHIFT_CLOCK and VGA_DISPLAY_CLOCK to 0 (these are inputs for the vig. cipher module)
	initial 
	begin
		CIPHER_SHIFT_CLOCK <= 1'b0;
		VGA_DISPLAY_CLOCK <= 1'b0;
		key_reg <= 32'b0;
		VGA_char <= SPC_ASCII_CHAR; //default is space					
	end

	// local variables to label states with their FF assignments
	localparam S_START  = 3'd0,
		   S_KEY0   = 3'd1, 
		   S_KEY1   = 3'd2, 
		   S_KEY2   = 3'd3, 
		   S_KEY3   = 3'd4,
		   S_ENCR   = 3'd5;

	// wire for connecting to output (VGA_char)
	wire [7:0] Char_out;
	
	// initialzing vigenere cipher with 
	// KEY increments twice for every button

	vigenere_cipher CIPHER(.key_arr(key_reg), // inputs key array as a 32-bit register
							.char_in(keyboard_char), // 8-bit ASCII character input to encrypt
							.char_out(Char_out),  // 8-bit ASCII character to output after encryption
							.keyboard_clk(CIPHER_SHIFT_CLOCK), // keyboard clock for driving module
							.IDX_out(CIPHER_IDX)); // outputs index of next key character
	
	// state table	
	always @(posedge keyboard_clk)
	begin

		case(STATE)
			S_START: 
				begin			
					key_reg <= 31'd0; // defaults the 32-bit key register (for storing 4 character key) to nothing on S_START
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state
				end			
			S_KEY0:
				begin			
					key_reg[7:0] <= keyboard_char; // assigns values to 32-bit key register (first character)
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state
				end			
			S_KEY1:
				begin			
					key_reg[15:8] <= keyboard_char; // assigns values to 32-bit key register (second character)
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state
				end			
			S_KEY2:
				begin			
					key_reg[23:16] <= keyboard_char; // assigns values to 32-bit key register (third character)
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state
				end			
			S_KEY3:
				begin			
					key_reg[31:24] <= keyboard_char; // assigns values to 32-bit key register (fourth character)
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state	
				end			
			S_ENCR: 
				begin
					VGA_char <= Char_out; // sets output VGA_char to Char_out wire
					VGA_DISPLAY_CLOCK <= 1'b1;	// sets clock to 1 to display encrypted key to VGA
				end
			default:
				// basically defaults to what is being done in S_START state
				begin
					key_reg <= 31'd0;
					VGA_DISPLAY_CLOCK <= 1'b0; // sets clock to 0 to prevent displaying on this state	
				end
		endcase
                CIPHER_SHIFT_CLOCK <= ~CIPHER_SHIFT_CLOCK; // toggles keyboard_clk input for vig. cipher to negative
	end
endmodule

