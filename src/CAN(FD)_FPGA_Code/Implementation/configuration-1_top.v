`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Organization: 		Amirkabir University of Technology
// Author: Mohamad 	Chamanmotlagh
// 
// Create Date:    	16:55:56 01/07/2022 
// Module Name:    	top
// Project Name: 		Implementation of a data communication system between a microcontroller 
//							and an FPGA using CAN-FD bus interface and CANOpen Protocol
// Target Devices: 	Xilinx Spartan 3E XC3S400
// Tool versions: 	Xilinx USE V14
// Description: 		TOP Level module for the communication system
//					 		Receives CAN signals from IO and send the data
//							through two CAN-FD modules that are connected 
//							in a loop-back manner
// Dependencies: 		liteCAN IP Core, CTU CAN FD IP Core, Genering Clock divider
//
// Revision: 			Revision 0.1
//
//////////////////////////////////////////////////////////////////////////////////
module top (
	clk,
	CAN_RX,
	CAN_TX,
	sending,
	received,
	data
);
//	====================IO Signals=============================//
	input 	wire 	clk;						// System Clock
	input 	wire 	CAN_RX;					// CAN Receive signla
	output 	wire 	CAN_TX;					// CAN Transmit signal
	output 	wire 	sending;					// Send indicator
	output 	wire 	received;				// Receive indicator 
	output 	wire 	[7:0]data;				// Received data visualization 
//	===========================================================//
	wire 	rstn;						// Reset line
	reg 	[31:0] can_tx_cnt;	// Sample sent data
	reg 	can_tx_valid;			// Sent data is valid or not
	reg 	[31:0] can_tx_data;	// Sent data
	wire 	can_rx_valid;			// Received data is valid or not
	wire 	[7:0] can_rx_data;	// Recived data
	wire 	clock_out; 				// output clock after dividing the input clock by divisor
	
	assign sending = can_tx_valid;
	assign received = can_rx_valid;
//	=================Generate Reset Signal=====================//	
	reset_gen #(
		.DEFAULT(1),
		.tP(25000),
		.tR(25000)
	) reset_gen_i(
		.rstn(1'b1),
		.clk(clk),
		.on(1'b0),
		.off(1'b0),
		.o_rst(rstn)
	);
//	================Apply Prescaler for CAN====================//		
	clock_divider 
	#(28'd40) 
	clk_div(
		clk, 
		clock_out
		);
//	==================Send Preiodic Data=======================//		
	always @(posedge clock_out or negedge rstn)
		if (~rstn) begin
			can_tx_cnt <= 0;
			can_tx_valid <= 1'b0;
			can_tx_data <= 0;
		end
		else if (can_tx_cnt < 1000000) begin
			can_tx_cnt <= can_tx_cnt + 1;
			can_tx_valid <= 1'b0;
		end
		else begin
			can_tx_cnt <= 0;
			can_tx_valid <= 1'b1;
			//sending <= 1'b1;
			can_tx_data <= can_tx_data + 1;
		end
//	================Instantiate CAN module=====================//			
	can_top #(
		.LOCAL_ID(11'h456),
		.RX_ID_SHORT_FILTER(11'h123),
		.RX_ID_SHORT_MASK(11'h7ff),
		.RX_ID_LONG_FILTER(29'h12345678),
		.RX_ID_LONG_MASK(29'h1fffffff),
		.default_c_PTS(16'd2),
		.default_c_PBS1(16'd1),
		.default_c_PBS2(16'd1)
	) can0_controller(
		.rstn(rstn),
		.clk(clock_out),
		.can_rx(CAN_RX),
		.can_tx(CAN_TX),
		.tx_valid(can_tx_valid),
		.tx_ready(),
		.tx_data(can_tx_data),
		.rx_valid(can_rx_valid),
		.rx_last(),
		.rx_data(can_rx_data),
		.rx_id(),
		.rx_ide()
	);
//	===============Instantiate CAN-FD modules===================//		
	wire 		CAN_FD_TX; 					// CAN-FD module 1 Transmit signal
	wire 		CAN_FD_RX; 					// CAN-FD module 1 Recieve signal
	wire 		[31:0] extended_date;	// Extended data for CAN-FD
	wire 		[31:0] read_data;			// CAN-FD module 1 Returned data
	assign 	extended_data = {24'b0, can_rx_data};
	
	can_fd_top_apb FDCAN_T(
		.CAN_tx(CAN_FD_TX), 
		.CAN_rx(CAN_FD_RX),
		.aclk(clock_out),
		.arstn(rstn),
		.s_apb_pwdata(extended_date),
		.s_apb_pwrite(can_rx_valid),
		.s_apb_psel(1'b1),
		.scan_enable(),
		.res_n_out(),
		.irq(),
		.timestamp(),
		.s_apb_paddr(),
		.s_apb_penable(1'b1),
		.s_apb_pprot(),
		.s_apb_pready(), // Caution
		.s_apb_pslverr(),
		.s_apb_pstrb(),
		.s_apb_prdata()
		);
		
		can_fd_top_apb FDCAN_R(
		.CAN_tx(CAN_FD_RX), 
		.CAN_rx(CAN_FD_TX),
		.aclk(clock_out),
		.arstn(rstn),
		.s_apb_pwdata(),
		.s_apb_pwrite(),
		.s_apb_psel(1'b1),
		.scan_enable(),
		.res_n_out(),
		.irq(),
		.timestamp(),
		.s_apb_paddr(),
		.s_apb_penable(1'b1),
		.s_apb_pprot(),
		.s_apb_pready(), // Caution
		.s_apb_pslverr(),
		.s_apb_pstrb(),
		.s_apb_prdata(read_data)
		);

	//	=================Write Data to outputs=====================//
	
	assign data = read_data[7:0];
	
endmodule


