import controlP5.*;

import processing.serial.*;

Serial myPort;

PrintWriter output;
String[] startCode;

int frame = 1;

float extrusion = 0;
float currentZ = 10;
float zInc = 0.5;
float initZ = 1;
float ExtCoeff = 100;
int layerCounter = 0;
int maxLayers = 10;

int initStage = 0;
int drawingStages = 0; 
// 0 : initialization | 1 : moving | 2 : send temp | 3 : change temp
boolean firstContact = true;
boolean initialization = false;
boolean available = false;
boolean drawing = true;
boolean stop = false;
String received="";

PVector nextPosition;
PVector oldPosition = new PVector(50, 50);

//3DPrinter ultimaker = new 3DPrinter();
pixelFloat memoire = new pixelFloat(100,100);

String[] initString = {
  "G28 \n", 
  "G90 \n", 
  "G0 F3000 X"+ 120 + " Y" + 120 + " Z"+ initZ +" \n", 
  "G91 \n", // Relative positioning
  "M82 \n", // Absolute Extrude Rate
  "M109 F S210 B220 \n", // E TEMP
  "M155 S4 \n", 
  //"M190 S60 \n", // B TEMP
  "M104 F S210 B220 \n"
};
///////////////////////
String[] point = {
  "G0 F3000 E30.0 \n", 
  "G0 F3000 X"+ 150 + " Y" + 150 + " Z"+ initZ +" \n", 
  "G0 F3000 E30.0 \n", 

};

//            PIXEL BLANC
ControlP5 cp5;
Agent agent;
PVector[] noise2D;

float accelerationLevel = 0.05;
float turbulenceLevel = 0.01;
float hesitationLevel = 0.02;

//

void setup() {

  size(100, 100);

  background(0);
  printArray(Serial.list());
  frameRate = frame;
  myPort = new Serial(this, Serial.list()[1], 250000);
  output = createWriter("output.gcode");
  startCode = loadStrings("startCode.gcode");
  myPort.clear();
  output = createWriter("output.gcode");
  /*
  for (int i=0; i< startCode.length; i++) {
   output.println(startCode[i]);
   myPort.write(startCode[i]);
   }
   */

  //      PIXEL BLANC SETUP()

  agent = new Agent(width/2, height/2);
  noiseDetail(10);
  noise2D = new PVector[(width+1)*(height+1)];
  float xoff = 0, yoff = 0;
  for (int y = 0; y <= height; y ++) {
    xoff = 0;
    for (int x = 0; x <= width; x ++) {   
      float noiseAngle = map(noise(xoff, yoff), 0, 1, -TWO_PI, TWO_PI);
      PVector externalForce = new PVector(cos(noiseAngle), sin(noiseAngle));
      externalForce.setMag(1);
      noise2D[y*width+x] = externalForce;
      xoff +=0.005;
    }
    yoff +=0.005;
  }
  /*
  cp5 = new ControlP5(this);
   cp5.addSlider("accelerationLevel")
   .setPosition(width*0.1, height*0.02)
   .setRange(0.00, 0.2)
   .setValue(accelerationLevel);
   ;
   cp5.addSlider("turbulenceLevel")
   .setPosition(width*0.1, height*0.04)
   .setRange(0, 0.5)
   .setValue(turbulenceLevel)
   ;
   cp5.addSlider("hesitationLevel")
   .setPosition(width*0.1, height*0.06)
   .setRange(0.002, 0.05)
   .setValue(hesitationLevel)
   ;
   */
  //
}

void draw() {



  //

  String GCodeLine;
  //gCodeLine = "G1 F1000 X" + x1 + " Y" + y1 + " Z" + currentZ + " E" + extrusion;


  if (available) {
  }
  if (firstContact) {
    println("sending..." + " " + frameCount);
    myPort.write("A");
    myPort.clear();
  }

  if (available == true & !firstContact) {
    GCodeLine = "";
    if (drawing) {
      switch(drawingStages) {

      case 0 :
        initialize();
        initStage +=1;
        available = false;
        break;

      case 1 :
        moving();
        available = false;
        break;
      case 2 :
        sendTemp();
        available = false;
        break;
      case 3 :
        sendCoordinates();
        available = false;
        break;
      case 4 :
        upZ();
        available = false;
        break;
      default :
        break;
      }
    }
  }
}

void initialize() {
  String GCodeLine = "";
  println("Entering the initialization");
  GCodeLine = initString[initStage];
  println(GCodeLine);
  myPort.write(GCodeLine);
  myPort.clear();
  if (initStage == initString.length - 1) {
    initialization = false;
    drawingStages = 1;
  }
}

void moving() {
  String GCodeLine = "";
  //        PIXEL BLANC SHOW
  background(0);
  agent.update();
  float x1 = agent.position.x;
  float y1 = agent.position.y;
  nextPosition = new PVector(x1, y1);

  float distance = nextPosition.dist(oldPosition);
  distance = round(distance);
  println("old : " + oldPosition.x + " " + oldPosition.y);
  println("next : " + nextPosition.x + " " + nextPosition.y);
  //println("distance : " + distance);
  
  fill(255);
  ellipse(x1, y1, 10, 10);
  println("moving "+ frameCount);
  float dx = nextPosition.x - oldPosition.x;
  float dy = nextPosition.y - oldPosition.y;
  
  float extRate = 0.2;
  print("dx : " + dx);
  println("dy : " + dy);
  
  float xmin = 25, xmax=75, ymin = 25, ymax=75;
  boolean interx = oldPosition.x < xmax && oldPosition.x > xmin;
  boolean intery = oldPosition.y < ymax && oldPosition.y > ymin;
  if(interx && intery) {
    extRate = 0.0;
  }
  
  GCodeLine = "G0 F500 X"+ dx +" Y"+ dy +" Z0.00"+" E"+ extRate +" \n";
  myPort.write(GCodeLine);
  myPort.clear();
  oldPosition.x =  nextPosition.x;
  oldPosition.y = nextPosition.y;
  memoire.addValue(1,oldPosition);
  //memoire.printTab();
  println("drawing stage : " + drawingStages);
  /*
  if (frameCount % 100*frameRate == 0) {
    drawingStages = 4;
  }
  */
}

void sendTemp() {
  String GCodeLine = "";
  GCodeLine = "M105 \n";
  myPort.write(GCodeLine);
  myPort.clear();
  drawingStages = 1;
}

void sendCoordinates() {
  String GCodeLine = "";
  GCodeLine = "M114 \n";
  myPort.write(GCodeLine);
  myPort.clear();
  drawingStages = 1;
}

void upZ() {
  String GCodeLine = "";
  GCodeLine = "G0 F100 Z" +zInc+" \n";
  myPort.write(GCodeLine);
  myPort.clear();
  drawingStages = 1;
}
void keyPressed() {
  if (key == 's' || key == 'S') {
    stop = true;
  }
  if (key == 't' || key == 'T') {
    drawingStages = 2;
  }
}

void serialEvent(Serial myPort) {
  received = myPort.readStringUntil('\n');
  //received = "ok\r\n";

  if (received != null) {
    print(received);
    if (received.contains("ok")) {
      println("contacted !");
      if (firstContact) {
        initialization = true;
        firstContact = false;
      }
      available = true;
    }
  }
}