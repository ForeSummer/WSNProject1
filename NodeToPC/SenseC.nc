/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 1000
#define NODE_ZERO 633
#define NODE_ONE 622
#define NODE_TWO 589

module SenseC {
  uses {
  	interface SplitControl as Control1;
  	interface SplitControl as Control2;
  	interface AMSend as AMSend1;
  	interface AMSend as AMSend2;
  	interface Packet as Packet1;		//Serial
  	interface Packet as Packet2;		//Node
  	interface AMPacket;
    interface Boot;
    interface Leds;


    interface Receive;
  }
}
implementation {

	message_t packet;
	sense_msg_t* recv_pkt;

	bool busy = FALSE;
	//uint16_t senseData[7] = {0, 0, 0, 0, 0, 0, 0};
	uint16_t curNodeID, curTemp, curHumid, curLight, curSeq, curVersion, curInterval;
	uint32_t curTime = 0, curToken;
	uint16_t version = 0, interval = 100;
  
  event void Boot.booted() {
  	call Control1.start();
  	call Control2.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet1.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = curNodeID;
			this_pkt->temp = curTemp;
			this_pkt->humid = curHumid;
			this_pkt->light = curLight;
			this_pkt->seq = curSeq;
			this_pkt->time = curTime;
			this_pkt->token = curToken;
			this_pkt->version = curVersion;
			this_pkt->interval = curInterval;

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
			this_pkt->time = 0;
			this_pkt->temp = 0;
			this_pkt->humid = 0;
			this_pkt->light = 0;
			this_pkt->token = 0xa849b25c;
			this_pkt->seq = 0;
			this_pkt->version = version;
			this_pkt->interval = interval;

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
			if (recv_pkt->token != 0xa849b25c) {
				return msg;
			} else if (recv_pkt->nodeID == 0x3) {
				version = recv_pkt->version;
				interval = recv_pkt->interval;
				post sendChangeFreq();
			} else if (call AMPacket.destination(msg) == NODE_ZERO) {
				if (call AMPacket.source(msg) == NODE_ONE && (recv_pkt->nodeID == 0x1 || recv_pkt->nodeID == 0x2)) {
					if (recv_pkt->interval != interval) {
						return msg;
					}
					curNodeID = recv_pkt->nodeID;
					curTemp = recv_pkt->temp;
					curHumid = recv_pkt->humid;
					curLight = recv_pkt->light;
					curSeq = recv_pkt->seq;
					curTime = recv_pkt->time;
					curVersion = recv_pkt->version;
					curInterval = recv_pkt->interval;
					curToken = recv_pkt->token;
				
					post sendData();
				}
			} 
		}
		return msg;
  }
}
