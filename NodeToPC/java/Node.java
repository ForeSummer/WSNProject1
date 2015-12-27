/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Class holding all data received from a mote.
 */
class Node {
    /* Data is hold in an array whose size is a multiple of INCREMENT, and
       INCREMENT itself must be a multiple of Constant.NREADINGS. This
       simplifies handling the extension and clipping of old data
       (see setEnd) */
    final static int INCREMENT = 100 * Constants.NREADINGS;
    final static int MAX_SIZE = 100 * INCREMENT; // Must be multiple of INCREMENT

    /* The mote's identifier */
    int id;

    /* Data received from the mote. data[0] is the dataStart'th sample
       Indexes 0 through dataEnd - dataStart - 1 hold data.
       Samples are 16-bit unsigned numbers, -1 indicates missing data. */
    int[] temp_data, humid_data, light_data;
    int dataStart, dataEnd;

    Node(int _id) {
    id = _id;
    }

    /* Update data to hold received samples newDataIndex .. newEnd.
       If we receive data with a lower index, we discard newer data
       (we assume the mote rebooted). */
    private void setEnd(int newDataIndex, int newEnd) {
    if (newDataIndex < dataStart || temp_data == null) {
        /* New data is before the start of what we have. Just throw it
           all away and start again */
        dataStart = newDataIndex;
        temp_data = new int[INCREMENT];
        humid_data = new int[INCREMENT];
        light_data = new int[INCREMENT];
    }
    if (newEnd > dataStart + temp_data.length) {
        /* Try extending first */
        if (temp_data.length < MAX_SIZE) {
        int newLength = (newEnd - dataStart + INCREMENT - 1) / INCREMENT * INCREMENT;
        if (newLength >= MAX_SIZE) {
            newLength = MAX_SIZE;
        }

        int[] temp_newData = new int[newLength];
        System.arraycopy(temp_data, 0, temp_newData, 0, temp_data.length);
        temp_data = temp_newData;

        int[] humid_newData = new int[newLength];
        System.arraycopy(humid_data, 0, humid_newData, 0, humid_data.length);
        humid_data = humid_newData;

        int[] light_newData = new int[newLength];
        System.arraycopy(light_data, 0, light_newData, 0, light_data.length);
        light_data = light_newData;

        }
        if (newEnd > dataStart + temp_data.length) {
        /* Still doesn't fit. Squish.
           We assume INCREMENT >= (newEnd - newDataIndex), and ensure
           that dataStart + data.length - INCREMENT = newDataIndex */
        int newStart = newDataIndex + INCREMENT - temp_data.length;

        if (dataStart + temp_data.length > newStart) {
            System.arraycopy(temp_data, newStart - dataStart, temp_data, 0,
                     temp_data.length - (newStart - dataStart));
            System.arraycopy(humid_data, newStart - dataStart, humid_data, 0,
                     humid_data.length - (newStart - dataStart));
            System.arraycopy(light_data, newStart - dataStart, light_data, 0,
                     light_data.length - (newStart - dataStart));
        }
        dataStart = newStart;
        }
    }
    /* Mark any missing data as invalid */
    for (int i = dataEnd < dataStart ? dataStart : dataEnd;
         i < newDataIndex; i++) {
        temp_data[i - dataStart] = -1;
        humid_data[i - dataStart] = -1;
        light_data[i - dataStart] = -1;
    }

    /* If we receive a count less than the old count, we assume the old
       data is invalid */
    dataEnd = newEnd;

    }

    /* Data received containing NREADINGS samples from messageId * NREADINGS 
       onwards */
    void update(int messageId, int temp, int humid, int light) {
    int start = messageId * Constants.NREADINGS;
    setEnd(start, start + Constants.NREADINGS);
    temp_data[start - dataStart] = temp;
    humid_data[start - dataStart] = humid;
    light_data[start - dataStart] = light;
    }

    /* Return value of sample x, or -1 for missing data */
    int getTempData(int x) {
    if (x < dataStart || x >= dataEnd) {
    		//System.out.println("x: " + x + " dataStart: " + dataStart + " dataEnd: " + dataEnd);
    		//System.out.println("Node   missing data");
        return -1;
    } else {
        return temp_data[x - dataStart];
    }
    }

    int getHumidData(int x) {
    if (x < dataStart || x >= dataEnd) {
        return -1;
    } else {
        return humid_data[x - dataStart];
    }
    }

    int getLightData(int x) {
    if (x < dataStart || x >= dataEnd) {
        return -1;
    } else {
        return light_data[x - dataStart];
    }
    }

    /* Return number of last known sample */
    int maxX() {
    return dataEnd - 1;
    }
}
