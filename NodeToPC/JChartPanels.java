/* 
 * Author: Wang Zhao
 * Create time: 2015/12/19 15:29
 */

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.*;
import java.lang.*;
  
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

public class JChartPanels {

	private ChartPanel[] chartPanels = new ChartPanel[6];

	public JChartPanels() {
		XYDataset[] datasets = createXYDataset("./result.txt");
		for (int i = 0; i < 6; ++i) {
			JFreeChart freeChart = createChart(datasets[i], "chart");
			chartPanels[i] = new ChartPanel(freeChart);
			//saveAsFile(freeChart, "./lineXY" + i + ".png", 2000, 500);
		}
		/*chartPanels[0].setBounds(0, 0, 400, 300);
		chartPanels[2].setBounds(400, 0, 400, 300);
		chartPanels[4].setBounds(800, 0, 400, 300);
		chartPanels[1].setBounds(0, 300, 400, 300);
		chartPanels[3].setBounds(400, 300, 400, 300);
		chartPanels[5].setBounds(800, 300, 400, 300);*/
	}

	public ChartPanel getChartPanel(int i) {
		return chartPanels[i];
	}

	private void saveAsFile(JFreeChart chart, String outputPath, int width, int height) {
		try {
			File file = new File(outputPath);
			if (!file.getParentFile().exists()) {
				file.getParentFile().mkdirs();
			}
			FileOutputStream fos = new FileOutputStream(outputPath);
			ChartUtilities.writeChartAsPNG(fos, chart, width, height);
			fos.flush();
			fos.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private JFreeChart createChart(XYDataset dataset, String title) {
		JFreeChart jfreechart = ChartFactory.createXYLineChart(
			title,	// title
			"time", // x axis label
			"value", // y axis label
			dataset, // dataset
			PlotOrientation.VERTICAL, // vertical chart
			true, // legend
			false, // tooltips
			false // URLS
		);

		XYPlot plot = (XYPlot) jfreechart.getPlot();
		NumberAxis numberAxis = (NumberAxis) plot.getRangeAxis();

		numberAxis.setAutoRangeIncludesZero(false);
		numberAxis.setAutoRangeStickyZero(false);
		numberAxis.setAutoRange(true);

		return jfreechart;
	}

	private XYDataset[] createXYDataset(String filePath) {
		XYSeriesCollection[] xySeriesCollections = new XYSeriesCollection[6];
		for (int i = 0; i < 6; ++i) {
			xySeriesCollections[i] = new XYSeriesCollection();
		}
	
		XYSeries xyseries1 = new XYSeries("Temprature #1");
		XYSeries xyseries2 = new XYSeries("Temprature #2");
		XYSeries xyseries3 = new XYSeries("Humidity #1");
		XYSeries xyseries4 = new XYSeries("Humidity #2");
		XYSeries xyseries5 = new XYSeries("Illumination #1");
		XYSeries xyseries6 = new XYSeries("Illumination #2");

		try {
			File file = new File(filePath);
			BufferedReader br = new BufferedReader(new FileReader(file));
			String line = null;
			while ((line = br.readLine()) != null) {
				String[] nums = line.split("\t");
				int ID = Integer.valueOf(nums[0], 10);
				int seqNo = Integer.valueOf(nums[1], 10);
				int temp = Integer.valueOf(nums[2], 10);
				int humid = Integer.valueOf(nums[3], 10);
				int ill = Integer.valueOf(nums[4], 10);

				if (ID == 1) {
					xyseries1.add(seqNo, temp);
					xyseries3.add(seqNo, humid);
					xyseries5.add(seqNo, ill);
				} else {
					xyseries2.add(seqNo, temp);
					xyseries4.add(seqNo, humid);
					xyseries6.add(seqNo, ill);
				}
			}
			br.close();
		} catch (IOException e) {
			e.printStackTrace();
		}

		xySeriesCollections[0].addSeries(xyseries1);
		xySeriesCollections[1].addSeries(xyseries2);
		xySeriesCollections[2].addSeries(xyseries3);
		xySeriesCollections[3].addSeries(xyseries4);
		xySeriesCollections[4].addSeries(xyseries5);
		xySeriesCollections[5].addSeries(xyseries6);
		return xySeriesCollections;
	}
}

