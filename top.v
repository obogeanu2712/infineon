module top(
    input clk_i,
    input rstn_i,
    input acc_en_i,
    input wr_en_i,
    input [2:0] addr_i,
    input [15:0] wdata_i,
    input [15:1] input_i,
    output [15:0] rdata_o,
    output reg output_o
);

wire [9:0] act_cnt_val_w;
wire [1:0] ctrl0_w;
wire [9:0] pwm_mode_duty_cycle_w;
wire [1:0] pwm_mode_freq_w;
wire [3:0] cnt_timer_mode_in_w;
wire [1:0] cnt_timer_trigger_sel_w;
wire cnt_timer_out_w;
wire [1:0] cnt_timer_capt_sel_w; 
wire [9:0] cnt_timer1_target_w;
wire cmd_clear_w;
wire cmd_sw_trigger_w;
wire [9:0] captured_status_value_w;
wire captured_status_tm_running_w;

reg input_reg;
reg input_reg_sync;

reg sel_in_s;

register_block f1(
    .clk_i(clk_i),                      
    .rstn_i(rstn_i),                    
    .acc_en_i(acc_en_i),                 
    .wr_en_i(wr_en_i),      
    .addr_i(addr_i),              
    .wdata_i(wdata_i),    
    .act_cnt_val_i(act_cnt_val_w),    
    .captured_status_tm_running_i(captured_status_tm_running_w),
    .captured_status_value_i(captured_status_value_w),
    .rdata_o(rdata_o),
    .ctrl0_o(ctrl0_w),                
    .pwm_mode_duty_cycle_o(pwm_mode_duty_cycle_w),  
    .pwm_mode_freq_o(pwm_mode_freq_w),        
    .cnt_timer_mode_in_o(cnt_timer_mode_in_w),    
    .cnt_timer_trigger_sel_o(cnt_timer_trigger_sel_w),
    .cnt_timer_out_o(cnt_timer_out_w),
    .cnt_timer_capt_sel_o(cnt_timer_capt_sel_w),
    .cnt_timer1_target_o(cnt_timer1_target_w),
    .cmd_clear_o(cmd_clear_w),
    .cmd_sw_trigger_o(cmd_sw_trigger_w)
    //.captured_status_value_o(captured_status_value_w),
    //.captured_status_tm_running_o(captured_status_tm_running_w)
    );
    
    
always@(*) begin
       case(cnt_timer_mode_in_w)
       	0: input_reg = 0;
        1: input_reg = input_i[1];
        2: input_reg = input_i[2];
        3: input_reg = input_i[3];
        4: input_reg = input_i[4];
        5: input_reg = input_i[5];
        6: input_reg = input_i[6];
        7: input_reg = input_i[7];
        8: input_reg = input_i[8];
        9: input_reg = input_i[9];
        10: input_reg = input_i[10];
        11: input_reg = input_i[11];
        12: input_reg = input_i[12];
        13: input_reg = input_i[13];
        14: input_reg = input_i[14];
        15: input_reg = input_i[15];
   endcase
end

always@(posedge clk_i or negedge rstn_i) begin
    if(rstn_i == 0)
    	input_reg_sync <= 0;
    else
    	input_reg_sync <= input_reg;
end

always@(*) begin
    case(cnt_timer_mode_in_w != 0)
        0: sel_in_s = cmd_sw_trigger_w;
        1: sel_in_s = input_reg_sync;
    endcase
end

Counter f2(
    .clk_i(clk_i),                      
    .rstn_i(rstn_i),                    
    .clear(cmd_clear_w),
    .trigger_sel(cnt_timer_trigger_sel_w), 
    .capture_sel(cnt_timer_capt_sel_w), 
    .target_value(cnt_timer1_target_w),
    .ctrl0_mode_i(ctrl0_w),
    .duty_cycle_i(pwm_mode_duty_cycle_w),  
    .out_function(cnt_timer_out_w),
    .freq_sel_i(pwm_mode_freq_w),
    .output_o(output_o),
    .captured_value(captured_status_value_w),
    .tm_running_o(captured_status_tm_running_w),
    .counter_o(act_cnt_val_w)
    );


endmodule