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
        .VGA_DISPLAY_CLOCK(VGA_DISPLAY_CLOCK)    // out, triggers VGA display
        );


    // instantiate VGA, pass VGA_char, VGA_DISPLAY_CLOCK
//	cipher_vga cv (
//		.clk(CLOCK_50),
//		.resetn(reset),
//
//        // come from Datapath
//		.go_signal(VGA_DISPLAY_CLOCK),
//		.asciis(VGA_char),
//
//		.del_signal(KEY[3]),
//		.vga_clk(VGA_CLK),    
//		.vga_hs(VGA_HS),     
//		.vga_vs(VGA_VS),     
//		.vga_blank_n(VGA_BLANK_N),
//		.vga_sync_n(VGA_SYNC_N), 
//		.vga_r(VGA_R),
//		.vga_g(VGA_G),
//		.vga_b(VGA_B) 
//		.vga_b(VGA_B) 
//    );

    assign LEDR[16] = VGA_DISPLAY_CLOCK;
    assign LEDR[7:0] = VGA_char;
    assign LEDR[17] = keyboard_clk;
    assign LEDR[12:10] = STATE;
	
	
	 
endmodule


