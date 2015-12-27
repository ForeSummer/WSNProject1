/* Author: Wang Zhao
 * Create time: 2015/12/19 20:25
 */

import java.awt.*;
import javax.swing.*;

import org.jfree.chart.ChartPanel;

public class Interface {
	public static void main(String[] args) {
		Frame f = new Frame();
		f.setTitle("title");
		
		JChartPanels jchartpanels = new JChartPanels();
		ChartPanel[] p = new ChartPanel[6];
		for (int i = 0; i < 6; ++i) {
			p[i] = jchartpanels.getChartPanel(i);
		}

		f.add(p[0]);
		f.add(p[2]);
		f.add(p[4]);
		f.add(p[1]);
		f.add(p[3]);
		f.add(p[5]);

		f.setSize(1200, 600);
		f.setLayout(new GridLayout(2, 3));
		//f.pack();
		f.setVisible(true);
	}
}
