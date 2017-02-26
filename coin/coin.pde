int numTrials;
int numFlips;
int[] streakChance = {50, 55, 60, 65}; //1 weak, 2 medium, 3 strong
int[] trialTypes = {0, 0, 1, 2, 3};

PFont f;

int trial;
int userResponse;
int trialType; //0 no pattern, 1 strong, 2 medium, 3 weak
int score; 
int head; //if streak, 1 if headstreak, 0 if tail.
int[] responses; //1 = heads, 0 = tails
int[] answers;
String[] curList;

int i; //current flip number

boolean instructions;
boolean nextTrial;
boolean respond;
boolean setup;
boolean setTime = true;
int oldTime;

void setup(){
  size(1000, 700);
  frameRate(1200);
  trial = 0;
  numTrials = trialTypes.length;
  numFlips = 10;
  instructions = true;
  nextTrial = false;
  respond = false;
  responses = new int[numTrials];
  answers = new int[numTrials];
  for (int i = 0; i < numTrials; i++){
    responses[i] = -1;
    answers[i] = -1; //a neutral trial has no correct answers
  }
  curList = new String[numFlips];
  
  setFont(24);
  background(122);
  text("For each trial, please guess what the next coin flip will be.\n" +
        "Press k for heads and l for tails.\n" +
        "Press space to begin.", width/2, height/3);
}

void draw(){
  if (instructions == true);
  else if (nextTrial){
    if (setup){
      trial++;
      if (trial >= numTrials){
        background(122);
        setFont(24);
        text("Thank you. You have finished the experiment.\n" +
        "Please return to Qualtrics.", width/2, height/3);
        noLoop();
      }
      else{
        setFont(28);
        trialType = trialTypes[trial];
        print(score + " ");
        head = int(random(2));
        if (trialType > 0){
          answers[trial - 1] = head;
        }
      }
      i = 0;
      setup = false;
    }
    else if (i < numFlips){
      background(255);
      if (setTime){
        oldTime = millis();
        setTime = false;
      }
      int w = width/(numFlips + 1);
      int h = height/2;
      if (millis() - oldTime < 1000){
        for (int j = 0; j < i; j++)
          text(curList[j], w*(1+j), h);
        if (random(100) <= 50)
          text("H", w*(1+i), h);
        else
          text("T", w*(1+i), h);
        delay((millis() - oldTime)/150);
      }
      else {
        String type = flip();
        curList[i] = type;
        for (int j = 0; j <= i; j++)
          text(curList[j], w*(1+j), h);
        while (millis() - oldTime > 2000);
        i++;
        setTime = true;
      }
    }
    else {
      text("What will the next coin most likely be? k (heads) or l (tails)?", 
              width/2, height/2 + 100);
      nextTrial = false;
      respond = true;
      for (int k = 0; k < responses.length; k++){
        print(responses[k]+" : ");
        print(answers[k]+",");
      }
      println();
    }
  }
}

void keyPressed(){
  if (instructions == true && key == ' '){
     instructions = false;
     nextTrial = true;
     setup = true;
  } else if (respond){ //k for heads, l for tails
    if (key == 'k' || key == 'K' || key == 'L' || key == 'l'){
      if (key == 'k' || key == 'K'){
        responses[trial - 1] = 1;
        if ((trialType >= 0) && head == 1)
          score = score + trialType;
      }
      if (key == 'l' || key == 'L'){
        responses[trial - 1] = 0;
        if ((trialType >= 0) && head == 0)
          score = score + trialType;
      }
      respond = false;
      nextTrial = true;
      setup = true;
    }
  }
}

void finish(){
  background(122);
  setFont(24);
  text("You have finished the experiment.\n" +
        "Please return to Qualtrics.", width/2, height/2);
}

String flip(){
  if (random(100) <= streakChance[trialType]){
    if (head == 1)
      return "H";
    return "T";
  }
  else {
    if (head == 1)
      return "T";
    return "H";
  }
}

// takes number as input and outputs an array of random indices
// for an array of that size, with no index repeated
int[] randIndex(int size) {
  int[] ret = new int[size];
  for (int i = 0; i < size; i++)
    ret[i] = i;
  for (int i = 0; i < size - 1; i++) {
    int rand = int(random(size));
    int temp = ret[i];
    ret[i] = ret[rand];
    ret[rand] = temp;
  }
  return ret;
}

void setFont(int size) {
  f = createFont("Vernada", size);
  fill(0);
  textFont(f);
  textAlign(CENTER);
}