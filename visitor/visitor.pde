import ddf.minim.*;
import nl.tue.id.oocsi.*;
import processing.io.*;

// Server
final String Server = "disa.csie.ntu.edu.tw";
final String Art_Piece_A = "A";
final String Art_Piece_B = "B";
final String Art_Piece_C = "C";
final String Art_Piece_None = "None";
final String Channel_Visitor = "visitorChannel";
final String client = "visitor";

// IO
final int Pin_A = 2;
final int Pin_B = 3;
final int Pin_C = 4;


// Global variables
int press_count = 0;
OOCSI oocsi;

void setup()
{
  size(100, 100);
  // Setup IO
  GPIO.pinMode(Pin_A, GPIO.INTPUT);
  GPIO.pinMode(Pin_B, GPIO.INTPUT);
  GPIO.pinMode(Pin_C, GPIO.INTPUT);
  oocsi = new OOCSI(this, client, Server);
} 

void draw()
{
  checkPin();
}

void checkPin()
{
  if (millis() - check_pin_time > 2000) {
    check_pin_time = millis();
    if (GPIO.digitalRead(Pin_A) == GPIO.HIGH) {
      oocsi.channel(Channel_Visitor).data("who", "A").data("act", "lead").send();
    }
    else if (GPIO.digitalRead(Pin_B) == GPIO.HIGH) {
      oocsi.channel(Channel_Visitor).data("who", "B").data("act", "lead").send();
    }
    else if (GPIO.digitalRead(Pin_C) == GPIO.HIGH) {
      oocsi.channel(Channel_Visitor).data("who", "C").data("act", "lead").send();
    }
}