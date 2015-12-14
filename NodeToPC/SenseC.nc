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
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
    interface Read<uint16_t> as Read1;
    interface Read<uint16_t> as Read2;
    interface Read<uint16_t> as Read3;
  }
}
implementation {

	message_t packet;

	bool locked = FALSE;
	uint16_t senseData[3] = {0, 0, 0};
  
  event void Boot.booted() {
  	call Control.start();
  }

  event void Timer.fired() {
    call Read1.read();
    call Read2.read();
    call Read3.read();
    
  	if (!locked) {
			sense_msg_t* m = (sense_msg_t*)call Packet.getPayload(&packet, sizeof(sense_msg_t));
			
			if (m == NULL || 
					call Packet.maxPayloadLength() < sizeof(sense_msg_t)) {
				return;
			}

			m->temp = senseData[0];
			m->humid = senseData[1];
			m->light = senseData[2];

			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				locked = TRUE;
			}
  	}
  }

  event void Read1.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			call Leds.led0On();
			senseData[0] = data;
  	} else {
			call Leds.led0Off();
  	}
  }

  event void Read2.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS) {
			call Leds.led1On();
			senseData[1] = data;
  	} else {
			call Leds.led1Off();
  	}
  }

  event void Read3.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			call Leds.led2On();
			senseData[2] = data;
  	} else {
			call Leds.led2Off();
  	}
  }

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			locked = FALSE;
		}
	}

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(SAMPLING_FREQUENCY);
		}
  }

  event void Control.stopDone(error_t err) {}
}
