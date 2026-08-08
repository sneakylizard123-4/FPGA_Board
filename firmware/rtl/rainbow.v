// rainbow.v - RGB LED rainbow proof-of-life for the FPGA_Board (ICE40UP5K)
//
// Clock: 12 MHz on IOB_25b_G3 (package pin 20)
// LED:   common-anode RGB, RGB0/1/2 (pins 39/40/41) are open-drain sinks,
//        so a logic '1' turns the color off and '0' turns it on.
//
// The hue advances 25 times per second, so one full rainbow lap takes 10 s.
// Color is computed as classic 6-segment HSV (S=1, V=1) and inverted
// for the active-low open-drain drive.

module rainbow (
    input  wire clk_12m,  // 12 MHz clock input
    output wire rgb_r,    // RGB0  (active low)
    output wire rgb_g,    // RGB1  (active low)
    output wire rgb_b     // RGB2  (active low)
);

localparam [23:0] HUE_STEP_TICKS = 12_000_000 / 25;  // 480,000 ticks @ 12 MHz

reg [23:0] tick_cnt;
reg [ 7:0] hue;

always @(posedge clk_12m) begin
    if (tick_cnt == HUE_STEP_TICKS - 1) begin
        tick_cnt <= 24'd0;
        hue      <= hue + 8'd1;
    end else begin
        tick_cnt <= tick_cnt + 24'd1;
    end
end

// HSV -> RGB, S=1, V=1, 10-bit components (max = 1023).
// hue * 6 maps the 8-bit hue onto the 6 color-wheel segments:
//   seg  = (hue * 6) >> 8        -> 0..5
//   frac = ((hue * 6) & 8'hff) * 4 -> 0..1020 (position within the segment)
wire [9:0] frac = ((hue * 6) & 8'hff) << 2;

reg [9:0] r_hi, g_hi, b_hi;

always @* begin
    case ((hue * 6) >> 8)
        3'd0: begin r_hi = 10'd1023;      g_hi = frac;         b_hi = 10'd0;    end
        3'd1: begin r_hi = 10'd1023-frac; g_hi = 10'd1023;     b_hi = 10'd0;    end
        3'd2: begin r_hi = 10'd0;         g_hi = 10'd1023;     b_hi = frac;     end
        3'd3: begin r_hi = 10'd0;         g_hi = 10'd1023-frac; b_hi = 10'd1023; end
        3'd4: begin r_hi = frac;          g_hi = 10'd0;        b_hi = 10'd1023; end
        default: begin r_hi = 10'd1023;   g_hi = 10'd0;        b_hi = 10'd1023-frac; end
    endcase
end

// active-low open-drain drive: output 0 = on, 1 = off
assign rgb_r = ~|r_hi;
assign rgb_g = ~|g_hi;
assign rgb_b = ~|b_hi;

endmodule
