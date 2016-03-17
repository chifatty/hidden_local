import ddf.minim.*;
import nl.tue.id.oocsi.*;


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
final String client = Art_Piece_B;

// Files
final String Music_Hello = "hello.wav";
final String Music_Goodbye = "goodbye.wav";

// Global variables
int press_count = 0;
boolean normal = false;
String position = Position_None;
AudioPlayer player;
Minim minim;
OOCSI oocsi;

// Play Music
boolean play_music = true;
String music_lead = Art_Piece_None; 
String music_file = client + ".wav";

// Interrupt
boolean been_interrupt = true;
boolean need_interrupt = false;
boolean doing_interrupt = false;
int interrupt_time = 0;

// Play farewell
boolean need_play_farewell = false;
boolean doing_play_farewell = false;
boolean leave_after_farewell = false;

// Say Hello
boolean need_say_hello = false;
boolean doing_say_hello = false;
int say_hello_time = 0;
int say_hello_count = 0;

// Ans Hello
boolean need_ans_hello = false;
boolean doing_ans_hello = false;
int ans_hello_time = 0;

// Say Goodbye
boolean need_say_goodbye = false;
boolean doing_say_goodbye = false;
int say_goodbye_time = 0;
int say_goodbye_count = 0;

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
  oocsi.subscribe(Channel_Gallery);
  oocsi.subscribe(Channel_Home);
  oocsi.subscribe(Channel_Visitor);
}

void draw()
{
  interrupt();
  sayHello();
  ansHello();
  playFarewell();
  sayGoodbye();
  ansGoodbye();
  lightup();
  playMusic();
}

void playMusic()
{
  if (doing_interrupt || doing_say_hello || doing_ans_hello || 
    doing_play_farewell || doing_say_goodbye || doing_ans_goodbye || doing_lightup)
    return;
  if (!play_music)
    return;
  if (been_interrupt) {
    been_interrupt = false;
    println("start play music:" + music_file);
    player = minim.loadFile(music_file);
    if (player != null) {
      player.play();
      player.loop();
    }
  }
  if (player != null) {
    int value = int(player.left.level() * 255);
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

void setupSayHello()
{
  need_say_hello = true;
  doing_say_hello = false;
}

void sayHello() 
{
  if (doing_interrupt)
    return;
  if (!need_say_hello)
    return;
  if (!doing_say_hello) {
    println("start say hello");
    doing_say_hello = true;
    say_hello_count = 2;
    say_hello_time = millis();
    player = minim.loadFile(Music_Hello);
    player.play();
  }
  if (!player.isPlaying()) {
    say_hello_count--;
    if (say_hello_count > 0) {
      player.rewind();
      player.play();
    }
    else if (millis() - say_hello_time > 6000) {
      need_say_hello = false;
      doing_say_hello = false;
      println("done say hello");
      setupLightup();
    }
  }
  background(int(player.left.level() * 255));
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
    player = minim.loadFile(Music_Hello);
    //player.play();
  }
  if (millis() - ans_hello_time > 4000 && !player.isPlaying()) {
    player.play();
  }
  else if (millis() - ans_hello_time > 6000) {
    player.pause();
    need_ans_hello = false;
    doing_ans_hello = false;
    println("done ans hello");
    setupLightup();
  }
  background(int(player.left.level() * 255));
}


void setupPlayFarewell()
{
  need_play_farewell = true;
  doing_play_farewell = false;
}

void playFarewell()
{
  if (doing_interrupt)
    return;
  if (!need_play_farewell)
    return;
  if (!doing_play_farewell) {
    println("start play farewell");
    doing_play_farewell = true;
    player = minim.loadFile(client + "_farewell_special.wav");
    player.play();
  }
  if (!player.isPlaying()) {
    need_play_farewell = false;
    doing_play_farewell = false;
    println("done play farewell");
    if (leave_after_farewell) 
      setupSayGoodbye();
    else
      setupAnsGoodbye();
  }
  background(int(player.left.level() * 255));
}

void setupSayGoodbye()
{
  need_say_goodbye = true;
  doing_say_goodbye = false;
}

void sayGoodbye() 
{
  if (doing_interrupt)
    return;
  if (!need_say_goodbye)
    return;
  if (!doing_say_goodbye) {
    println("start say goodbye");
    doing_say_goodbye = true;
    say_goodbye_time = millis();
    player = minim.loadFile(Music_Goodbye);
    player.play();
    player.loop(1);
  }
  if (millis() - say_goodbye_time > 6000) {
    need_say_goodbye = false;
    doing_say_goodbye = false;
    println("done say goodbye");
  }
  background(int(player.left.level() * 255));
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
    player = minim.loadFile(Music_Goodbye);
  }
  if (millis() - ans_goodbye_time > 4000 && !player.isPlaying()) {
    player.play();
  }
  else if (millis() - ans_goodbye_time > 6000) {
    player.pause();
    need_ans_goodbye = false;
    doing_ans_goodbye = false;
    println("done ans goodbye");
    setupLightup();
  }
  background(int(player.left.level() * 255));
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
    if (millis() - lightup_time > 7000) {
      need_lightup = false;
      doing_lightup = false;
      println("done lightup");
    }
    else if (millis() - lightup_time < 6000){
      int value = abs(int(lightup_ratio * sin(float((millis() - lightup_time)) / 2000.0 * HALF_PI) * 255));
      background(value);
    }
    else {
      int value = abs(int(lightup_ratio * 255));
      background(value);
    }
  }
}


void galleryChannel(OOCSIEvent event) 
{
  String who = event.getString("who");
  String act = event.getString("act");
  println("Gallery:" + who + " - " + act);
  if (act.equals("enter")) {
    if (who.equals(client)) {
      position = Position_Gallery;
      lightup_ratio = 0.5;
      play_music = true;
      setupInterrupt();
      setupSayHello();
    }
    else if (position.equals(Position_Gallery)) {
      lightup_ratio = 1;
      setupInterrupt();
      setupAnsHello();
    }
  }
  else if (act.equals("leave") && position.equals(Position_Gallery)) {
    if (who.equals(client)) {
      position = Position_None;
      setupInterrupt();
      setupPlayFarewell();
      leave_after_farewell = true;
    }
    else {
      lightup_ratio = 1;
      setupInterrupt();
      setupPlayFarewell();
      leave_after_farewell = false;
    }
  }
}

void homeChannel(OOCSIEvent event) 
{
  String who = event.getString("who");
  String act = event.getString("act");
  println("Home:" + who + " - " + act);
  if (act.equals("enter")) {
    if (who.equals(client)) {
      position = Position_Home;
      lightup_ratio = 1;
      setupInterrupt();
      setupSayHello();
    }
    else if (position.equals(Position_Home)) {
    }
  }
  else if (act.equals("leave") && position.equals(Position_Home)) {
    if (who.equals(client)) {
      play_music = false;
      position = Position_None;
      setupInterrupt();
      setupSayGoodbye();
    }
    else {
    }
  }
}

void visitorChannel(OOCSIEvent event)
{
  String who = event.getString("who");
  String act = event.getString("act");
  println("Visitor:" + who + " - " + act);
  println(position);
  println(music_lead);
  if (position.equals(Position_Gallery)) {
    if (who.equals(music_lead))
      return;
    setupInterrupt();
    music_lead = who;
    if (who.equals(client) || who.equals(Art_Piece_None)) {
      music_file = client + ".wav";
      return;
    }
    music_file = client + "_support_" + who + ".wav";
    return;
  }
}