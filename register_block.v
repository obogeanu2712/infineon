module register_block(
	input clk_i,
	input rstn_i,
	input acc_en_i,
	input wr_en_i,
	input [2:0] addr_i,
	input [15:0] wdata_i,
	input [9:0] act_cnt_val_i,
	input captured_status_tm_running_i,
	input [9:0] captured_status_value_i,
	output reg [15:0] rdata_o,
	output [1:0] ctrl0_o,
	output [9:0] pwm_mode_duty_cycle_o,
	output [1:0] pwm_mode_freq_o,
	output [3:0] cnt_timer_mode_in_o,
	output [1:0] cnt_timer_trigger_sel_o,
	output cnt_timer_out_o,
	output [1:0] cnt_timer_capt_sel_o,
	output [9:0] cnt_timer1_target_o,
	output cmd_clear_o,
	output cmd_sw_trigger_o
	//output [9:0] captured_status_value_o,
	//output captured_status_tm_running_o
);

reg [9:0] pwm_mode_duty_cycle_reg;
reg [1:0] pwm_mode_freq_reg;
wire [15:0] pwm_mode;

reg [1:0] ctrl0_reg;
wire [15:0] ctrl0;

reg [3:0] cnt_timer_mode_in_reg;
reg [1:0] cnt_timer_trigger_sel_reg;
reg cnt_timer_out_reg;
reg [1:0] cnt_timer_capt_sel_reg;
wire [15:0] cnt_mode0;

reg [9:0] cnt_timer1_target_reg;
wire [15:0] cnt_mode1;

wire [15:0] act_cnt;

//reg cmd_clear_reg;
//reg cmd_sw_trigger_reg;
wire [15:0] cmd;

wire [15:0] captured_value;

reg [9:0] captured_status_value_reg;
reg captured_status_tm_running_reg;

//PWM_MODE WRITE
always@(posedge clk_i or negedge rstn_i) begin
		if(rstn_i == 0) begin
			pwm_mode_duty_cycle_reg <= 0;
			pwm_mode_freq_reg <= 0;
		end else if ((acc_en_i & wr_en_i) == 1 && addr_i == 3'b001) begin
			pwm_mode_duty_cycle_reg <= wdata_i[9:0];
			pwm_mode_freq_reg <= wdata_i[13:12];
		end
	end

//PWM_MODE READ
assign pwm_mode = {2'b00, pwm_mode_freq_reg, 2'b00, pwm_mode_duty_cycle_reg};
assign pwm_mode_duty_cycle_o = pwm_mode_duty_cycle_reg;
assign pwm_mode_freq_o = pwm_mode_freq_reg;



//CTRL0 WRITE
always@(posedge clk_i or negedge rstn_i) begin
		if(rstn_i == 0) begin
			ctrl0_reg <= 0;
		end else if ((acc_en_i & wr_en_i) == 1 && addr_i == 3'b000) begin
			ctrl0_reg <= wdata_i[1:0];
		end
	end
	
	
//CTRL0 READ	
assign ctrl0 = {14'b000_0000_0000_00, ctrl0_reg};
assign ctrl0_o = ctrl0_reg;


//COUNTER MODE0 WRITE
always@(posedge clk_i or negedge rstn_i) begin
		if(rstn_i == 0) begin
			cnt_timer_mode_in_reg <= 0;
			cnt_timer_trigger_sel_reg <= 0;
			cnt_timer_out_reg <= 0;
			cnt_timer_capt_sel_reg <= 0;
		end else if ((acc_en_i & wr_en_i) == 1 && addr_i == 3'b010) begin
			cnt_timer_mode_in_reg <= wdata_i[3:0];
			cnt_timer_trigger_sel_reg <= wdata_i[5:4];
			cnt_timer_out_reg <= wdata_i[8];
			cnt_timer_capt_sel_reg <= wdata_i[13:12];
		end
	end
	

//COUNTER MODE0 READ
assign cnt_mode0 = {2'b00, cnt_timer_capt_sel_reg, 3'b000, cnt_timer_out_reg, 2'b00, cnt_timer_trigger_sel_reg, cnt_timer_mode_in_reg};
assign cnt_timer_mode_in_o = cnt_timer_mode_in_reg;
assign cnt_timer_trigger_sel_o = cnt_timer_trigger_sel_reg;
assign cnt_timer_out_o = cnt_timer_out_reg;
assign cnt_timer_capt_sel_o = cnt_timer_capt_sel_reg;



//COUNTER MODE1 WRITE
always@(posedge clk_i or negedge rstn_i) begin
		if(rstn_i == 0) begin
			cnt_timer1_target_reg <= 0;
		end else if ((acc_en_i & wr_en_i) == 1 && addr_i == 3'b011) begin
			cnt_timer1_target_reg <= wdata_i[9:0];
		end
	end

//COUNTER MODE1 READ
assign cnt_mode1 = {6'b0000_00, cnt_timer1_target_reg};
assign cnt_timer1_target_o = cnt_timer1_target_reg;

//ACTUAL COUNTER VALUE READ
assign act_cnt = {6'b0000_00, act_cnt_val_i};


//COMMAND WRITE
//always@(posedge clk_i or negedge rstn_i) begin
		//if(rstn_i == 0) begin
			//cmd_clear_reg <= 0;
			//cmd_sw_trigger_reg <= 0;
		//end else if ((acc_en_i & wr_en_i) == 1 && addr_i == 3'b101) begin
			//cmd_clear_reg <= wdata_i[0];
			//cmd_sw_trigger_reg <= wdata_i[4];
		//end
	//end

assign cmd_clear_o = acc_en_i & wr_en_i & (addr_i == 3'b101) & wdata_i[0];
assign cmd_sw_trigger_o = acc_en_i & wr_en_i & (addr_i == 3'b101) & wdata_i[4];



//CAPTURED VALUE READ
assign captured_value = {3'b000, captured_status_tm_running_i, 2'b00, captured_status_value_i};
//assign captured_status_value_o = captured_status_value_i;
//assign captured_status_tm_running_o = captured_status_tm_running_i;

always@(*) begin
if(acc_en_i  == 1 && wr_en_i == 0) begin
	case(addr_i)
		3'b000: rdata_o = ctrl0;
		3'b001: rdata_o = pwm_mode;
		3'b010: rdata_o = cnt_mode0;
		3'b011: rdata_o = cnt_mode1;
		3'b100: rdata_o = act_cnt;
		3'b110: rdata_o = captured_value;
		default: rdata_o = 0;
	endcase
	end
	else begin
	rdata_o = 0;
	end
		
end



endmodule