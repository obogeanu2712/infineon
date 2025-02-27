module Counter(
	input clk_i,
	input rstn_i,
	input selected_in,
	input clear,
	input [1:0] trigger_sel,
	input [1:0] capture_sel,
	input [9:0] target_value,
	input [1:0] ctrl0_mode_i,
	input [9:0] duty_cycle_i,
	input out_function,
	input [1:0] freq_sel_i,
	output reg output_o,
	output reg [9:0] captured_value,
	output [9:0] counter_o,
	output tm_running_o
	);
 
reg [8:0] prescaler_count;
wire cmp_eq, prescaler;
reg [9:0] counter;
reg [9:0] freq_limit;
wire cmp_freq;
wire out_pwm;
reg detector;
wire rise, fall, both;
reg trigger;
reg counting;
reg counter_timer;
wire pwm_mode, pulse_mode, trigger_mode;
reg out_reg;
reg capture;
 
 
//PRESCALER
always@(posedge clk_i or negedge rstn_i) begin
	if((rstn_i == 0) || (cmp_eq == 1)) begin
		prescaler_count <= 0;
	end if(ctrl0_mode_i == 2'b01) begin
		prescaler_count <= prescaler_count + 1;
	end
end
 
assign cmp_eq = (prescaler_count == 499);
 
assign prescaler = cmp_eq; 
 
//COUNTER
always@(posedge clk_i or negedge rstn_i) begin
	if(rstn_i == 0 || clear == 1)
		counter <= 0;
	else begin
		case(ctrl0_mode_i)
		2'b00: begin
			counter <= 0;
		end
		2'b01: begin
				if(prescaler == 1)
					counter <= counter + 1;
			end
		2'b10: begin
		      if(target_value == counter)
		          counter <= 0;
		      if(trigger == 1)
		          counter <= counter + 1;
		end
		2'b11: begin
		      if(trigger == 1)
		          counter <= 1;
		      if(counter >= 1 && counter < target_value)
		          counter <= counter + 1;
		      else counter <= 0;
 
 
		end
		endcase
	end
end
 
//PWM Logic
always@(*) begin
	case(freq_sel_i)
		2'b00: freq_limit = 390;
		2'b01: freq_limit = 194;
		2'b10: freq_limit = 121;
		2'b11: freq_limit = 97;
		default: freq_limit = 97;
	endcase
end
 
always@(posedge clk_i or negedge rstn_i) begin
    if(rstn_i == 0)
        detector <= 0;
    else
        detector <= selected_in;
end
 
 
assign out_pwm = (counter <= duty_cycle_i);
 
assign rise = (selected_in & ~detector);
 
assign fall = (~selected_in & detector);
 
assign both = rise | fall;
 
 
always@(*) begin
    case(trigger_sel)   
        2'b00: trigger = rise;
        2'b01: trigger = fall;
        2'b10: trigger = both;
        2'b11: trigger = 0;
    endcase
end
 
assign pwm_mode = (ctrl0_mode_i[0] & out_pwm);
 
assign pulse_mode = (counter == target_value);
 
assign trigger_mode = (pulse_mode ^ output_o);
 
always@(*) begin
	case(out_function)
		1'b0:	counter_timer = pulse_mode;
		1'b1:	counter_timer = trigger_mode;
	endcase
end
 
always@(*) begin
	case(ctrl0_mode_i[1])
		1'b0: out_reg = pwm_mode;
		1'b1: out_reg = counter_timer;
	endcase
end
 
always@(posedge clk_i or negedge rstn_i) begin
	if(rstn_i == 0)
		output_o <= 0;
	else
		output_o <= out_reg;
 
end
 
 
always@(*) begin
    case(capture_sel)
        2'b00: capture = rise;
        2'b01: capture = fall;
        2'b10: capture = both;
        2'b11: capture = 0;
    endcase
end
 
always@(posedge clk_i or negedge rstn_i) begin
	if(rstn_i == 0)
		captured_value <= 0;
	else	if(capture == 1)
		captured_value <= counter;
end
 
 
assign counter_o = counter;
 
assign tm_running_o = (counter != 0);
 
endmodule