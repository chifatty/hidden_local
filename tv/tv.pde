import ddf.minim.*;
import nl.tue.id.oocsi.*;
import processing.io.*;


// Server
final String Server = "disa.csie.ntu.edu.tw";
final String Art_Piece_A = "A";
final String Art_Piece_B = "B";
final String Art_Piece_C = "C";
final String Art_Piece_None = "None";
final String Position_Gallery = "gallery";
final String Position_Home = "home";
final String Position_None = "none";
final String Channel_Gallery = "galleryChannel";
final String Channel_Home = "homeChannel";
final String Channel_Visitor = "visitorChannel";
final String client = "tv";

// Files
final String Music_Hello = "hello.wav";
final String Music_Goodbye = "goodbye.wav";

// Global variables
int press_count = 0;
boolean normal = false;
String position = Position_Home;
AudioPlayer player;
Minim minim;
OOCSI oocsi;

// system_state 
boolean system_state = false;

// Play Music Home
boolean play_music_home = false;

// Interrupt
boolean been_interrupt = true;
boolean need_interrupt = false;
boolean doing_interrupt = false;
int interrupt_time = 0;

// Ans Hello
boolean need_ans_hello = false;
boolean doing_ans_hello = false;
int ans_hello_time = 0;

// Ans Goodbye
boolean need_ans_goodbye = false;
boolean doing_ans_goodbye = false;
int ans_goodbye_time = 0;

// light up
boolean need_lightup = false;
boolean doing_lightup = false;
float lightup_ratio = 1;
int lightup_time = 0;

void setup()
{
  size(100, 100);
  background(0);
  minim = new Minim(this);
  oocsi = new OOCSI(this, client, Server);
  oocsi.subscribe(Channel_Home);
  analogSetup();
}

void draw()
{
  if (system_state) {
    interrupt();
    ansHello();
    ansGoodbye();
    lightup();
    // playMusicHome();
  }
}

void playMusicHome()
{
  if (doing_interrupt || doing_ans_hello || 
      doing_ans_goodbye || doing_lightup)
    return;
  if (!play_music_home)
    return;
  if (!player.isPlaying()) {
    minim.stop();
    player = minim.loadFile("vacuum.wav");
    player.play();
    player.loop();
  }
  if (player != null) {
    int value = int(player.left.level() * 255);
    analogWrite(value);
    background(value);
  }
}

void setupInterrupt()
{
  need_interrupt = true;
  doing_interrupt = false;
  interrupt_time = 0;
}

void interrupt()
{
  if (!need_interrupt)
    return;
  if (!doing_interrupt) {
    println("start interrupt");
    doing_interrupt = true;
    interrupt_time = millis();
    if (player != null)
      player.shiftVolume(1, 0, 2000);
  }
  if (millis() - interrupt_time > 2000) {
    println("done interupt");
    need_interrupt = false;
    doing_interrupt = false;
    been_interrupt = true;
    if (player != null) {
      player.pause(); 
      player.setVolume(1);
    }
  }
}

void setupAnsHello()
{
  need_ans_hello = true;
  doing_ans_hello = false;
}

void ansHello() 
{
  if (doing_interrupt)
    return;
  if (!need_ans_hello)
    return;
  if (!doing_ans_hello) {
    println("start ans hello");
    doing_ans_hello = true;
    ans_hello_time = millis();
    minim.stop();
    player = minim.loadFile(Music_Hello);
  }
  if (millis() - ans_hello_time > 4000 && !player.isPlaying()) {
    player.mute();
    player.play();
  }
  else if (millis() - ans_hello_time > 6000) {
    player.pause();
    need_ans_hello = false;
    doing_ans_hello = false;
    println("done ans hello");
    setupLightup();
  }
  int value = int(player.left.level() * 255); 
  analogWrite(value);
  background(value);
}


void setupAnsGoodbye()
{
  need_ans_goodbye = true;
  doing_ans_goodbye = false;
}

void ansGoodbye() 
{
  if (doing_interrupt)
    return;
  if (!need_ans_goodbye)
    return;
  if (!doing_ans_goodbye) {
    println("start ans goodbye");
    doing_ans_goodbye = true;
    ans_goodbye_time = millis();
    minim.stop();
    player = minim.loadFile(Music_Goodbye);
  }
  if (millis() - ans_goodbye_time > 4000 && !player.isPlaying()) {
    player.mute();
    player.play();
  }
  else if (millis() - ans_goodbye_time > 6000) {
    player.pause();
    need_ans_goodbye = false;
    doing_ans_goodbye = false;
    println("done ans goodbye");
    setupLightup();
  }
  int value = int(player.left.level() * 255); 
  analogWrite(value);
  background(value);
}

void setupLightup()
{
  need_lightup = true;
  doing_lightup = false;
}

void lightup() 
{
  if (need_lightup == false)
    return;
  if (doing_lightup == false) {
    println("start lightup");
    doing_lightup = true;
    lightup_time = millis();
  }
  else {
    if (millis() - lightup_time > 14000) {
      need_lightup = false;
      doing_lightup = false;
      println("done lightup");
    }
    else if (millis() - lightup_time < 12000){
      int value = abs(int(lightup_ratio * sin(float((millis() - lightup_time)) / 4000.0 * HALF_PI) * 255));
      analogWrite(value);
      background(value);
    }
    else {
      int value = abs(int(lightup_ratio * 255));
      analogWrite(value);
      background(value);
    }
  }
}


void homeChannel(OOCSIEvent event) 
{
  String who = event.getString("who");
  String act = event.getString("act");
  println("Home:" + who + " - " + act);
  if (act.equals("on")) {
    oocsi.channel(Channel_Gallery).data("who", client).data("act", "goingOn").send();
    system_state = true;
  }
  else if (act.equals("off")) {
    oocsi.channel(Channel_Gallery).data("who", client).data("act", "goingOff").send();
    system_state = false;
  }
  else if (act.equals("enter")) {
    lightup_ratio = 0.5;
    play_music_home = true;
    setupInterrupt();
    setupAnsHello();
  }
  else if (act.equals("leave") && position.equals(Position_Home)) {
    lightup_ratio = 0.5;
    play_music_home = false;
    setupInterrupt();
    setupAnsGoodbye();
  }
}

void analogSetup() {
  for (int pin = 3; pin <= 7; pin++) {
    GPIO.pinMode(pin, GPIO.OUTPUT);
    GPIO.digitalWrite(pin, GPIO.LOW);
  }
}

void analogWrite(int value) {
  for (int pin = 3; pin <= 7; pin++) {
    int output = value & (1 << pin);
    if (output != 0) {
      GPIO.digitalWrite(pin, GPIO.HIGH);
    }
    else {
      GPIO.digitalWrite(pin, GPIO.LOW);
    }
  }
}