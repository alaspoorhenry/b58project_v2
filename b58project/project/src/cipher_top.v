/*
DE2 inputs:

reset = KEY[0]
enter = KEY[1]
keyboard_key = keyboard_clk


DE2 outputs:

LEDR[17] = keyboard_clk

*/


module cipher_top(

        // keyboard input
        input PS2_KBCLK,                            // Keyboard clock
        input PS2_KBDAT,                            // Keyboard input data

        // VGA output
        output VGA_CLK,                             // VGA Clock
        output VGA_HS,                              // VGA H_SYNC
        output VGA_VS,                              // VGA V_SYNC
        output VGA_BLANK_N,                         // VGA BLANK
        output VGA_SYNC_N,                          // VGA SYNC
        output [9:0] VGA_R,                         // VGA Red[9:0]
        output [9:0] VGA_G,                         // VGA Green[9:0]
        output [9:0] VGA_B,                         // VGA Blue[9:0]

        // DE2 board outputs
        output [17:0] LEDR,
        output [7:0] LEDG,
        output [6:0] HEX0,
        output [6:0] HEX1,

        // DE2 board control inputs
        input CLOCK_50,                             // 50 MHz
        input [3:0] KEY,                            // Keys
        input [17:0] SW                             // Switches
    );

    wire reset, enter;
    assign reset = KEY[0];
    assign enter = KEY[1];
    

    wire [7:0] kb_scan_code;
    wire kb_sc_ready, kb_letter_case;
    wire [7:0] ASCII_value;


    // KEYBOARD
    // taken from https://github.com/armitag8/ASIC_Notepad--
    keyboard kd (
            .clk(CLOCK_50),                    // in
            .reset(~reset),                   // in
            .ps2d(PS2_KBDAT),                  // in
            .ps2c(PS2_KBCLK),                  // in
            .scan_code(kb_scan_code),          // out [7:0]
            .scan_code_ready(kb_sc_ready),     // out
            .letter_case_out(kb_letter_case)   // out; Not used
        );

    // taken from https://github.com/armitag8/ASIC_Notepad--
    key2ascii_vga SC2A (
            .ascii_code(ASCII_value),      // out reg  [7:0]
            .scan_code(kb_scan_code)       // in       [7:0]
        );


    // KEYBOARD_CLK
    // keyboard_clk based on kb_sc_ready; (should have a downward spike when key is pressed)
    reg keyboard_clk;
    initial
		 begin
			  keyboard_clk <= 0;
		 end

    always @(posedge kb_sc_ready)
    begin
        keyboard_clk = ~keyboard_clk;
    end

    // comes from FSM
    wire [2:0] STATE;

    // comes from DP; passed to LEDR[7:0] and VGA
    wire [7:0] LETTER;

    // transfers 8 bit encrypted char to VGA
    wire [7:0] VGA_char;

    // triggers VGA change on posedge
    wire VGA_DISPLAY_CLOCK;

    FSM fsm(
        .clk(CLOCK_50),   // CLOCK_50
        .reset(reset),    // KEY[0]
        .enter(enter),    // KEY[1]
        .STATE(STATE)     // out
        );

    Datapath dp(
        .STATE(STATE),                           // in, from FSM
        .keyboard_clk(keyboard_clk),             // in
        .keyboard_char(ASCII_value),             // in
        .VGA_char(VGA_char),                     // out, goes to VGA
        .VGA_DISPLAY_CLOCK(VGA_DISPLAY_CLOCK),   // out, triggers VGA display
	.CIPHER_IDX(LEDG[1:0])                   // out. Displays current key IDX on LEDG
        );

    wire [8:0] x_vga;
    wire [7:0] y_vga;
    wire [2:0] c_vga;
    wire writeEn_vga;
    vga_adapter VGA
        (
            .resetn(reset),
            .clock(CLOCK_50),
            .colour(c_vga),
            .x(x_vga),
            .y(y_vga),
            .plot(writeEn_vga),
            // Signals for the DAC to drive the monitor.
		.VGA_CLK(VGA_CLK),    
		.VGA_HS(VGA_HS),     
		.VGA_VS(VGA_VS),     
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N), 
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
        );


    defparam VGA.RESOLUTION = "320x240"; // "160x120" works, for sure
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black_320.mif";

    // instantiate VGA, pass VGA_char, VGA_DISPLAY_CLOCK
	cipher_vga cv (
		.clk(CLOCK_50),			//clock signal
        	.asic(VGA_char),	//VGA_char for outputting to VGA
        	.go_k(KEY[3]),		//clock signal for VGA
		.resetn(SW[0]),			//reset switch for display
		.x_o(x_vga),			// x - horizontal direction for drawing
		.y_o(y_vga),			// y - vertical direction for drawing
		.c_o(c_vga),			// colour input for vga display
		.w_o(writeEn_vga),		// write enable for vga
		.debug(LEDG[7:2])		// green LEDs for debugging display signals
    );


	//red LEDs for debugging display clock, character (hex values), keyboard clock, and state of FSM
    assign LEDR[16] = VGA_DISPLAY_CLOCK;
    assign LEDR[7:0] = VGA_char;
    assign LEDR[17] = keyboard_clk;
    assign LEDR[12:10] = STATE;

	//hex displays instantiated for debugging
    hex_display h0(
        .IN(VGA_char[3:0]),
        .OUT(HEX0)
        );

    hex_display h1(
        .IN(VGA_char[7:4]),
        .OUT(HEX1)
        );
	
	 
endmodule


