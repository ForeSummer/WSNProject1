/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Sense.h"

configuration SenseAppC {} 
implementation { 
  
  components SenseC, MainC, LedsC;
  components SerialActiveMessageC as AM;

	components new AMSenderC(AM_MSG);
	components ActiveMessageC;
  components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Control2 -> AM;
  SenseC.AMSend1 -> AM.AMSend[AM_SENSE_MSG_T];
  SenseC.Packet1 -> AM;

	SenseC.Control1 -> ActiveMessageC;
	SenseC.Packet2 -> AMSenderC;
	SenseC.AMSend2 -> AMSenderC;
  SenseC.Receive -> AMReceiverC;
  SenseC.Receive -> AM.Receive[AM_SENSE_MSG_T];
}
