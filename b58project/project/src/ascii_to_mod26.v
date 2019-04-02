
/*

input ascii byte; output: 0=a, 1=b .. 26=z

example usage:
wire [7:0]mod26;
wire [7:0]ascii;
ASCII_to_mod26 Decoder(.mod26_out(mod26), .ascii_in(ASCII_value));

*/

// Changes on ascii_in change
module ASCII_to_mod26(output [7:0]mod26_out, input [7:0]ascii_in);
    reg [7:0]out;

    always @(ascii_in)
    begin
      // [a-z]
      if (ascii_in >= 97 && ascii_in < 123)
          begin
              out <= ascii_in - 97;
          end
      // spc
      else if (ascii_in == 32)
          begin
              out <= 32;
          end
      // other; output space char
      else
          begin
              out <= 32;
          end
    end

    assign mod26_out = out;
endmodule

// changes on mod26_in change
module mod26_toASCII(output [7:0]ascii_out, input [7:0]mod26_in);
    reg [7:0]out;

    always @(mod26_in)
    begin
      // [a-z]
      if (mod26_in >=0 && mod26_in < 26)
          begin
              out <= mod26_in + 97;
          end
      // other; output space char
      else
          begin
              out <= 32;
          end
    end

    assign ascii_out = out;
endmodule


