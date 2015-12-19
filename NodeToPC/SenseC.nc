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
  	interface AMSend as AMSend1;
  	interface AMSend as AMSend2;
  	interface Packet as Packet1;
  	interface Packet as Packet2;
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
	uint32_t curTime = 0;

	uint32_t cur_freq = SAMPLING_FREQUENCY;
  
  event void Boot.booted() {
  	call Control1.start();
  	call Control2.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet1.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = senseData[0];
			this_pkt->temp = senseData[1];
			this_pkt->humid = senseData[2];
			this_pkt->light = senseData[3];
			this_pkt->seq = senseData[4];
			this_pkt->time = curTime;
			this_pkt->token = 0xa849b25c;

			if (call AMSend1.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led2Toggle();
			}
		} else {
			post sendData();
		}
  }

  task void sendChangeFreq() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet2.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = 3;
			this_pkt->seq = cur_freq;

			if (call AMSend2.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led1Toggle();
			}
		} else {
			post sendChangeFreq();
		}
  }
  
	event void AMSend1.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			busy = FALSE;
		}
	}

	event void AMSend2.sendDone(message_t* bufPtr, error_t error) {
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
			if(recv_pkt->nodeID == 3) {
				call Leds.led0Toggle();
				cur_freq = recv_pkt->seq;
				post sendChangeFreq();
			}
			senseData[0] = recv_pkt->nodeID;
			senseData[1] = recv_pkt->temp;
			senseData[2] = recv_pkt->humid;
			senseData[3] = recv_pkt->light;
			senseData[4] = recv_pkt->seq;
			curTime = recv_pkt->time;
			if (recv_pkt->nodeID == 0x1 ||
					recv_pkt->nodeID == 0x2) {
				post sendData();
			}
		}
		return msg;
  }
}
