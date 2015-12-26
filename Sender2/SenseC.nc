/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 100
#define NODE_ZERO 633
#define NODE_ONE 622
#define NODE_TWO 589

module SenseC {
  uses {
  	interface SplitControl as Control;
  	interface AMSend;
  	interface Packet;
  	interface AMPacket;
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
    interface Read<uint16_t> as Read1;
    interface Read<uint16_t> as Read2;
    interface Read<uint16_t> as Read3;

    interface Receive;
  }
}
implementation {

	message_t packet;

	bool busy = FALSE;

	uint16_t cur_temp = 0;
	uint16_t cur_humid = 0;
	uint16_t cur_light = 0;
	
	uint16_t counter = 0;

	uint16_t version = 0, interval = 100;
  
  event void Boot.booted() {
  	call Control.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)(call Packet.getPayload(&packet, NULL));
			this_pkt->nodeID = -1;
			this_pkt->temp = cur_temp;
			this_pkt->humid = cur_humid;
			this_pkt->light = cur_light;
			this_pkt->seq = ++counter;
			this_pkt->time = call Timer.getNow();
			this_pkt->token = 0xa849b25c;
			this_pkt->version = version;
			this_pkt->interval = interval;
			
			if (interval == 1) {
				call Leds.led0Toggle();
				call Control.stop();
			}
				
			if(call AMSend.send(NODE_ONE, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led0Toggle();
			}
		}
  }

  event void Timer.fired() {
    call Read1.read();
    call Read2.read();
    call Read3.read();
    post sendData();
  }

  event void Read1.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			cur_temp = data;
  	} else {
  	}
  }

  event void Read2.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS) {
			cur_humid = data;
  	} else {
  	}
  }

  event void Read3.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			cur_light = data;
  	} else {
  	}
  }
  
  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(interval);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

	event void AMSend.sendDone(message_t* msg, error_t error) {
		if(&packet == msg) {
			busy = FALSE;
		}
	}

	task void changeFreq() {
		if (busy) {
			call Leds.led1Toggle();
			call Timer.stop();
			call Timer.startPeriodic(interval);
		} else {
			post changeFreq();
		}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if(call AMPacket.source(msg) == NODE_ZERO && len == sizeof(sense_msg_t)) {
			sense_msg_t* this_pkt = (sense_msg_t*)payload;
			if (this_pkt->token != 0xa849b25c) {
				return msg;
			} else if (this_pkt->nodeID == 3) {
				version = this_pkt->version;
				interval = this_pkt->interval;
				//post changeFreq();
				call Timer.stop();
				call Timer.startPeriodic(interval);
			}
		}
		return msg;
	}
}

