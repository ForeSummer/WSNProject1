import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class changeFreq implements MessageListener {

  private MoteIF moteIF;
  
  public changeFreq(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new SenseMsg(), this);
  }

  public void sendPackets(int freq) {
    SenseMsg payload = new SenseMsg();
    
    try {
	System.out.println("Sending packet ...");
	payload.set_nodeID(3);
	payload.set_seq(freq);
	moteIF.send(0, payload);
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
    System.out.println("Send Complete!");
    System.exit(1);
  }

  public void messageReceived(int to, Message message) {
    SenseMsg msg = (SenseMsg)message;
    //System.out.println("Received packet sequence number " + msg.get_seq());
  }
  
  private static void usage() {
    System.err.println("usage: changeFreq [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 3) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    changeFreq change = new changeFreq(mif);
    change.sendPackets(Integer.parseInt(args[2]));
  }


}
