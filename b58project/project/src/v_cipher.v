module caesar_cipher
	(
	input [31:0] key,         // only key[8:0] is used
	input [7:0] char_in,
	output reg [7:0] char_out
	);

	wire [7:0] key_m26;

	ASCII_to_mod26 AM(
	.mod26_out(key_m26),
	.ascii_in(key[7:0])
	);

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
        begin
            char_out <= 8'd32; // Space ascii char
        end
    end

endmodule



module caesar_cipher_8_bit
	(
	input [7:0] key,         // only key[8:0] is used
	input [7:0] char_in,
	output reg [7:0] char_out
	);

	wire [7:0] key_m26;

	ASCII_to_mod26 AM(
	.mod26_out(key_m26),
	.ascii_in(key)
	);

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
        begin
            char_out <= 8'd32; // Space ascii char
        end
    end

endmodule





module vigenere_cipher(
    input [31:0] key_arr,
    input [7:0] char_in,
    input keyboard_clk,
    output reg [7:0] char_out
    );

    wire [7:0] key_0;
    wire [7:0] key_1;
    wire [7:0] key_2;
    wire [7:0] key_3;

    wire [7:0] char_out_0;
    wire [7:0] char_out_1;
    wire [7:0] char_out_2;
    wire [7:0] char_out_3;

    assign key_0 = key_arr[7:0];
    assign key_1 = key_arr[15:8];
    assign key_2 = key_arr[23:16];
    assign key_3 = key_arr[31:24];

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


    // 0 to 3
    reg [1:0] IDX;
    wire [1:0] IDX_next;

    assign IDX_next = IDX+1;

    initial
    begin
        IDX <= 2'b00;
    end

    always @(posedge keyboard_clk)
    begin

	// https://cryptii.com/pipes/vigenere-cipher

        /*
        // DEBUG; prints IDX on LEDS
        char_out[3:0] <= IDX;
        char_out[7:4] <= 4'b0000;

        // DEBUG; displays key[IDX]
        case (IDX)
            2'b00:
                 begin
                     char_out <= key_0;
                 end
            2'b01:
                 begin
                     char_out <= key_1;
                 end
            2'b10:
                 begin
                     char_out <= key_2;
                 end
            2'b11:
                 begin
                     char_out <= key_3;
                 end
            default:
                 begin
                     char_out <= key_0;
                 end
        endcase
        */

        case (IDX)
            2'b00:
                 begin
                     char_out <= char_out_0;
                 end
            2'b01:
                 begin
                     char_out <= char_out_1;
                 end
            2'b10:
                 begin
                     char_out <= char_out_2;
                 end
            2'b11:
                 begin
                     char_out <= char_out_3;
                 end
            default:
                 begin
                     char_out <= char_out_0;
                 end
        endcase

        IDX <= IDX_next;
    end


endmodule

