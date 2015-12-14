/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 1000

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

	bool locked = FALSE;
	bool busy = FALSE;

	uint16_t cur_temp = 0;
	uint16_t cur_humid = 0;
	uint16_t cur_light = 0;
	
	uint16_t counter = 0;
  
  event void Boot.booted() {
  	call Control.start();
  }

  task void sendData() {
		counter++;
		cur_temp = counter;
		cur_humid = counter;
		cur_light = counter;

		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)(call Packet.getPayload(&packet, NULL));
			this_pkt -> temp = cur_temp;
			this_pkt -> humid = cur_humid;
			this_pkt -> light = cur_light;
			this_pkt -> nodeID = -1;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
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
			cur_temp = data;
  	} else {
  	}
  }

  event void Read3.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			cur_temp = data;
  	} else {
  	}
  }

  

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(SAMPLING_FREQUENCY);
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

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if(len == sizeof(sense_msg_t)) {
			sense_msg_t* this_pkt = (sense_msg_t*)payload;
			//call Leds.set(this_pkt -> temp);
		}
		return msg;
	}
  
}





