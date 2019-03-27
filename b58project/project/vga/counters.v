module counter_4bit
    (
        output reg [3:0] Q_OUT,
        input [3:0] load,
        input parallel,
        input increase, 
        input decrease, 
        input CLK, 
        input CLR
    );
    initial
    begin
        Q_OUT = 4'b0000;
    end
    
    always @(posedge CLK)
    begin
        if (increase == 1'b1 || decrease == 1'b1 || CLR == 1'b1 || parallel == 1'b1)
        begin
            if (CLR == 1'b1)
                Q_OUT[3:0] <= 4'b0000;
            else if (CLK == 1'b1 && increase == 1'b1)
               Q_OUT[3:0] <= Q_OUT[3:0] + 4'b0001;
            else if (CLK == 1'b1 && decrease == 1'b1)
               Q_OUT[3:0] <= Q_OUT[3:0] - 4'b0001;
            else if (CLK == 1'b1 && parallel == 1'b1)
               Q_OUT[3:0] <= load[3:0];
        end
    end
endmodule

module counter_6bit
    (
        output reg [5:0] Q_OUT,
        input [5:0] load,
        input parallel,
        input increase, 
        input decrease, 
        input CLK, 
        input CLR
    );
    initial
    begin
        Q_OUT = 6'b00_0000;
    end

    always @(posedge CLK)
    begin
        if (increase == 1'b1 || decrease == 1'b1 || CLR == 1'b1 || parallel == 1'b1)
        begin
            if (CLR == 1'b1)
                Q_OUT[5:0] <= 6'b00_0000;
            else if (CLK == 1'b1 && increase == 1'b1)
               Q_OUT[5:0] <= Q_OUT[5:0] + 6'b00_0001;
            else if (CLK == 1'b1 && decrease == 1'b1)
               Q_OUT[5:0] <= Q_OUT[5:0] - 6'b00_0001;
            else if (CLK == 1'b1 && parallel == 1'b1)
               Q_OUT[5:0] <= load[5:0];
        end
    end

endmodule
module counter_8bit
    (
        output reg [7:0] Q_OUT, 
        input EN, 
        input CLK, 
        input CLR
    );
    initial
    begin
        Q_OUT = 8'b0000_0000;
    end

    always @(posedge CLK)
    begin
        if (EN == 1'b1 | CLR == 1'b1)
        begin
            if (CLR == 1'b1)
                Q_OUT[7:0] <= 8'b0000_0000;
            else if (CLK == 1'b1)
                Q_OUT[7:0] <= Q_OUT[7:0] + 8'b0000_0001;
        end
    end
endmodule
