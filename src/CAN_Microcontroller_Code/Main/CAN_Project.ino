/*     Sending and receiving pure CAN messages       */


/**
 * Author: Mohamad Chamanmotlagh
 * Organization: Amirkabir University of Technology
 * 
 * Description: Arduino code for sending and receiving data on CAN bus using CANOpen
 * 
 * Dependencies: due_can library, variant library
 * 
 * Revision: Revision 0.1
 */

// Required libraries
#include "variant.h"
#include <due_can.h>

//random ID
#define TEST1_CAN_TRANSFER_ID    0x456

// CAN frame max data length
#define MAX_CAN_FRAME_DATA_LEN   8
// Number of test frames
#define TEST_MAX_COUNT 10000
// CAN's bit rate
#define BIT_RATE 125000

uint32_t sentFrames, receivedFrames;

//Leave this defined if you use the native port or comment it out if you use the programming port
//#define Serial SerialUSB

// Used frames
CAN_FRAME frame, incoming;

void setup() {

// start serial port at 115200 bps:      
  Serial.begin(115200);
  
// Wait unitl serial monitor is opened  
  while(!Serial);
  
  // Verify CAN0 and CAN1 initialization, baudrate is 1Mb/s:
  if (Can0.begin(BIT_RATE) &&
	  Can1.begin(BIT_RATE)) {
  }
  else {
    Serial.println("CAN initialization (sync) ERROR");
  }
  
  //Initializing the sending frame.
  frame.id = TEST1_CAN_TRANSFER_ID;
  frame.length = MAX_CAN_FRAME_DATA_LEN;
  frame.data.value = 0;
  frame.extended = 1;
  
  // Filter incoming IDs
  Can0.watchFor(TEST1_CAN_TRANSFER_ID);
  
  start_can();
}

// Create traffic on CAN bus
static void start_can(void)
{
  uint32_t counter = 0;
        
  while (1==1) {
    // Send data on bus lines
    if(sentFrames < TEST_MAX_COUNT){
      Can0.sendFrame(frame);
      sentFrames++;
      frame.data.value += 2;
    }
    
    Serial.print((int)frame.data.value);
      Serial.print("\t");

    // Read incoming messages if any is available  
    if (Can0.available() > 0) {
      Can0.read(incoming);
        Serial.print((int)incoming.data.value);
        Serial.print("\t");
      receivedFrames++;
      counter++;
    } else {
      Serial.print("-");
      Serial.print("\t");
    }
     Serial.print(sentFrames);
     Serial.print("\t");
     
     Serial.print(receivedFrames);
     Serial.print("\t");

    // Couting number of errors 
    int total_error_1 = Can0.get_rx_error_cnt() + Can0.get_tx_error_cnt();
    Serial.println(total_error_1);

    // Finish if all of messages hasbeen recieved
    if(receivedFrames == sentFrames)
      break;
  }
}

void loop()
{
}
