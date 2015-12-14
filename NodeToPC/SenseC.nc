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
  
  event void Boot.booted() {
  	call Control.start();
  }

  event void Timer.fired() {
    call Read1.read();
    call Read2.read();
    call Read3.read();
  }

  event void Read1.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			call Leds.led0On();
  	} else {
			call Leds.led0Off();
  	}
  }

  event void Read2.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS) {
			call Leds.led1On();
  	} else {
			call Leds.led1Off();
  	}
  }

  event void Read3.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			call Leds.led2On();
  	} else {
			call Leds.led2Off();
  	}
  }

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call MilliTimer.startPeriodic(SAMPLINT_FREQUENCY);
		}
  }

  event void Control.stopDone(error_t err) {}
}
