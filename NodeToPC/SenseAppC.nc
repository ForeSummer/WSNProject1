/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

configuration SenseAppC 
{ 
} 
implementation { 
  
  components SenseC, MainC, LedsC, new TimerMilliC();
  components new SensirionSht11C() as SSensor;
  components new HamamatsuS1087ParC() as HSensor;

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  SenseC.Read1 -> SSensor.Temperature;
  SenseC.Read2 -> SSensor.Humidity;
  SenseC.Read3 -> HSensor;
}
