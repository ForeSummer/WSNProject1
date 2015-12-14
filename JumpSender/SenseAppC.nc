/*
 * Author: Yingda
 * Create time: 2015/12/14 20:27
 */

#include <Timer.h>
#include "Sense.h"

configuration SenseAppC 
{ 
} 
implementation { 
  
  components SenseC,MainC, LedsC, new TimerMilliC();
  components new SensirionSht11C() as SSensor;
  components new HamamatsuS1087ParC() as HSensor;

  components new AMSenderC(AM_MSG);
  components ActiveMessageC;

  components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  SenseC.Read1 -> SSensor.Temperature;
  SenseC.Read2 -> SSensor.Humidity;
  SenseC.Read3 -> HSensor;

  SenseC.Packet -> AMSenderC;
  SenseC.AMPacket -> AMSenderC;
  SenseC.AMSend -> AMSenderC;
  SenseC.Control -> ActiveMessageC;

  SenseC.Receive -> AMReceiverC;
}
