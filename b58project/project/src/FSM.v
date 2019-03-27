
module FSM
        (
        input clk,   // CLOCK_50
        input reset,
        input enter,
        output reg [2:0] STATE
        );
	
	reg [2:0] current_state, next_state; 	

    initial
    begin
        STATE <= 3'd0;
    end

	localparam S_START      = 3'd0,
		   S_KEY0 	= 3'd1,
		   S_KEY1 	= 3'd2,
		   S_KEY2 	= 3'd3,
		   S_KEY3 	= 3'd4,
		   S_ENCR 	= 3'd5;

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
	    //
	    if(!reset)
			  begin
				  current_state <= S_START;
				  //next_state <= 1'b0;	
			  end
		 else
	        current_state <= next_state;
       end // state_FFS

endmodule

module Datapath
        (
        input [2:0] STATE,
        input keyboard_clk,
        input [7:0] keyboard_char,
        output reg [7:0] VGA_char,
        output reg VGA_DISPLAY_CLOCK,

	output [1:0] CIPHER_IDX
        );

	reg [31:0] key_reg;

	// used to shift cipher key; half the rate of keyboard_clk
	reg CIPHER_SHIFT_CLOCK;
		
	localparam SPC_ASCII_CHAR = 8'd32;

	initial
	begin
		CIPHER_SHIFT_CLOCK <= 1'b0;
		VGA_DISPLAY_CLOCK <= 1'b0;
		key_reg <= 32'b0;
		VGA_char <= SPC_ASCII_CHAR; //default is space					
	end

	localparam S_START  = 3'd0,
		   S_KEY0   = 3'd1, 
		   S_KEY1   = 3'd2, 
		   S_KEY2   = 3'd3, 
		   S_KEY3   = 3'd4,
		   S_ENCR   = 3'd5;

	wire [7:0] Char_out;
	
	// caesar_cipher CIPHER(.char_in(keyboard_char), .char_out(Char_out), .key(key_reg));

	// vigenere_cipher CIPHER(.key_arr(key_reg), .char_in(keyboard_char), .char_out(Char_out), .keyboard_clk(keyboard_clk));
	// KEY increments twice for every button

	vigenere_cipher CIPHER(.key_arr(key_reg), .char_in(keyboard_char), .char_out(Char_out), .keyboard_clk(CIPHER_SHIFT_CLOCK), .IDX_out(CIPHER_IDX));

	
	always @(posedge keyboard_clk)
	begin
                CIPHER_SHIFT_CLOCK <= ~CIPHER_SHIFT_CLOCK;
		case(STATE)
			S_START: 
				begin			
					key_reg <= 31'd0;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end			
			S_KEY0:
				begin			
					key_reg[7:0] <= keyboard_char;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end			
			S_KEY1:
				begin			
					key_reg[15:8] <= keyboard_char;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end			
			S_KEY2:
				begin			
					key_reg[23:16] <= keyboard_char;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end			
			S_KEY3:
				begin			
					key_reg[31:24] <= keyboard_char;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end			
			S_ENCR: 
				begin
					VGA_char <= Char_out;
					VGA_DISPLAY_CLOCK <= 1'b1;							
				end
			default:
				begin
					key_reg <= 31'd0;
					VGA_DISPLAY_CLOCK <= 1'b0;			
				end
		endcase
	end
endmodule

