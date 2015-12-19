/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 1000

module SenseC {
  uses {
  	interface SplitControl as Control1;
  	interface SplitControl as Control2;
  	interface AMSend;
  	interface Packet;
    interface Boot;
    interface Leds;

    interface Receive;
  }
}
implementation {

	message_t packet;
	sense_msg_t* recv_pkt;

	bool busy = FALSE;
	uint16_t senseData[5] = {0, 0, 0, 0, 0};
  
  event void Boot.booted() {
  	call Control1.start();
  	call Control2.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = senseData[0];
			this_pkt->temp = senseData[1];
			this_pkt->humid = senseData[2];
			this_pkt->light = senseData[3];
			this_pkt->seq = senseData[4];

			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led2Toggle();
			}
		} else {
			post sendData();
		}
  }
  
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			busy = FALSE;
		}
	}

  event void Control1.startDone(error_t err) {
		if (err == SUCCESS) {
			
		} else {
			call Control1.start();
		}
  }

  event void Control1.stopDone(error_t err) {}

  event void Control2.startDone(error_t err) {
		if (err == SUCCESS) {
			
		} else {
			call Control2.start();
		}
  }

  event void Control2.stopDone(error_t err) {}

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(sense_msg_t)) {
			recv_pkt = (sense_msg_t*)payload;
			senseData[0] = recv_pkt->nodeID;
			senseData[1] = recv_pkt->temp;
			senseData[2] = recv_pkt->humid;
			senseData[3] = recv_pkt->light;
			senseData[4] = recv_pkt->seq;
			if (recv_pkt->nodeID == 0x1 ||
					recv_pkt->nodeID == 0x2) {
				post sendData();
			}
		}
		return msg;
  }
}
