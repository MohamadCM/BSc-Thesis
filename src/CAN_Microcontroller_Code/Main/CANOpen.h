
/**
 * Author: Mohamad Chamanmotlagh
 * Organization: Amirkabir University of Technology
 *
 * Description: CANOpen Functionality
 *
 * Dependencies: --
 *
 * Revision: Revision 0.1
 */

#include "CANOpen.h";

// CANOpen Node structure
typedef struct {
    uint8_t         node_id;       // Node-Id
    uint32_t        Baudrate;     // Baudrate
    struct CO_OBJ_T *Dict;        // object dictionary
    uint16_t        dict_len;      // object dictionary (max) length
} CO_NODE;

// CANOpen Frame structure
typedef struct {
    unit8_t node_id;        // node_id
    unit8_t function_code;  // function of the message
    unit8_t RTR;            // request for data
    unit8_t length;         // length of the data
    unit8_t data;           // payload data
} CO_FRAME;

CO_FRAME* send_co_frame(char* msg){

    size_t msg_count = 0;
    while (msg[msg_count] != '\0') msg_count++;
    CO_FRAME *messages = malloc(sizeof(CO_FRAME) * msg_count);
    int i = 0;

    // Segmenting the whole message
    while (I <= msg_count) {
        CO_FRAME frame;
         // function-code for sending data messages is 0x3
        frame.function_code = 0x3;
         // node-id is assumed 1 for the microcontroller
        frame.node_id = 1;
        frame.RTR = 0;
        frame.length = msg_count - i;
        frame.data = (int)msg;
        messages[i] = frame;
        i++;
    }
    return messages;
}


char * receive_co_frame(CO_FRAME* messages){

    CO_FRAME frame_1 = messages[0];
    if(frame_1.function_code != 0x3)
        return NULL;
    size_t len = messages[0].length;

    char * full_msg = malloc(sizeof(char) * len);
    for (int i = 0; i < len; i++) {
        char msg_char = messages[i].data +'0';
        full_msg[i] = msg_char;
    }
    return full_msg;
}
