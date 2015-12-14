/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:53
 */

#ifndef SENSE_H
#define SENSE_H

typedef nx_struct sense_msg {
	nx_uint16_t temp;
	nx_uint16_t humid;
	nx_uint16_t light;
} sense_msg_t;

#endif
