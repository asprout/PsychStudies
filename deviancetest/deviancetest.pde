// uses images named "xx" where xx>=01, xx is odd for deviant images
// and xx+1 would be the 'normal' version of the image
import java.io.File;

File dir; 
// note: images[0] will be image 1, so EVEN indices mean DEVIANT images
String[] images; //an array of image names

int numTrials;
//testing 100 milliseconds, missing images. 
int[] blockTime = {100, 100, 100, 100}; 

//correct block times for experiment
//int[] blockTime = {100, 150, 250, 1000}; 

int timegrayscr = 750; //time between two images

PFont f;
int oldTime;
boolean acceptRes; //whether or not to accept user response
boolean setTime;
boolean nextTrial; 
boolean nextBlock;
boolean instructions; //only set to true in the beginning
String oKey = " (Normal)                "; //for telling user which is which
String pKey = " (Deviant) ";                //randomized in setup!

// keeping track of useful info
boolean oNormal = true; //which key is normal? (o is default, but randomized in setup)
int trial; //current trial, 0 - images.length - 1
int block;  //current block, 0 - blockTime.length - 1
int imgnum; //number of current image, as per image file name
int userResponse; //deviancy scale 1-7 of image, from less to more
int timeElapsed;  //time user takes to respond
int[] trialList; //random order of indices of imgs to be displayed in current block
img[] imageList; //list of images to be displayed; updated every block
int[] blockList; //random block order to be used

int numberCorrect=0; //number of correct responses
boolean responseType;

void setup() {
  size(1000, 700);

  //testing different frameRate for missing image issues
  //frameRate(60);

  //correct frame rate
  frameRate(1200);

  dir = new File(dataPath("")); 
  images = dir.list(); //an array of image names
  numTrials = images.length;
  blockList = blockTime;
  block = -1;
  acceptRes = false;
  instructions = true;
  nextTrial = false;
  nextBlock = false;
  imageList = new img[numTrials];

  if (random(2) < 1) {
    oNormal = false;
    oKey = " (Deviant)                ";
    pKey = " (Normal) ";
  }

  setFont(24);
  background(122);
  text("In this experiment, you will see a collection of images.\n" +
    "For each image, press the option that corresponds most to your judgment:\n" +
    "o" + oKey + "or                p" + pKey + "\n" +
    "You will have a different amount of time to view the images\n" +
    "in different blocks of the experiment.\n" +
    "You may feel that in some trials the images are displayed too quickly,\n" +
    "and as a result, you may feel that you are just guessing.\n" +
    "This is totally okay! Remember, we are interested in your first impression\n" +
    "and 'snap-judgment,' not in your calculated answer.\n" +
    "Please do your best to remain focused until you reach the 'finish' page\n" +
    "Press space to begin.", width/2, height/4);
}

void draw() {
  if (instructions == true); //wait until user presses space
  else if (nextBlock) { //Move to next block
    background(122);
    setFont(28);
    if (block >= blockList.length - 1) {
      text("You have finished the experiment.\n" +
        "Please return to Qualtrics.", width/2, height/2);
      noLoop();
    } else {
      println(numberCorrect); // temp variable - delete me.
      text("The next block will be block " + (block+2) + " out of " + 
        blockList.length + ".\n" + 
        "Remember, we are not looking for calculated answers.\n" +
        "Just do your best!\n" +
        "Press space to continue.", width/2, height/2.5);
    }
  } else if (nextTrial) { //the user responded; set up next trial
    if (setTime) {
      oldTime = millis();
      setTime = false;
    }
    background(122);
    setFont(75);
    text("+", width/2, height/2);
    if (millis() - oldTime > timegrayscr) {
      trial += 1;
      if (trial > numTrials)
        nextBlock = true;
      setTime = true;
      nextTrial = false;
    }
  } else {
    background(255);
    setFont(28);
    if (setTime) {
      oldTime = millis();
      print("Oldtime: " + oldTime + "\n");
      setTime = false;
    }
    if (millis() - oldTime < blockTime[block]) {
      print(millis()- oldTime + "\n");
      imageList[trial-1].display();
      responseType = imageList[trial-1].deviant;
    }
    text("How deviant is the content of this image?\n" +
      "o" + oKey + "or                p" + pKey, width/2, height/2+200);
    acceptRes = true;
  }
}

void keyPressed() {
  if (instructions == true && key == ' ') {
    instructions = false;
    nextBlock = true;
  } else if (nextBlock) { 
    if (key == ' ') { //after user presses space, move on to next block
      nextBlock = false;
      acceptRes = false;
      trialList = randIndex(images.length);
      for (int i = 0; i < imageList.length; i++) {
        imgnum = trialList[i] + 1;
        imageList[i] = new img(images[trialList[i]], imgnum);
      }
      trial = 0;
      block = block + 1;
      setTime = true;
      nextTrial = true;
    }
  } else if (acceptRes == true) {
    if (key == 'o' || key == 'O' || key == 'P' || key == 'p') {
      acceptRes = false;
      userResponse = key;
      if ((key == 'P' || key == 'p') && responseType == true)
        numberCorrect++;
      if ((key == 'O' || key == 'o') && responseType == false)
        numberCorrect++;
      setTime = true;
      nextTrial = true;
    }
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

// object class for images
class img {
  int id;
  String imgName;
  boolean deviant; //if true, deviant version of image

  img(String name, int num) {
    id = num; //the number found in the imageFile name
    imgName = name;
    deviant = true;
    if (num % 2 == 0)
      deviant = false;
  }

  void display() {
    PImage displayPic;
    displayPic = loadImage(imgName);
    int w = int(displayPic.width/2);
    int h = int(displayPic.height/2);
    displayPic.resize(w, h);
    image(displayPic, width/2-w/2, height/2-h/2);
  }
}