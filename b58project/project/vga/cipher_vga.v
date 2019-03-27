module cipher_vga
    (
        //input PS2_KBCLK,                            // Keyboard clock
        //input PS2_KBDAT,                            // Keyboard input data
        /*input CLOCK_50,                             //    On Board 50 MHz
        input [2:0] KEY,                            // Reset key*/
	input clk,
	input resetn,
	//input [1:0] switches,
	input go_signal,
	input del_signal,
	input [7:0] asciis,
	
	//input [16:15] SW,
        // The ports below are for the VGA output.  Do not change.
        output vga_clk,                             //    VGA Clock
        output vga_hs,                              //    VGA H_SYNC
        output vga_vs,                              //    VGA V_SYNC
        output vga_blank_n,                         //    VGA BLANK
        output vga_sync_n,                          //    VGA SYNC
        output [9:0] vga_r,                         //    VGA Red[9:0]
        output [9:0] vga_g,                         //    VGA Green[9:0]
        output [9:0] vga_b                          //    VGA Blue[9:0]
	/*output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [17:0] LEDR*/
    );

	 
	hex_display h0(
	       .IN(pixel_counter_transfer[3:0]),
	       .OUT(HEX0)
	);
	hex_display h1(
	       .IN(pixel_counter_transfer[7:4]),
	       .OUT(HEX1)
	);
	hex_display h2(
	       .IN(line_pos_counter_transfer[3:0]),
	       .OUT(HEX2)
	);
	
    wire [7:0] ascii_in;
    //assign LEDR[17:10] = ascii_in;
	/*
    wire go_signal;
    assign go_signal = switches[0];
    wire del_signal;
    assign del_signal = switches[1];
	*/
    // Create the colour, x, y and writeEn wires that are inputs to the VGA adapter.
    wire [2:0] colour;
    wire [8:0] x;
    wire [7:0] y;
    wire writeEn;
    // Create wires used to transfer signals and data between datapath and FSM
    wire [7:0] pixel_counter_transfer;
    wire [5:0] x_pos_counter_transfer;
    wire [5:0] x_load;
    wire x_parallel;
    wire [5:0] line_pos_counter_transfer;
    wire [5:0] line_load;
    wire line_parallel;
    wire [3:0] y_pos_counter_transfer;
    wire [3:0] cursor_pixel_counter_transfer;
    wire [3:0] y_load;
    wire y_parallel;
    wire inc_pixel_counter_transfer, dec_x_pos_counter_transfer, inc_x_pos_counter_transfer, 
        inc_y_pos_counter_transfer, dec_y_pos_counter_transfer, inc_line_pos_counter_transfer,
        dec_line_pos_counter_transfer;
    wire reset_pixel_counter_transfer, reset_x_pos_counter_transfer, reset_y_pos_counter_transfer,
        reset_line_pos_counter_transfer, load_char_transfer;
    wire shift_for_cursor_transfer, plot_cursor_transfer;
    // Create wires used to transfer keyboard input to datapath and FSM
    wire [6:0] ASCII_value;
    wire [7:0] kb_scan_code;
    wire kb_sc_ready, kb_letter_case, kb_del;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
	
    vga_adapter VGA
        (
            .resetn(resetn),
            .clock(clk),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(vga_r),
            .VGA_G(vga_g),
            .VGA_B(vga_b),
            .VGA_HS(vga_hs),
            .VGA_VS(vga_vs),
            .VGA_BLANK(vga_blank_n),
            .VGA_SYNC(vga_sync_n),
            .VGA_CLK(vga_clk)
        );

    defparam VGA.RESOLUTION = "320x240"; // "160x120" works, for sure
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black_320.mif";
	//wire [2:0] waste;
    // Instantiate keyboard input
    vga_signal kd
        (
			// Inputs
            .clk(clk),
            .reset(~resetn),
            .go(go_signal),
            .del(del_signal),
            //.ps2d(PS2_KBDAT),
            //.ps2c(PS2_KBCLK),
			// Outputs
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_sc_ready),
            .del_code_ready(kb_del),
            .letter_case_out(kb_letter_case)//,
            //.state(waste)
        );
/*
    key2ascii_vga SC2A    
        (
            .ascii_code(ASCII_value), // currently irrelevant
            .scan_code(kb_scan_code),
        );
*/
   // Instantiate datapath
    datapath d0
        (
			// Outputs
            .x_out(x),
            .y_out(y),
            .colour_out(colour),
            .pixel_counter(pixel_counter_transfer),
			.load_char(load_char_transfer),
            .x_pos_counter(x_pos_counter_transfer),
            .y_pos_counter(y_pos_counter_transfer),
			// Inputs
            .line_pos_counter(line_pos_counter_transfer),
            .clk(clk),
            .reset_n(~resetn),
            .colour_in(3'b010),
            .plot_cursor(plot_cursor_transfer),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
            .cursor_pixel_counter(cursor_pixel_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .letter_in(ascii_in), //was ascii value
            .shift_for_cursor(shift_for_cursor_transfer)
        );

    // Instantiate FSM control
    control_FSM c0
        (
			// Outputs
            .plot(writeEn),
            .inc_pixel_counter(inc_pixel_counter_transfer),
            .reset_pixel_counter(reset_pixel_counter_transfer),
			.load_char(load_char_transfer),
            .inc_line_pos_counter(inc_line_pos_counter_transfer),
            .dec_line_pos_counter(dec_line_pos_counter_transfer),
            .line_load(line_load),
            .line_parallel(line_parallel),
            .reset_line_pos_counter(reset_line_pos_counter_transfer),
            .inc_x_pos_counter(inc_x_pos_counter_transfer),
            .dec_x_pos_counter(dec_x_pos_counter_transfer),
            .x_load(x_load),
            .x_parallel(x_parallel),
            .reset_x_pos_counter(reset_x_pos_counter_transfer),
            .inc_y_pos_counter(inc_y_pos_counter_transfer),
            .dec_y_pos_counter(dec_y_pos_counter_transfer),
            .y_load(y_load),
            .y_parallel(y_parallel),
            .reset_y_pos_counter(reset_y_pos_counter_transfer),
            .shift_for_cursor(shift_for_cursor_transfer),
            .cursor_colour(plot_cursor_transfer),
            .cursor_pixel_counter(cursor_pixel_counter_transfer),
			// Inputs
            .clk(clk),
            .reset_n(~resetn),
            .char_available(kb_sc_ready),
            .del_available(kb_del),
            .pixel_counter_in(pixel_counter_transfer),
            .x_pos_counter_in(x_pos_counter_transfer),
            .y_pos_counter_in(y_pos_counter_transfer),
            .line_pos_counter_in(line_pos_counter_transfer),
            .asciis(asciis), // Input ascii from top
            //.ascii_list(asciis),
            .ascii_code(ascii_in) // changed this to output, it controls ascii now for print
        );
		  
endmodule

module datapath
    (
        output reg [8:0] x_out,
        output reg [7:0] y_out,
        output reg [2:0] colour_out,
        output [7:0] pixel_counter,
        output [5:0] line_pos_counter,
        output [5:0] x_pos_counter,
        output [3:0] y_pos_counter,
        input clk,
		input load_char,
        input reset_n,
        input [2:0] colour_in,
        input inc_pixel_counter,
        input reset_pixel_counter,
        input plot_cursor,
        input [3:0] cursor_pixel_counter,
        input inc_x_pos_counter,
        input dec_x_pos_counter,
        input [5:0] x_load,
        input x_parallel,
        input reset_x_pos_counter,
        input inc_y_pos_counter,
        input dec_y_pos_counter,
        input [3:0] y_load,
        input y_parallel,
        input reset_y_pos_counter,
        input inc_line_pos_counter,
        input dec_line_pos_counter,
        input [5:0] line_load,
        input line_parallel,
        input reset_line_pos_counter,
        input [6:0] letter_in,
        input shift_for_cursor
    );
    wire top_shifter_bit;
    wire [127:0] letter_out;

    // Instantiate line-position counter
    counter_6bit lineposc0
        (
            .Q_OUT(line_pos_counter),
            .load(line_load),
            .parallel(line_parallel),
            .increase(inc_line_pos_counter),
            .decrease(dec_line_pos_counter),
            .CLK(clk),
            .CLR(reset_line_pos_counter)
        );

    // Instantiate relative pixel position pixel_counter
    counter_8bit pxcnt0
        (
            .Q_OUT(pixel_counter), 
            .EN(inc_pixel_counter), 
            .CLK(clk), 
            .CLR(reset_pixel_counter)
        );

    // Instantiate x-position counter
    counter_6bit xposc0
        (
            .Q_OUT(x_pos_counter),
            .load(x_load),
            .parallel(x_parallel),
            .increase(inc_x_pos_counter),
            .decrease(dec_x_pos_counter),
            .CLK(clk),
            .CLR(reset_x_pos_counter)
        );

    // Instantiate y-position counter
    counter_4bit yposc0
        (
            .Q_OUT(y_pos_counter),
            .load(y_load),
            .parallel(y_parallel),
            .increase(inc_y_pos_counter),
            .decrease(dec_y_pos_counter),
            .CLK(clk),
            .CLR(reset_y_pos_counter)
        );

    // Instantiate character decoder (forms bitmaps from ascii values)
    char_decoder decoder0
        (
            .OUT(letter_out),
            .IN(letter_in) // The letter to be adjusted, was letter_in
        );


   // Instantiate shifting register to store character bitmap
   shifter_128bit s0
        (
            .result(top_shifter_bit),
            .load_val(letter_out),
            .load_n(load_char),
            .shift(inc_pixel_counter),
            .reset(reset_pixel_counter),
            .clock(clk)
        );

    always @(negedge clk)
    begin: colour_activator
        if (letter_in > 7'h1F && letter_in < 7'h7F && (top_shifter_bit || plot_cursor))
            colour_out = colour_in;
        else
            colour_out = 3'b000;
    end // colour_activator

    always @(posedge clk)
    begin: coordinate_shifter
        if (shift_for_cursor)
          begin
            y_out = (y_pos_counter << 4) + 4'd13;
            x_out = (x_pos_counter << 3) + cursor_pixel_counter;
          end
        if (~inc_pixel_counter)
        begin
            x_out = (x_pos_counter << 3) + pixel_counter[2:0];
            y_out = (y_pos_counter << 4) + pixel_counter[6:3];
        end
    end // coordinate_shifter
endmodule

module control_FSM(
        output reg plot, 
        output reg load_char,
        output reg inc_pixel_counter,
        output reg reset_pixel_counter,
        output reg inc_line_pos_counter,
        output reg dec_line_pos_counter,
        output reg [5:0] line_load,
        output reg line_parallel,
        output reg reset_line_pos_counter,
        output reg inc_x_pos_counter,
        output reg dec_x_pos_counter,
        output reg [5:0] x_load,
        output reg x_parallel,
        output reg reset_x_pos_counter,
        output reg inc_y_pos_counter,
        output reg dec_y_pos_counter,
        output reg [3:0] y_load,
        output reg y_parallel,
        output reg reset_y_pos_counter,
        output reg shift_for_cursor,
        output reg cursor_colour,
        output [3:0] cursor_pixel_counter,
        input clk,
        input reset_n,
        input char_available,
        input del_available,
		//input [3:0] del_length,
        input [7:0] pixel_counter_in,
        input [5:0] line_pos_counter_in,
        input [5:0] x_pos_counter_in,
        input [3:0] y_pos_counter_in,
        input [7:0] asciis,
        output reg [6:0] ascii_code
    );

    reg char_ready, backspace, delete;
    // Instantiate Rate Divider
    rate_divider RD
        (
        .OUT(half_hz_clock),
        .IN(clk)
        );

    // Insantiate Cursor pixel counter
    counter_4bit cpc
        (
            .Q_OUT(cursor_pixel_counter),
            .increase(inc_cursor_pixel_counter),
            .CLK(clk),
            .CLR(reset_cursor_pixel_counter)
        );

    reg [5:0] current_state, next_state;
    reg cur_ascii_i;
    reg [2:0] backspace_i;
    reg [2:0] backspace_inc;
    reg [2:0] backspace_len;
    reg [2:0] backspace_base;
    reg ascii_time;
    reg in_backspace;
    reg control_char;
    reg inc_cursor_pixel_counter, reset_cursor_pixel_counter;
    wire half_hz_clock;
	
    initial
    begin
		backspace_i <= 3'b000;
		ascii_time <= 1'b0;
		backspace_inc <= 3'b001;
		backspace_len <= 3'b111;
		backspace_base <= 3'b000;
    end
	/*
    reg max_len = 7'b1010000;
    reg inc = 7'b0000001;
    reg base = 7'b0000000;
	*/
    localparam  CHAR_SIZE             = 8'd127,
                MAX_X_POS             = 6'd39,
                MAX_Y_POS             = 4'd14,
                MAX_CURSOR_W          = 4'd7;

    localparam  S_PLOT_CURSOR           = 6'd0,
                S_PLOT_CURSOR_WAIT      = 6'd1,
                S_CURSOR_INC            = 6'd2,
                S_CURSOR_INC_WAIT       = 6'd3,
                S_FLIP_CURSOR_COLOUR    = 6'd4,
                S_CURSOR_WAIT           = 6'd5,
                S_CHECK_CHAR            = 6'd6,
                S_SAVE_CHAR             = 6'd7,
                S_SAVE_CHAR_WAIT        = 6'd8,
                S_PLOT_PIXEL            = 6'd9,
                S_PLOT_WAIT             = 6'd10,
                S_INC_PIXEL             = 6'd11,
                S_INC_PIXEL_WAIT        = 6'd12,
                S_INC_X_POS             = 6'd13,
                S_INC_X_POS_WAIT        = 6'd14,
                S_INC_Y_POS             = 6'd15,
                S_INC_Y_POS_WAIT        = 6'd16,
                S_START_NEXT_LINE       = 6'd17,
                S_START_LINE            = 6'd18,
                S_END_LINE              = 6'd19,
                S_START_NEXT_PAGE       = 6'd20,
                S_DEC_X_POS             = 6'd21,
                S_DEC_Y_POS             = 6'd22,
                S_SCROLL_UP             = 6'd23,
                S_SCROLL_DOWN           = 6'd24,
                S_END_PREV_LINE         = 6'd25,
                S_PLOT_CURSOR2          = 6'd26,
                S_DEC_X_POS_PRE         = 6'd27,
                S_DEC_Y_POS_PRE         = 6'd28,
                S_END_PREV_PAGE         = 6'd29,
                S_INC_X_POS_PRE         = 6'd30,
                S_INC_Y_POS_PRE         = 6'd31,
                S_DEC_X_POS_WAIT        = 6'd32,
                S_DEC_Y_POS_WAIT        = 6'd33,
                S_BACKSPACE             = 6'd34,
                S_DELETE                = 6'd35,
				S_INC_PIXEL_POST			 = 6'd36;

    localparam  NULL        = 7'h00, // NULL
                PGUP        = 7'h02, // STX
                PGDWN       = 7'h03, // ETX
                BACKSPACE   = 7'h08, // BS
                HOME        = 7'h0D, // CR
                UP          = 7'h11, // DC1
                LEFT        = 7'h12, // DC2
                DOWN        = 7'h13, // DC3
                RIGHT       = 7'h14, // DC3
                END         = 7'h17, // ETB
                ENTER       = 7'h0A, // LF
                DELETE      = 7'h7F; // DEL
    always @(posedge clk)
    begin
    if (char_available)
	begin
	    ascii_time = 1'b1;
	end
    if (del_available)
	begin
	    ascii_time = 1'b0;

	end
    end
    
    always @(posedge clk)
    begin: state_table
        case (current_state)
            S_PLOT_CURSOR:          next_state = char_ready ? S_CHECK_CHAR : S_PLOT_CURSOR2;
            S_PLOT_CURSOR2:         next_state = char_ready ? S_CHECK_CHAR : S_PLOT_CURSOR_WAIT;
            S_PLOT_CURSOR_WAIT:     next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC;

            S_CURSOR_INC:           next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_INC_WAIT;
            S_CURSOR_INC_WAIT:      next_state = char_ready ? S_CHECK_CHAR : 
                ( (cursor_pixel_counter <= MAX_CURSOR_W) ? S_PLOT_CURSOR : S_FLIP_CURSOR_COLOUR );

            S_FLIP_CURSOR_COLOUR:   next_state = char_ready ? S_CHECK_CHAR : S_CURSOR_WAIT;
            S_CURSOR_WAIT:          next_state = (char_ready || control_char) ? S_CHECK_CHAR :
                (half_hz_clock ? S_PLOT_CURSOR : S_CURSOR_WAIT);

            S_CHECK_CHAR:   
                        begin
									if (ascii_time)
										ascii_code <= asciis;
									else
										ascii_code <= BACKSPACE;
									
                            if (ascii_code > 7'h1F && ascii_code < 7'h7F) // if a printing char
                            begin
                                control_char = 1'b0;
                                next_state = S_SAVE_CHAR;
                            end
                            else if (control_char) // after cursor has been cleared
                            begin
                                control_char = 1'b0;
                                case(ascii_code)
                                    BACKSPACE:  
                                    begin
                                        next_state = S_BACKSPACE;
                                        in_backspace = 1'b1;
                                    end
                                    HOME:       next_state = S_START_LINE;
                                    UP:         next_state = S_DEC_Y_POS_PRE;
                                    LEFT:       next_state = S_DEC_X_POS_PRE;
                                    DOWN:       next_state = S_INC_Y_POS_PRE;
                                    RIGHT:      next_state = S_INC_X_POS_PRE;
                                    END:        next_state = S_END_LINE;
                                    ENTER:      next_state = S_START_NEXT_LINE;
                                    DELETE:     next_state = S_DELETE;
                                    default:    next_state = S_PLOT_CURSOR;
                                endcase    
                            end
                            else // if control character is pressed, before clearing cursor
                            begin
                                control_char = (ascii_code == NULL ) ? 1'b0 : 1'b1;
                                next_state = S_PLOT_CURSOR;
                            end
                        end
            S_SAVE_CHAR:            next_state = S_SAVE_CHAR_WAIT;
            S_SAVE_CHAR_WAIT:       next_state = S_PLOT_PIXEL;

            S_PLOT_PIXEL:           next_state = S_PLOT_WAIT;
            S_PLOT_WAIT:            next_state = S_INC_PIXEL;
            S_INC_PIXEL:            next_state = S_INC_PIXEL_WAIT;
            S_INC_PIXEL_WAIT:       next_state = (pixel_counter_in <= CHAR_SIZE) ? S_PLOT_PIXEL : 
                ( ((backspace == 1'b1) || (delete == 1'b1)) ? S_INC_PIXEL_POST : S_INC_X_POS_PRE );
	    S_INC_PIXEL_POST: next_state = S_CHECK_CHAR;
		// for multiple deletes
		/*
				begin	
					if (in_backspace == 1'b1)
					begin
						if (backspace_i == backspace_len)
						begin
							backspace_i = backspace_base;
							next_state = S_PLOT_CURSOR;
							in_backspace = 1'b0;
						end
						else
						begin
							backspace_i = backspace_i + backspace_inc;
							next_state = S_BACKSPACE;
						end
					end
					else
						next_state = S_CHECK_CHAR;

				end
*/
            S_INC_X_POS_PRE:        next_state = (x_pos_counter_in < MAX_X_POS) ? S_INC_X_POS : S_START_NEXT_LINE;
            S_INC_X_POS:            next_state = S_INC_X_POS_WAIT;
            S_INC_X_POS_WAIT:		 next_state = S_PLOT_CURSOR;
/*			
		// for multiple characters
				begin
					// Reset if went over all letters
					if (cur_ascii_i == max_len)
					begin
						cur_ascii_i = base;
						next_state = S_PLOT_CURSOR;
					end
					// Otherwise move to next letter
					else
					begin
						cur_ascii_i = cur_ascii_i + inc;
						next_state = S_CHECK_CHAR;
					end
						
				end
*/
            S_DEC_X_POS_PRE:        next_state = (x_pos_counter_in > 0) ? S_DEC_X_POS : S_END_PREV_LINE;
            S_DEC_X_POS:            next_state = S_DEC_X_POS_WAIT;
            S_DEC_X_POS_WAIT:       next_state = (backspace == 1'b1) ? S_SAVE_CHAR : S_PLOT_CURSOR;
		
            S_INC_Y_POS_PRE:        next_state = (y_pos_counter_in < MAX_Y_POS) ? S_INC_Y_POS : S_SCROLL_DOWN;
            S_INC_Y_POS:            next_state = S_INC_Y_POS_WAIT;
            S_INC_Y_POS_WAIT:       next_state = S_PLOT_CURSOR;

            S_DEC_Y_POS_PRE:        next_state = (y_pos_counter_in > 0) ? S_DEC_Y_POS : S_SCROLL_UP;
            S_DEC_Y_POS:            next_state = S_DEC_Y_POS_WAIT;
            S_DEC_Y_POS_WAIT:       next_state = (backspace == 1'b1) ? S_SAVE_CHAR : S_PLOT_CURSOR;

            S_START_LINE:           next_state = S_PLOT_CURSOR;
            S_END_LINE:             next_state = S_PLOT_CURSOR;
            S_START_NEXT_LINE:      next_state = S_INC_Y_POS_PRE;
            S_END_PREV_LINE:        next_state = S_DEC_Y_POS_PRE;

            S_SCROLL_DOWN:          next_state = S_PLOT_CURSOR;
            S_SCROLL_UP:            next_state = S_PLOT_CURSOR;

            S_BACKSPACE:            next_state = S_DEC_X_POS_PRE;
            S_DELETE:               next_state = S_SAVE_CHAR;

            default:                next_state = S_PLOT_CURSOR;
        endcase
    end // state_table

    always @(negedge clk)
    begin: enable_signals
        char_ready = (ascii_code == NULL || control_char) ? 1'b0 : (char_available || del_available);

        plot                        = 1'b0;
        load_char                   = 1'b0;

        inc_pixel_counter           = 1'b0;
        reset_pixel_counter         = 1'b0;

        line_parallel               = 1'b0;
        inc_line_pos_counter        = 1'b0;
        dec_line_pos_counter        = 1'b0;
        reset_line_pos_counter      = 1'b0;

        inc_cursor_pixel_counter    = 1'b0;
        reset_cursor_pixel_counter  = 1'b0;

        x_parallel                  = 1'b0;
        inc_x_pos_counter           = 1'b0;
        dec_x_pos_counter           = 1'b0;
        reset_x_pos_counter         = 1'b0;

        y_parallel                  = 1'b0;
        inc_y_pos_counter           = 1'b0;
        dec_y_pos_counter           = 1'b0;
        reset_y_pos_counter         = 1'b0;

        case (current_state)
            S_PLOT_CURSOR:              shift_for_cursor            = 1'b1;
            S_PLOT_CURSOR2:             plot                        = 1'b1;
            S_CURSOR_INC:               inc_cursor_pixel_counter    = 1'b1;
            S_FLIP_CURSOR_COLOUR:   begin
                                        cursor_colour               = ~cursor_colour;
                                        reset_cursor_pixel_counter  = 1'b1;
                                    end

            S_CHECK_CHAR:           begin
                                        cursor_colour               = 1'b0;
                                        reset_cursor_pixel_counter  = 1'b1;
                                    end

            S_SAVE_CHAR:
                                    begin
					reset_pixel_counter  		= 1'b1;
                                        reset_cursor_pixel_counter  = 1'b1;
                                        shift_for_cursor            = 1'b0;
                                    end
			S_SAVE_CHAR_WAIT:			load_char	                 = 1'b1;

            S_PLOT_PIXEL:               plot                        = 1'b1;
            S_INC_PIXEL:            	 inc_pixel_counter           = 1'b1;
				S_INC_PIXEL_POST:			begin
													delete							  = 1'b0;
													backspace						  = 1'b0;
												end

            S_SCROLL_DOWN:              inc_line_pos_counter        = 1'b1;
            S_SCROLL_UP:                dec_line_pos_counter        = 1'b1;

            S_START_NEXT_LINE:          reset_x_pos_counter         = 1'b1;
            S_END_PREV_LINE:        begin
                                        x_load                      = MAX_X_POS;
                                        x_parallel                  = 1'b1;
                                    end

            S_INC_X_POS:                inc_x_pos_counter           = 1'b1;
            S_INC_Y_POS:                inc_y_pos_counter           = 1'b1;
            S_DEC_X_POS:                dec_x_pos_counter           = 1'b1;
            S_DEC_Y_POS:                dec_y_pos_counter           = 1'b1;

            S_START_LINE:               reset_x_pos_counter         = 1'b1;
            S_END_LINE:             begin
                                        x_load                      = MAX_X_POS;
                                        x_parallel                  = 1'b1;
                                    end

            S_BACKSPACE:             begin
													backspace                   = 1'b1;
													reset_pixel_counter 			= 1'b1;
												end
            S_DELETE:                begin
	                             			delete                      = 1'b1;
													shift_for_cursor            = 1'b0;
													reset_pixel_counter 			= 1'b1;
												end

        endcase
    end // enable_signals

    always @(posedge clk)
    begin: state_FFs
        current_state = reset_n ? S_PLOT_CURSOR : next_state;
    end // state_FFs
	

endmodule

