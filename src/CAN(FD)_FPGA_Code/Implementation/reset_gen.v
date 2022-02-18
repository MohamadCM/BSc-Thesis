module reset_gen (
	rstn,
	clk,
	on,
	off,
	o_pwr,
	o_rst,
	o_rst_aux
);
	parameter DEFAULT = 0;
	parameter RESETHL = 0;
	parameter RESETHL_AUX = 0;
	parameter tP = 10000000;
	parameter tR = 10000000;
	input wire rstn;
	input wire clk;
	input wire on;
	input wire off;
	output wire o_pwr;
	output wire o_rst;
	output wire o_rst_aux;
	localparam tA = 1;
	localparam tB = 1 + tP;
	localparam tC = (1 + tP) + tR;
	localparam tD = ((1 + tP) + tR) + 1;
	reg [1:0] out;
	reg [31:0] cnt;
	assign o_pwr = out[1];
	assign o_rst = (RESETHL ? ~out[0] : out[0]);
	assign o_rst_aux = (RESETHL_AUX ? ~out[0] : out[0]);
	always @(posedge clk or negedge rstn)
		if (~rstn) begin
			out <= 2'b00;
			cnt <= 0;
		end
		else if (off) begin
			out <= 2'b00;
			cnt <= tD;
		end
		else if (on) begin
			out <= 2'b00;
			cnt <= tA;
		end
		else if (cnt < tA) begin
			out <= 2'b00;
			cnt <= (DEFAULT ? tA : tD);
		end
		else if (cnt < tB) begin
			out <= 2'b00;
			cnt <= cnt + 1;
		end
		else if (cnt < tC) begin
			out <= 2'b10;
			cnt <= cnt + 1;
		end
		else if (cnt < tD) begin
			out <= 2'b11;
			cnt <= cnt + 1;
		end
		else if (cnt > tD) begin
			out <= 2'b00;
			cnt <= 0;
		end
endmodule
