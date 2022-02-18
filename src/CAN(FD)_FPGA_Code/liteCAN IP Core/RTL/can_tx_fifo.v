module can_tx_fifo (
	rstn,
	clk,
	emptyn,
	itvalid,
	itready,
	itdata,
	otvalid,
	otready,
	otdata
);
	parameter AWIDTH = 10;
	parameter DWIDTH = 8;
	input wire rstn;
	input wire clk;
	output wire emptyn;
	input wire itvalid;
	output wire itready;
	input wire [DWIDTH - 1:0] itdata;
	output wire otvalid;
	input wire otready;
	output wire [DWIDTH - 1:0] otdata;
	localparam [AWIDTH - 1:0] ONE = 1;
	reg [AWIDTH - 1:0] wpt;
	reg [AWIDTH - 1:0] rpt;
	reg dvalid;
	reg valid;
	reg [DWIDTH - 1:0] datareg;
	wire rreq;
	wire [DWIDTH - 1:0] rdata;
	assign emptyn = rpt != wpt;
	assign itready = rpt != (wpt + 1);
	assign otvalid = valid | dvalid;
	assign rreq = emptyn & (otready | ~otvalid);
	assign otdata = (dvalid ? rdata : datareg);
	always @(posedge clk or negedge rstn)
		if (~rstn)
			wpt <= 0;
		else if (itvalid & itready)
			wpt <= wpt + ONE;
	always @(posedge clk or negedge rstn)
		if (~rstn)
			rpt <= 0;
		else if (rreq & emptyn)
			rpt <= rpt + ONE;
	always @(posedge clk or negedge rstn)
		if (~rstn) begin
			dvalid <= 1'b0;
			valid <= 1'b0;
			datareg <= 0;
		end
		else begin
			dvalid <= rreq;
			if (dvalid)
				datareg <= rdata;
			if (otready)
				valid <= 1'b0;
			else if (dvalid)
				valid <= 1'b1;
		end
	sync_ram #(
		.DWIDTH(DWIDTH),
		.AWIDTH(AWIDTH)
	) ram_for_fifo(
		.clk(clk),
		.wen(itvalid),
		.waddr(wpt),
		.wdata(itdata),
		.raddr(rpt),
		.rdata(rdata)
	);
endmodule
module sync_ram (
	clk,
	wen,
	waddr,
	wdata,
	raddr,
	rdata
);
	parameter AWIDTH = 10;
	parameter DWIDTH = 32;
	input wire clk;
	input wire wen;
	input wire [AWIDTH - 1:0] waddr;
	input wire [DWIDTH - 1:0] wdata;
	input wire [AWIDTH - 1:0] raddr;
	output reg [DWIDTH - 1:0] rdata;
	reg [DWIDTH - 1:0] mem [0:(1 << AWIDTH) - 1];
	always @(posedge clk)
		if (wen)
			mem[waddr] <= wdata;
	always @(posedge clk) rdata <= mem[raddr];
endmodule
