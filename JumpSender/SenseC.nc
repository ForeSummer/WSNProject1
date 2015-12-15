/*
 * Author: Yingda
 * Create time: 2015/12/14 20:27
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 100

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
	sense_msg_t* recv_pkt;

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
  	while (busy) {}
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)(call Packet.getPayload(&packet, NULL));
			this_pkt->nodeID = 1;
			this_pkt->temp = cur_temp;
			this_pkt->humid = cur_humid;
			this_pkt->light = cur_light;
			this_pkt->seq = ++counter;
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
			call Timer.startPeriodic(SAMPLING_FREQUENCY);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

	event void AMSend.sendDone(message_t* msg, error_t error) {
		//if(&packet == msg) {
			busy = FALSE;
		//}
	}

	task void sendJumpData() {
		while (busy) {}
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = 2;
			this_pkt->temp = recv_pkt->temp;
			this_pkt->humid = recv_pkt->humid;
			this_pkt->light = recv_pkt->light;
			this_pkt->seq = recv_pkt->seq;
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led2Toggle();
			}
		}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if(len == sizeof(sense_msg_t)) {
			recv_pkt = (sense_msg_t*)payload;
			if(recv_pkt -> nodeID == -1) {
				call Leds.led1Toggle();
				post sendJumpData();
			}
		}
		return msg;
	}
}

