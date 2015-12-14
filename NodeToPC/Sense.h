/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:53
 */

#ifndef SENSE_H
#define SENSE_H

typedef nx_struct sense_msg_t {
	nx_uint16_t temp;
	nx_uint16_t humid;
	nx_uint16_t light;
}sense_msg_t;

enum {
	NREADINGS = 1,
  DEFAULT_INTERVAL = 256,
  AM_SENSE_MSG_T = 0x89,
};

#endif
