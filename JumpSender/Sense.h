/*
 * Author: Yingda
 * Create time: 2015/12/14 20:27
 */

#ifndef SENSE_H
#define SENSE_H

enum {
    AM_MSG = 6,
    TIMER_PERIOD_MILLI = 250
};

typedef nx_struct sense_msg {
	nx_uint16_t nodeID;
	nx_uint16_t temp;
	nx_uint16_t humid;
	nx_uint16_t light;
} sense_msg_t;

#endif
