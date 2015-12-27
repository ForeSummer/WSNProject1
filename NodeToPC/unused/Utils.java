/*
 * Author: Wang Zhao
 * Create time: 2015/12/19 14:32
 */

import java.util.*;
import java.text.SimpleDateFormat;

public class Utils {
	
	/*
	 * Extract hex values from message, return String[]
	 */
	public static String[] getValue(String str) {
		String[] lines = str.split("\n");
		int length = lines.length;
		String[] result = new String[length-1];
		for (int i = 1; i < length; ++i) {
			result[i-1] = lines[i].split("=")[1].split("]")[0].split("0x")[1];
		}
		return result;
	}
	
	/*
	 * Transfer hex string to oct number
	 */
	public static int[] getNumbers(String[] value) {
		int[] numbers = new int[6];
		numbers[0] = Integer.valueOf(value[0], 16).intValue();	// ID
		numbers[1] = Integer.valueOf(value[4], 16).intValue();	// SeqNo
		numbers[2] = Integer.valueOf(value[1], 16).intValue();	// Temprature
		numbers[3] = Integer.valueOf(value[2], 16).intValue();	// Humidity
		numbers[4] = Integer.valueOf(value[3], 16).intValue();	// Illumination
		numbers[5] = Integer.valueOf(value[5], 16).intValue();	// Time
		return numbers;
	}

	/*
	 * Get current time
	 */
	public static String getTime() {
		Date now = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
	  return dateFormat.format(now);
	}
}
