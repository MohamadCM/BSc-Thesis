`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Organization: 		Amirkabir University of Technology
// Author: Mohamad 	Chamanmotlagh
// 
// Create Date:    21:03:42 01/30/2022 
// Module Name:    top_config_2 
// Project Name: 		Implementation of a data communication system between a microcontroller 
//							and an FPGA using CAN-FD bus interface and CANOpen Protocol
// Target Devices: 	Xilinx Spartan 3E XC3S400
// Tool versions: 	Xilinx USE V14
// Description: 		TOP Level module for the communication system
//					 		Receives CAN signals from IO and send the data
//							through two CAN-FD modules that are connected 
//							in a loop-back manner
// Dependencies: 		CTU CAN FD IP Core, Genering Clock divider
//
// Revision: 			Revision 0.1
//
//////////////////////////////////////////////////////////////////////////////////

module top_config_2(
    input RX_1,
    output TX_1,
    input RX_2,
    output TX_2,
    input CLK,
    output sending,
    output receiving
    );
	 
//	================Apply Prescaler for CAN====================//
	wire 	clock_out; 				// output clock after dividing the input clock by divisor		
	clock_divider 
	#(28'd40) 						// Prescale factor
	clk_div(
		clk, 
		clock_out
		);
//	==================Send Preiodic Data=======================//		
	reg 		send;
	reg		[31:0] counter;
	reg		[31:0] sent_data = 32'b0;
	always @(posedge clock_out)
		if (counter < 1000000) begin
			counter <= counter + 1;
			send <= 1'b0;
		end
		else begin
			counter <= 0;
			send <= 1'b1;
			sent_data <= sent_data + 1;
		end
//	===============Instantiate CAN-FD modules===================//	
	wire 		[31:0] read_data;			// CAN-FD module 1 Returned data
	
	can_fd_top_apb FDCAN_1(
		.CAN_tx(TX_1), 
		.CAN_rx(RX_1),
		.aclk(clock_out),
		.arstn(1'b1),
		.s_apb_pwdata(sent_data),
		.s_apb_pwrite(send),
		.s_apb_psel(1'b1),
		.scan_enable(),
		.res_n_out(),
		.irq(),
		.timestamp(),
		.s_apb_paddr(),
		.s_apb_penable(1'b1),
		.s_apb_pprot(),
		.s_apb_pready(),
		.s_apb_pslverr(),
		.s_apb_pstrb(),
		.s_apb_prdata()
		);
		
		can_fd_top_apb FDCAN_2(
		.CAN_tx(TX_2), 
		.CAN_rx(RX_2),
		.aclk(clock_out),
		.arstn(1'b1),
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
		.s_apb_pready(receiving),
		.s_apb_pslverr(),
		.s_apb_pstrb(),
		.s_apb_prdata(read_data)
		);

	//	================Write signals to outputs===================//
	//assign data = read_data[7:0];
	
endmodule
