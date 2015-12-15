/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Sense.h"

configuration SenseAppC {} 
implementation { 
  
  components SenseC, MainC, LedsC;
  components SerialActiveMessageC as AM;

	//components new AMSenderC(AM_MSG);
	components ActiveMessageC;
  components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Control2 -> AM;
  SenseC.AMSend -> AM.AMSend[AM_SENSE_MSG_T];
  SenseC.Packet -> AM;

	SenseC.Control1 -> ActiveMessageC;
	//SenseC.Packet -> AMSenderC;
	//SenseC.AMSend -> AMSenderC;
  SenseC.Receive -> AMReceiverC;
}
