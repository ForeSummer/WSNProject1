/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.font.*;
import java.awt.geom.*;
import java.util.*;

/* Panel for drawing mote-data graphs */
class Graph extends JPanel
{
    final static int BORDER_LEFT = 40;
    final static int BORDER_RIGHT = 0;
    final static int BORDER_TOP = 10;
    final static int BORDER_BOTTOM = 10;

    final static int TICK_SPACING = 40;
    final static int MAX_TICKS = 16;
    final static int TICK_WIDTH = 10;

    final static int MIN_WIDTH = 50;

    int gx0, gx1, gy0, gy1; // graph bounds
    int scale = 2; // gx1 - gx0 == MIN_WIDTH << scale
    Window parent;

    /* Graph to screen coordinate conversion support */
    int height, width;
    double xscale, yscale;

    void updateConversion() {
    height = getHeight() - BORDER_TOP - BORDER_BOTTOM;
    //System.out.println("height: " + height);
    width = getWidth() - BORDER_LEFT - BORDER_RIGHT;
    if (height < 1) {
        height = 1;
    }
    if (width < 1) {
        width = 1;
    }
    xscale = (double)width / (gx1 - gx0 + 1);
    yscale = (double)height / (gy1 - gy0 + 1);
    }

    Graphics makeClip(Graphics g) {
    return g.create(BORDER_LEFT, BORDER_TOP, width, height);
    }

    // Note that these do not include the border offset!
    int screenX(int gx) {
    return (int)(xscale * (gx - gx0) + 0.5);
    }

    int screenY(int gy) {
    return (int)(height - yscale * (gy - gy0));
    }

    int graphX(int sx) {
    return (int)(sx / xscale + gx0 + 0.5);
    }

    Graph(Window parent) {
    this.parent = parent;
    gy0 = 0; gy1 = 0xffff;
    gx0 = 0; gx1 = MIN_WIDTH << scale;
    }

    void rightDrawString(
            Graphics2D g, 
            String s, 
            int x, 
            int y) {
    TextLayout layout =
        new TextLayout(s, parent.smallFont, g.getFontRenderContext());
    Rectangle2D bounds = layout.getBounds();
    layout.draw(g, x - (float)bounds.getWidth(), y + (float)bounds.getHeight() / 2);
    }

    protected void paintComponent(Graphics g) {
    Graphics2D g2d = (Graphics2D)g;

    /* Repaint. Synchronize on Oscilloscope to avoid data changing.
       Simply clear panel, draw Y axis and all the mote graphs. */
    synchronized (parent.parent) {
        updateConversion();
        g2d.setColor(Color.BLACK);
        g2d.fillRect(0, 0, getWidth(), getHeight());
        drawYAxis(g2d);

        Graphics clipped = makeClip(g2d);
        int count = parent.moteListModel.size();
        for (int i = 0; i < count; i++) {
        clipped.setColor(parent.moteListModel.getColor(i));
        drawGraph(clipped, parent.moteListModel.get(i));
        }
    }
    }

    /* Draw the Y-axis */
    protected void drawYAxis(Graphics2D g) {
    int axis_x = BORDER_LEFT - 1;
    int height = getHeight() - BORDER_BOTTOM - BORDER_TOP;

    g.setColor(Color.WHITE);
    g.drawLine(axis_x, BORDER_TOP, axis_x, BORDER_TOP + height - 1);

    /* Draw a reasonable set of tick marks */
    int nTicks = height / TICK_SPACING;
    if (nTicks > MAX_TICKS) {
        nTicks = MAX_TICKS;
    }

    int tickInterval = (gy1 - gy0 + 1) / nTicks;
    if (tickInterval == 0) {
        tickInterval = 1;
    }

    /* Tick interval should be of the family A * 10^B,
       where A = 1, 2 * or 5. We tend more to rounding A up, to reduce
       rather than increase the number of ticks. */
    int B = (int)(Math.log(tickInterval) / Math.log(10));
    int A = (int)(tickInterval / Math.pow(10, B) + 0.5);
    if (A > 2) {
        A = 5;
    } else if (A > 5) {
        A = 10;
    }

    tickInterval = A * (int)Math.pow(10, B);

    /* Ticks are printed at multiples of tickInterval */
    int tick = ((gy0 + tickInterval - 1) / tickInterval) * tickInterval;
    while (tick <= gy1) {
        int stick = screenY(tick) + BORDER_TOP;
        rightDrawString(g, "" + tick, axis_x - TICK_WIDTH / 2 - 2, stick);
        g.drawLine(axis_x - TICK_WIDTH / 2, stick,
               axis_x - TICK_WIDTH / 2 + TICK_WIDTH, stick);
        tick += tickInterval;
    }
    
    }

    /* Draw graph for mote nodeId */
    protected void drawGraph(Graphics g, int nodeId) {
    SingleGraph sg = new SingleGraph(g, nodeId);

    if (gx1 - gx0 >= width) {
        for (int sx = 0; sx < width; sx++)
        sg.nextPoint(g, graphX(sx), sx);
    } else {
        for (int gx = gx0; gx <= gx1; gx++)
        sg.nextPoint(g, gx, screenX(gx));
    }
    }

    /* Inner class to simplify drawing a graph. Simplify initialise it, then
       feed it the X screen and graph coordinates, from left to right. */
    private class SingleGraph {
    int nodeId;
    int lastsx, temp_lastsy, humid_lastsy, light_lastsy;

    /* Start drawing the graph mote id */
    SingleGraph(Graphics g, int id) {
        nodeId = id;
        lastsx = -1;
        temp_lastsy = -1;
        humid_lastsy = -1;
        light_lastsy = -1;
    }

    /* Next point in mote's graph is at x value gx, screen coordinate sx */
    void nextPoint(Graphics g, int gx, int sx) {
        int temp_gy = parent.parent.data.getTempData(nodeId, gx), temp_sy = -1;
        int humid_gy = parent.parent.data.getHumidData(nodeId, gx), humid_sy = -1;
        int light_gy = parent.parent.data.getLightData(nodeId, gx), light_sy = -1;

        //if (nodeId == 2) System.out.println("temp_gy: " + temp_gy);
				temp_gy = (int)(-39.6 + temp_gy * 0.01);
				humid_gy = (int)(-4 + 0.0405 * humid_gy - 0.0000028 * humid_gy * humid_gy);

        if (temp_gy >= 0) { // Ignore missing values
        double temp_rsy = height - yscale * (temp_gy - gy0);

        // Ignore problem values
        if (temp_rsy >= -1e6 && temp_rsy <= 1e6) {
            temp_sy = (int)(temp_rsy + 0.5);
        }
         
        if (temp_lastsy >= 0 && temp_sy >= 0) {
            g.drawLine(lastsx, temp_lastsy, sx, temp_sy);
        }
        }

        if (humid_gy >= 0) { // Ignore missing values
        double humid_rsy = height - yscale * (humid_gy - gy0);

        // Ignore problem values
        if (humid_rsy >= -1e6 && humid_rsy <= 1e6) {
            humid_sy = (int)(humid_rsy + 0.5);
        }
         
        if (humid_lastsy >= 0 && humid_sy >= 0) {
            g.drawLine(lastsx, humid_lastsy, sx, humid_sy);
        }
        }

        if (light_gy >= 0) { // Ignore missing values
        double light_rsy = height - yscale * (light_gy - gy0);

        // Ignore problem values
        if (light_rsy >= -1e6 && light_rsy <= 1e6) {
            light_sy = (int)(light_rsy + 0.5);
        }
         
        if (light_lastsy >= 0 && light_sy >= 0) {
        		//System.out.println("lastsx: " + lastsx + " light_lastsy: " + light_lastsy);
            g.drawLine(lastsx, light_lastsy, sx, light_sy);
        }
        }
        
        lastsx = sx;
        temp_lastsy = temp_sy;
        humid_lastsy = humid_sy;
        light_lastsy = light_sy;
    }
    }

    /* Update X-axis range in GUI */
    void updateXLabel() {
    parent.xLabel.setText("X: " + gx0 + " - " + gx1);
    }

    /* Ensure that graph is nicely positioned on screen. max is the largest 
       sample number received from any mote. */
    private void recenter(int max) {
    // New data will show up at the 3/4 point
    // The 2nd term ensures that gx1 will be >= max
    int scrollby = ((gx1 - gx0) >> 2) + (max - gx1);
    gx0 += scrollby;
    gx1 += scrollby;
    if (gx0 < 0) { // don't bother showing negative sample numbers
        gx1 -= gx0;
        gx0 = 0;
    }
    updateXLabel();
    }

    /* New data received. Redraw graph, scrolling if necessary */
    void newData() {
    int max = parent.parent.data.maxX();

    if (max > gx1 || max < gx0) {
        recenter(max);
    }
    repaint();
    }

    /* User set the X-axis scale to newScale */
    void setScale(int newScale) {
    gx1 = gx0 + (MIN_WIDTH << newScale);
    scale = newScale;
    recenter(parent.parent.data.maxX());
    repaint();
    }

    /* User attempted to set Y-axis range to newy0..newy1. Refuse bogus
       values (return false), or accept, redraw and return true. */
    boolean setYAxis(int newy0, int newy1) {
    if (newy0 >= newy1 || newy0 < 0 || newy0 > 65535 ||
        newy1 < 0 || newy1 > 65535) {
        return false;
    }
    gy0 = newy0;
    gy1 = newy1;
    repaint();
    return true;
    }
}
