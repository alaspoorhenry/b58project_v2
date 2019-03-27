module sequential_write(
    input [7:0] ascii_char,
    input clk,
    input [11:0] begin_at,
	input writeEn,
	output [7:0] q_out,
    output reg [11:0] ret
    );

    /*
    reg [11:0]Begin;

    assign begin_at = Begin;

    memory_module ram(
		.address(begin_at),
		.clock(clk),
		.data(ascii_char),
		.wren(write_En),
		.q(q_out)
	);

    always @()
    begin
	ret <= Begin + 4'b1000;
    end
	*/

endmodule
