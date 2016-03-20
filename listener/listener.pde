
import nl.tue.id.oocsi.*;

// Server
final String Server = "disa.csie.ntu.edu.tw";
final String Art_Piece_A = "A";
final String Art_Piece_B = "B";
final String Art_Piece_C = "C";
final String Art_Piece_None = "None";
final String Channel_Visitor = "visitorChannel";
final String client = "listener";

// Global variables
int press_count = 0;
boolean system_state = false;
OOCSI oocsi;

void setup()
{
  size(512, 200);
  background(0);
  // Setup IO
  oocsi = new OOCSI(this, client, Server);
  oocsi.subscribe("galleryChannel");
  oocsi.subscribe("homeChannel");
  oocsi.subscribe("visitorChannel");
} 

void draw()
{
  background(0);
  if (system_state) {
    text("Press any key to stop the system_state.", 10, 20 );
  }
  else {
    text("Press any key to start the system_state.", 10, 20 );
  }
}

void keyPressed()
{
  if (system_state) {
    system_state = false;
    oocsi.channel("galleryChannel").data("who", "all").data("act", "off").send();
    oocsi.channel("homeChannel").data("who", "all").data("act", "off").send();
    println("Turn off the system");
  }
  else {
    system_state = true;
    oocsi.channel("galleryChannel").data("who", "all").data("act", "on").send();
    oocsi.channel("homeChannel").data("who", "all").data("act", "on").send();
    println("Turn on the system");
  }
}

void galleryChannel(OOCSIEvent e) {
  String who = e.getString("who");
  String act = e.getString("act");
  println("Gallery: " + who + " - " + act);
}

void homeChannel(OOCSIEvent e) {
  String who = e.getString("who");
  String act = e.getString("act");
  println("Home: " + who + " - " + act);
}

void visitorChannel(OOCSIEvent e) {
  String who = e.getString("who");
  String act = e.getString("act");
  println("Visitor: " + who + " - " + act);
}