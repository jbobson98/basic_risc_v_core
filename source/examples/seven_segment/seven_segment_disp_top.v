module seven_segment_disp_top (
    input wire clk_i,
    input wire rst_i,
    input wire dot_en_i,
    input wire disp_en_i,
    input wire [13:0] digit_i,       // assigned to toggle switches
    output wire [3:0] anodes_o,     // [left disp -> right display]
    output wire [7:0] cathodes_o    // [CA, CB, CC, CD, CE, CF, CG, DP]
);

localparam CLOCK_FREQUENCY = 100_000_000;

// Sync/Debounce Reset
wire rst_sync;
debouncer #(.CLK_FREQ(CLOCK_FREQUENCY)) reset_debouncer 
    (.clk(clk_i), .rst(1'b0), .btn_in(rst_i), .btn_out(rst_sync));

// Sync Display Enable
wire disp_en_sync;
debouncer #(.CLK_FREQ(CLOCK_FREQUENCY)) disp_en_debouncer 
    (.clk(clk_i), .rst(rst_sync), .btn_in(disp_en_i), .btn_out(disp_en_sync));

// Sync Dot Enable
wire dot_en_sync;
debouncer #(.CLK_FREQ(CLOCK_FREQUENCY)) dot_en_debouncer 
    (.clk(clk_i), .rst(rst_sync), .btn_in(dot_en_i), .btn_out(dot_en_sync));

// Sync Toggle Switches
wire [13:0] digit_sync;
genvar i;
generate
    for(i = 0; i < 14; i = i + 1) begin: toggle_switch_debouncers
        debouncer #(.CLK_FREQ(CLOCK_FREQUENCY)) switch_debouncer 
            (.clk(clk_i), .rst(rst_sync), .btn_in(digit_i[i]), .btn_out(digit_sync[i]));
    end
endgenerate

// Instantiate 4 segment display
quad_display #(.CLOCK_FREQ_HZ(100_000_000), .REFRESH_RATE_HZ(240)) disp 
    (.clk_i(clk_i), .rst_i(rst_sync), .disp_en_i(disp_en_sync), .dot_enables_i({4{dot_en_sync}}), 
     .disp_num_i(digit_sync), .anodes_o(anodes_o), .cathodes_o(cathodes_o));


endmodule