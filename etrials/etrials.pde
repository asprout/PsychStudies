//TODO: user information and instructions 

import processing.sound.*;

SoundFile error;

int trial; //current trial number
boolean setup; //setting up current trial?
int block; //current block number
int numTrials;
int numBlocks;
int practiceTrials;
int userResponse; //s or k
int timeElapsed; //time user takes for each trial
int maxTimeElapsed; //time before trial automatically ends
int trialType; //s for all normal E's, k for backwards E
int timegrayres; //time user has to respond while in gray screen
int timegrayscr; //time that the grayscreen will be displayed for
int oldTime; //time at the start of the trial
boolean nextTrial;
boolean acceptRes; //whether or not to accept user response
PFont f; //for text

int numletters;
E[] letters;

int[] blockTime = {100, 250, 500, 1000, 1500};
String[] timeDes = {"very fast", "fast", "moderately fast", "a moderate pace", "moderately slow"};
String timeType; //set to one of the items from timeDes depending on the blockTime
boolean timeSet; //is time already set for current block?

boolean instructions;

void setup(){
  error = new SoundFile(this, "error.wav");
  numletters = 36;
  letters = new E[numletters];
  size(1200, 700);
  frameRate(1000);
  practiceTrials = 4;
  numTrials = 20;
  numBlocks = 5;
  timegrayscr = 400; //time of display of fixation cross
  timegrayres = 1500; //time to respond while in gray screen
  trial = 0;
  block = 0;
  acceptRes = false;
  timeSet = false;
  instructions = true;
  f = createFont("Vernada", 28);
  fill(0);
  textFont(f);
  textAlign(CENTER);
  background(122);
  text("In this experiment, you will see a display of objects.\n" +
          "If you spot one that is different from the others, press k.\n" +
          "Otherwise, if you determine that they are all the same, press s.\n" +
          "You will have a different amount of time to view the displays\n" +
          "in each block of the experiment, followed by a blank gray screen for 1.5s.\n" +
          "Please respond as quickly and accurately as possible in this time period.\n" +
          "You will no longer be able to respond once the fixation cross appears on the screen.\n" +
          "You will hear audio feedback if you respond incorrectly.\n" +
          "Press space to begin.", width/2, height/4);
}

void draw(){
  if (instructions == true); //wait until user presses space
  else if (nextTrial == true) //the user responded in time
    grayScreen();
  else if (trial == 0 || trial > numTrials + practiceTrials){ //Move to next block
    acceptRes = false;
    background(122);
    if (block + 1 > numBlocks){
      text("You have finished the experiment.", width/2, height/2);
    }
    else {
      if (!timeSet){ //changes the speed of the next block
        setTime();
        timeSet = true;
      }
      text("The next block will be block " + (block + 1) + " out of " + 
            numBlocks + ".\nIt will be " + timeType + 
            ".\nThe first " + practiceTrials + " trials will be counted" +
            " as practice.\nPress space to continue.", width/2, height/2.5);
    }
  }
  else if (millis() - oldTime > maxTimeElapsed){ //the user took too long
    background(122); //give them timegrayres to respond while in grayscreen
    if (millis() - oldTime > maxTimeElapsed + timegrayres){
      grayScreen();
    }
  } 
  else{
    background(255);
    for (int i = 0; i < numletters; i++)
      letters[i].display();
    acceptRes = true;
    //time(oldTime); //displays time
    if (setup){
      oldTime = millis();
      setup = false;
    }
  }
}

void keyPressed(){
  if (instructions == true && key == ' ')
    instructions = false;
  else if ((trial == 0) || (trial > numTrials + practiceTrials && block < numBlocks)){ //next block
    if (key == ' '){ //after user presses space
      block = block + 1;
      nextTrial = true;
      timeSet = false;
      trial = 0;
    }
  }
  //else if ((nextTrial == false) && (trial <= numTrials) && block <= numBlocks){
  else if (acceptRes == true){
    if (key == 's' || key == 'k'){
      userResponse = key;
      if (userResponse != trialType)
        error.play(); //notify user if they made a mistake
      background(122);
      nextTrial = true;
    }
  }
}

//resets all values and prepares for next trial
void grayScreen(){ 
  background(122);
  acceptRes = false;
  f = createFont("Vernada", 45);
  fill(0);
  textFont(f);
  textAlign(CENTER);
  text("+", width/2, height/2);
  f = createFont("Vernada", 28);
  textFont(f);
  userResponse = 0;
  if (random(2) < 1){ //creates the E objects for the next trial
    trialType = 's';
    letters[0] = new E(0, true, letters);
  }
  else{
    trialType = 'k';
    letters[0] = new E(0, false, letters);
  }
  for (int i = 1; i < numletters; i++)
    letters[i] = new E(i, true, letters);
  delay(timegrayscr);
  trial += 1;
  nextTrial = false;
  setup = true;
  oldTime = millis();
}

//shows time taken so far in current trial
void time(int oldtime){
  f = createFont("Vernada", 16);
  fill(0);
  textFont(f);
  text(millis() - oldtime, 50, 50);
}

//tells the program to wait for however long wait is
void delay(int wait){
  int time = millis();
  while (millis() - time <= wait);
}

//sets the speed type for the current block
void setTime(){
  int btime = int(random(blockTime.length));
  while (blockTime[btime] == 0)
    btime = int(random(blockTime.length));
  maxTimeElapsed = blockTime[btime];
  blockTime[btime] = 0;
  timeType = timeDes[btime];
}

//object class for the E's
class E{
  float x, y;
  int size;
  int id;
  int buffer; //area E's will never appear
  boolean s; //if true, E is normal type, else backwards
  E[] others;
  
  E(int num, boolean norm, E[] prev){
    id = num;
    others = prev;
    s = norm;
    size = 40;
    buffer = 180;
    x = random(width - 2 * (buffer * 2)) + buffer * 2;
    y = random(height - 2 * buffer) + buffer;
    while (collide()){
      x = random(width - 2 * (buffer * 2)) + buffer * 2;
      y = random(height - 2 * buffer) + buffer;
    }
  }  
  //checks that this does not collide against previously made letters or borders
  boolean collide(){
    for (int i = 0; i < id; i++){
      float distance = dist(x + size/2, y + size/2, //since coords are upper left
                       others[i].x + size/2, others[i].y + size/2);
      if (distance < size || x + 20 > width || y + 20 > height)
        return true;
    }
    return false;
  }
  
  void display(){
    PImage letter;
    if (s)
      letter = loadImage("normal.png");
    else
      letter = loadImage("backwards.png");
    letter.resize(size, size);
    image(letter, x, y);
  }
}