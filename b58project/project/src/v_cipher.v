// Basic Caesar cipher module;
// Supports only lowercase ascii as key and plaintext chars
module caesar_cipher
	(
	input [31:0] key,         // only key[8:0] is used
	input [7:0] char_in,
	output reg [7:0] char_out
	);

	wire [7:0] key_m26;

    // convert the key to mod 26 representation
	ASCII_to_mod26 AM(
	.mod26_out(key_m26),
	.ascii_in(key[7:0])
	);

    // when char in changes, encrypt it and output on char_out reg
    always @(char_in)
    begin

        // lower case ascii
        if (char_in >= 97 && char_in <= 122)
        begin
            if (char_in + key_m26 > 122)
            // overflow
            begin
                char_out <= char_in + key_m26 - 26;
            end
            else
            // no overflow
            begin
                char_out <= char_in + key_m26;
            end
        end
        else
        // disallowed input - output Space ascii char
        begin
            char_out <= 8'd32;
        end
    end

endmodule


// Basic Caesar cipher module;
// Supports only lowercase ascii as key and plaintext chars
module caesar_cipher_8_bit
	(
	input [7:0] key,         // only key[8:0] is used
	input [7:0] char_in,
	output reg [7:0] char_out
	);

	wire [7:0] key_m26;

    // convert the key to mod 26 representation
	ASCII_to_mod26 AM(
	.mod26_out(key_m26),
	.ascii_in(key)
	);

    // when char in changes, encrypt it and output on char_out reg
    always @(char_in)
    begin

        if (char_in >= 97 && char_in <= 122)
        begin
            if (char_in + key_m26 > 122)
            // overflow
            begin
                char_out <= char_in + key_m26 - 26;
            end
            else
            // no overflow
            begin
                char_out <= char_in + key_m26;
            end
        end
        else
        // disallowed input - output Space ascii char
        begin
            char_out <= 8'd32;
        end
    end

endmodule


// https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher
// supports 4 char key
// reference:
// https://cryptii.com/pipes/vigenere-cipher
module vigenere_cipher(
    input [31:0] key_arr,
    input [7:0] char_in,
    input keyboard_clk,
    output reg [7:0] char_out,
    output [1:0] IDX_out            // output for debug purposes
    );

    // 4 key ascii bytes
    wire [7:0] key_0;
    wire [7:0] key_1;
    wire [7:0] key_2;
    wire [7:0] key_3;

    // used by caesar_cipher_8_bit modules
    wire [7:0] char_out_0;
    wire [7:0] char_out_1;
    wire [7:0] char_out_2;
    wire [7:0] char_out_3;

    assign key_0 = key_arr[7:0];
    assign key_1 = key_arr[15:8];
    assign key_2 = key_arr[23:16];
    assign key_3 = key_arr[31:24];

    // instantiate 4 caesar_cipher_8_bit modules (1 for each key char, 0-3)
    caesar_cipher_8_bit C0(
        .key(key_0),
        .char_in(char_in),
        .char_out(char_out_0)
    );

    caesar_cipher_8_bit C1(
        .key(key_1),
        .char_in(char_in),
        .char_out(char_out_1)
    );

    caesar_cipher_8_bit C2(
        .key(key_2),
        .char_in(char_in),
        .char_out(char_out_2)
    );

    caesar_cipher_8_bit C3(
        .key(key_3),
        .char_in(char_in),
        .char_out(char_out_3)
    );


    // IDX - current key index
    // IDX_next - key index on next keyboard clock cycle
    // 0 to 3
    reg [1:0] IDX;
    reg [1:0] IDX_next;

    assign IDX_out = IDX;

    // set IDX to 0 (first key byte initially)
    initial
    begin
        IDX <= 2'b00;
    end

    // on keyboard clock, modify the output char and assign IDX_next to next key char
    always @(posedge keyboard_clk)
    begin

        case (IDX)
            2'b00:
                 begin
                     char_out <= char_out_0;
                     IDX_next <= 2'b01;
                 end
            2'b01:
                 begin
                     char_out <= char_out_1;
                     IDX_next <= 2'b10;
                 end
            2'b10:
                 begin
                     char_out <= char_out_2;
                     IDX_next <= 2'b11;
                 end
            2'b11:
                 begin
                     char_out <= char_out_3;
                     IDX_next <= 2'b00;     // wrap around to the beginning of key
                 end
            default:
                 begin
                     char_out <= char_out_0;
                     IDX_next <= 2'b01;
                 end
        endcase

    end

    // increment IDX to next key index
    always @(posedge keyboard_clk)
    begin
        IDX <= IDX_next;
    end

endmodule

