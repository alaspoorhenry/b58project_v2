module key2ascii_vga
    (
        input wire [7:0] scan_code,
        output reg [7:0] ascii_code
    );
    
always @*
    begin
        case(scan_code)
            /* We had also done these */
            8'h45: ascii_code = 8'h30;   // 0
            8'h16: ascii_code = 8'h31;   // 1
            8'h1e: ascii_code = 8'h32;   // 2
            8'h26: ascii_code = 8'h33;   // 3
            8'h25: ascii_code = 8'h34;   // 4
            8'h2e: ascii_code = 8'h35;   // 5
            8'h36: ascii_code = 8'h36;   // 6
            8'h3d: ascii_code = 8'h37;   // 7
            8'h3e: ascii_code = 8'h38;   // 8
            8'h46: ascii_code = 8'h39;   // 9
            /* These scan codes are identical to the uppercase ones, obviously. 
            Redoing this would have been pointless, so we took it as-is.*/
            8'h1c: ascii_code = 8'h61;   // a
            8'h32: ascii_code = 8'h62;   // b
            8'h21: ascii_code = 8'h63;   // c
            8'h23: ascii_code = 8'h64;   // d
            8'h24: ascii_code = 8'h65;   // e
            8'h2b: ascii_code = 8'h66;   // f
            8'h34: ascii_code = 8'h67;   // g
            8'h33: ascii_code = 8'h68;   // h
            8'h43: ascii_code = 8'h69;   // i
            8'h3b: ascii_code = 8'h6A;   // j
            8'h42: ascii_code = 8'h6B;   // k
            8'h4b: ascii_code = 8'h6C;   // l
            8'h3a: ascii_code = 8'h6D;   // m
            8'h31: ascii_code = 8'h6E;   // n
            8'h44: ascii_code = 8'h6F;   // o
            8'h4d: ascii_code = 8'h70;   // p
            8'h15: ascii_code = 8'h71;   // q
            8'h2d: ascii_code = 8'h72;   // r
            8'h1b: ascii_code = 8'h73;   // s
            8'h2c: ascii_code = 8'h74;   // t
            8'h3c: ascii_code = 8'h75;   // u
            8'h2a: ascii_code = 8'h76;   // v
            8'h1d: ascii_code = 8'h77;   // w
            8'h22: ascii_code = 8'h78;   // x
            8'h35: ascii_code = 8'h79;   // y
            8'h1a: ascii_code = 8'h7A;   // z
            8'h0e: ascii_code = 8'h60;   // `
            8'h4e: ascii_code = 8'h2D;   // -
            8'h55: ascii_code = 8'h3D;   // =
            8'h54: ascii_code = 8'h5B;   // [
            8'h5b: ascii_code = 8'h5D;   // ]
            8'h5d: ascii_code = 8'h5C;   // \
            8'h4c: ascii_code = 8'h3B;   // ;
            8'h52: ascii_code = 8'h27;   // '
            8'h41: ascii_code = 8'h2C;   // ,
            8'h49: ascii_code = 8'h2E;   // .
            8'h4a: ascii_code = 8'h2F;   // /
            8'h29: ascii_code = 8'h20;   // space
            8'h5a: ascii_code = 8'h0A;   // LF: Return (\n)
            8'h66: ascii_code = 8'h08;   // BS: backspace
            8'h0D: ascii_code = 8'h09;   // TAB: horizontal tab
            /* Again, we added all these to control cursor movement, behavior */
            8'h75: ascii_code = 8'h11;   // DC1: Up Arrow
            8'h6B: ascii_code = 8'h12;   // DC2: Left Arrow
            8'h72: ascii_code = 8'h13;   // DC3: Down Arrow
            8'h74: ascii_code = 8'h14;   // DC4: Right Arrow
            8'h6C: ascii_code = 8'h0D;   // CR: Home (\r)
            8'h7D: ascii_code = 8'h02;   // STX: Page Up
            8'h7A: ascii_code = 8'h03;   // ETX: Page Down
            8'h69: ascii_code = 8'h17;   // ETB: End
            8'h71: ascii_code = 8'h7F;   // DEL: Delete
            8'h70: ascii_code = 8'h1A;   // SUB: Insert
            
            default: ascii_code = 8'h61; // NUL
            //default: ascii_code = 8'h00; // NUL
        endcase
    end
endmodule
