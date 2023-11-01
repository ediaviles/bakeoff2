import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;
float logoApproxSideLen = 2 * logoZ / sqrt(2);

// OUR VARIABLES
boolean isDragging = false;
float offsetX = 0;
float offsetY = 0;
float circleX = logoX + logoApproxSideLen / 2;
float circleY = logoY + logoApproxSideLen / 2;
boolean isResizing = false;
float resizeCircleSize = 20f;
boolean isRotating = false;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  //size(1000, 800);  
  fullScreen();
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      if (checkForSuccess()) {
         stroke (0, 255, 0, 255);
      } else {
        stroke(255, 0, 0, 192); //set color to semi translucent
      }
    }
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  
  translate(logoX, logoY); //translate draw center to the center oft he logo square

  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  
    
  stroke(190,190,190,190);
  rect(0, 0, logoApproxSideLen, logoApproxSideLen);
  fill(100, 100, 255, 255);
  noStroke();
  circle(logoApproxSideLen / 2, logoApproxSideLen / 2, resizeCircleSize);
  fill(100, 255, 100, 255);
  circle(0, -logoApproxSideLen / 2, resizeCircleSize);

  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  
  popMatrix();
      
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{    
  //if (isDragging) {
  //  logoX = mouseX + offsetX;
  //  logoY = mouseY + offsetY;
  //}
  if (isResizing) {
    float sizeChange = dist(mouseX, mouseY, logoX, logoY);
    logoZ = constrain(sizeChange, 0.01, inchToPix(4f));
    logoApproxSideLen = 2 * logoZ / sqrt(2);
  }
  
  if (isRotating) {
    PVector vMouse = new PVector(mouseX, mouseY);
    PVector vLogo = new PVector(logoX, logoY);
    vMouse.sub(vLogo);
    logoRotation = ((degrees(vMouse.heading())) + 90)  % 360;
  }
  //left middle, move left
  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if (mouseOnResizeCircle()) {
    isResizing = true;
    offsetX = mouseX;
    offsetY = mouseY;
  } else if (mouseOnRotateCircle()) {
    isRotating = true;
    offsetX = mouseX;
    offsetY = mouseY;  
  }
  //} else if (mouseInDraggingRegion()) {
  //  isDragging = true;
  //  offsetX = logoX - mouseX;
  //  offsetY = logoY - mouseY;
  //}
}

void mouseReleased()
{
  isDragging = false;
  isResizing = false;
  isRotating = false;
  
  //check if it's a double click
  if (mouseEvent.getCount() == 2) // TODO: says this is deprecated but seems to work ok? Might want a better solution
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  } 
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  //println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  //println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  //println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  //println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}


// checks if the mouse is currently within the dragging bounds (white box outline)
boolean mouseInDraggingRegion() {
  return (mouseX >= logoX - logoApproxSideLen / 2 && mouseX <= logoX + logoApproxSideLen / 2 && mouseY >= logoY - logoApproxSideLen / 2
    && mouseY <= logoY + logoApproxSideLen / 2);
}


// returns whether or not the mouse is over the blue resizing circle
boolean mouseOnResizeCircle() { 
  boolean inCircle = false;
  
  translate(logoX, logoY);
  float cx = (logoApproxSideLen/2) * cos(radians(logoRotation)) - (-logoApproxSideLen / 2) * sin(radians(logoRotation));
  float cy = (logoApproxSideLen/2) * sin(radians(logoRotation)) + (-logoApproxSideLen / 2) * cos(radians(logoRotation));
  
  float rx = logoX - cy;
  float ry = logoY + cx;

  inCircle = dist(mouseX, mouseY, rx, ry) <= resizeCircleSize / 2;
  
  return inCircle;
}

// returns whether or not the mouse is over the green rotating circle
boolean mouseOnRotateCircle() {

  translate(logoX, logoY);
  float cx = 0 * cos(radians(logoRotation)) - (logoApproxSideLen / 2) * sin(radians(logoRotation));
  float cy = 0 * sin(radians(logoRotation)) + (logoApproxSideLen / 2) * cos(radians(logoRotation));
  
  float rx = logoX - cx;
  float ry = logoY - cy;
  
  return dist(mouseX, mouseY, rx, ry) <= resizeCircleSize / 2;
  
}
