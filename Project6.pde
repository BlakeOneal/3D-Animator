// VertexAnimation Project - Student Version
import java.io.*;
import java.util.*;

/*========== Monsters ==========*/
Animation monsterAnim;
ShapeInterpolator monsterForward = new ShapeInterpolator();
ShapeInterpolator monsterReverse = new ShapeInterpolator();
ShapeInterpolator monsterSnap = new ShapeInterpolator();

/*========== Sphere ==========*/
Animation sphereAnim; // Load from file
Animation spherePos; // Create manually
ShapeInterpolator sphereForward = new ShapeInterpolator();
PositionInterpolator spherePosition = new PositionInterpolator();

// TODO: Create animations for interpolators
ArrayList<PositionInterpolator> cubes = new ArrayList<PositionInterpolator>();

float eyeY = 0;
float eyeZ = 0;
float camX = 0;
float camY = 0;
float camZ = 0;
float pMouseXPos;
float pMouseYPos;
float mouseXPos;
float mouseYPos;

class sphereCam {
  float eyeX = 10;
  float derX = eyeX * cos(radians(0.15)) * sin(radians(0.15));
  float derY = eyeX * cos(radians(0.15));
  float derZ = eyeX * sin(radians(0.15)) * sin(radians(0.15));
  float phi = 0;
  float theta = 0;

  void Update() {
    mouseXPos = mouseX;
    mouseYPos = mouseY;
    float deltaX = (mouseXPos - pMouseXPos) * 0.15f;
    float deltaY = (mouseYPos - pMouseYPos) * 0.15f;
    // Derived values when converting to spherical coords
    // radius = distance, mapped by zoom function
    float radius = eyeX;
    phi += deltaX;
    if (phi > 360) {
      phi = 360;
    }
    if (phi < 0) {
      phi = 0;
    }
    theta += deltaY;
    if (theta > 179) {
      theta = 179;
    }
    if (theta < 1) {
      theta = 1;
    }
    derX = radius * cos(radians(phi)) * sin(radians(theta));
    derY = radius * cos(radians(theta));
    derZ = radius * sin(radians(theta)) * sin(radians(phi));
    // Modify cam every frame (when this is called in draw()) 
    camera(derX, derY, derZ, 0, 0, 0, 0, 1, 0);
  }
  void zoom(float desiredZoom) {
    // Function that takes mouse scroll wheel input and modifies camera zoom
    desiredZoom *= 3;
    eyeX += desiredZoom;
    eyeY += desiredZoom;
    eyeZ += desiredZoom;
    // min value of radius
    if (eyeX < 10) {
      eyeX = 30;
      eyeY = 30;
      eyeZ = 30;
    }
    // max value of radius
    if (eyeX > 200) {
      eyeX = 200;
      eyeY = 200;
      eyeZ = 200;
    }
    float radius = eyeX;
    derX = radius * cos(radians(phi)) * sin(radians(theta));
    derY = radius * cos(radians(theta));
    derZ = radius * sin(radians(theta)) * sin(radians(phi));
    // Modify cam every frame (when this is called in draw()) 
    camera(derX, derY, derZ, 0, 0, 0, 0, 1, 0);
  }
}


void setup()
{
  size(1200, 800, P3D);

  /*====== Load Animations ======*/
  monsterAnim = ReadAnimationFromFile("monster.txt");
  sphereAnim = ReadAnimationFromFile("sphere.txt");

  monsterForward.SetAnimation(monsterAnim);
  monsterReverse.SetAnimation(monsterAnim);
  monsterSnap.SetAnimation(monsterAnim);  
  monsterSnap.SetFrameSnapping(true);

  /*====== Create Animations For Cubes ======*/
   //When initializing animations, to offset them
   //you can "initialize" them by calling Update()
   //with a time value update. Each is 0.1 seconds
   //ahead of the previous one
  for (int i = 0; i <= 10; i++) {
    PositionInterpolator cubeInterp = cubeAnimation();
    cubeInterp.Update(0.1 * i);
    cubes.add(cubeInterp);
  }

  /*====== Create Animations For Spheroid ======*/
  Animation spherePos = new Animation();
  spherePos = sphereAnimation();
  spherePosition.SetAnimation(spherePos);
  sphereForward.SetAnimation(sphereAnim);
   //Create and set keyframes


  width = 1200;
  height = 800;
  perspective(radians(90), width/(float)height, 0.1, 1000);
}

sphereCam mainCam = new sphereCam();



void draw()
{
  lights();
  background(0);
  camera(mainCam.derX, mainCam.derY, mainCam.derZ, 0, 0, 0, 0, 1, 0);
  perspective(radians(90), width/(float)height, 0.1, 1000);
  pMouseXPos = mouseX;
  pMouseYPos = mouseY;
  DrawGrid();

  float playbackSpeed = 0.005f;

  /*====== Draw Forward Monster ======*/
  pushMatrix();
  translate(-40, 0, 0);
  monsterForward.fillColor = color(128, 200, 54);
  monsterForward.Update(playbackSpeed);
  shape(monsterForward.currentShape);
  popMatrix();

  /////*====== Draw Reverse Monster ======*/
  pushMatrix();
  translate(40, 0, 0);
  monsterReverse.fillColor = color(220, 80, 45);
  monsterReverse.Update(-playbackSpeed);
  shape(monsterReverse.currentShape);
  popMatrix();

  /////*====== Draw Snapped Monster ======*/
  pushMatrix();
  translate(0, 0, -60);
  monsterSnap.fillColor = color(160, 120, 85);
  monsterSnap.Update(playbackSpeed);
  shape(monsterSnap.currentShape);
  popMatrix();

  ///*====== Draw Spheroid ======*/
  spherePosition.Update(playbackSpeed);
  sphereForward.fillColor = color(39, 110, 190);
  sphereForward.Update(playbackSpeed/2);
  PVector position = spherePosition.currentPosition;
  pushMatrix();
  translate(position.x, position.y, position.z);
  shape(sphereForward.currentShape);
  popMatrix();

  ///*====== TODO: Update and draw cubes ======*/
  //// For each interpolator, update/draw
  for (int i = 0; i < cubes.size(); i++) {
    PositionInterpolator curr = cubes.get(i);
    if (i == 0) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x - 100, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 1)
    {
      pushMatrix();
      curr.snapping = true;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x - 80, pos.y, pos.z);
      fill(255, 255, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 2) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x - 60, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 3) {
      pushMatrix();
      curr.snapping = true;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x - 40, pos.y, pos.z);
      fill(255, 255, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 4) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x - 20, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 5) {
      pushMatrix();
      curr.snapping = true;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x, pos.y, pos.z);
      fill(255, 255, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 6) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x + 20, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 7) {
      pushMatrix();
      curr.snapping = true;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x + 40, pos.y, pos.z);
      fill(255, 255, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 8) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x + 60, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 9) {
      pushMatrix();
      curr.snapping = true;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x + 80, pos.y, pos.z);
      fill(255, 255, 0);
      noStroke();
      box(10);
      popMatrix();
    } else if (i == 10) {
      pushMatrix();
      curr.snapping = false;
      curr.Update(playbackSpeed);
      PVector pos = curr.currentPosition;
      translate(pos.x + 100, pos.y, pos.z);
      fill(255, 0, 0);
      noStroke();
      box(10);
      popMatrix();
    }
  }
}



void mouseDragged() {
  // update cam pos. based on x y offset
  mainCam.Update();
  camera();
  perspective(); // Reset the projection matrix
}

void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  // Zoom the camera
  mainCam.zoom(e);
  // SomeCameraClass.zoom(e);
}

// Create and return an animation object
Animation ReadAnimationFromFile(String fileName)
{
  Animation animationToReturn = new Animation();
  String currLine;
  BufferedReader reader = createReader(fileName);
  String strArray[];
  ArrayList<PVector> framePoints;
  int numFrames = 0;
  int numDataPoints = 0;
  float currTime = 0;

  // The BufferedReader class will let you read in the file data
  try
  {
    currLine = reader.readLine();
  }
  catch (FileNotFoundException ex)
  {
    println("File not found: " + fileName);
    return null;
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
    return null;
  }
  numFrames = Integer.parseInt(currLine);
  try
  {
    currLine = reader.readLine();
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
    return null;
  }
  numDataPoints = Integer.parseInt(currLine);
  for (int i = 0; i < numFrames; i++) {
    KeyFrame newFrame = new KeyFrame();
    try
    {
      currLine = reader.readLine();
    }
    catch (IOException ex)
    {
      ex.printStackTrace();
      return null;
    }
    currTime = Float.parseFloat(currLine);
    newFrame.time = currTime;
    for (int j = 0; j < numDataPoints; j++) {
      try
      {
        currLine = reader.readLine();
      }
      catch (IOException ex)
      {
        ex.printStackTrace();
        return null;
      }
      strArray = currLine.split(" ");
      PVector point = new PVector();
      point.x = Float.parseFloat(strArray[0]);
      point.y = Float.parseFloat(strArray[1]);
      point.z = Float.parseFloat(strArray[2]);
      newFrame.points.add(point);
    }
    animationToReturn.keyFrames.add(newFrame);
  }

  return animationToReturn;
}

void DrawGrid()
{
  // TODO: Draw the grid
  // Dimensions: 200x200 (-100 to +100 on X and Z)
  for (int i = -10; i <= 10; i++) {
    strokeWeight(1);
    if (i == 0) {
      stroke(255, 0, 0);
      line(-100, 0, 0, 100, 0, 0);
    } else {
      stroke(255, 255, 255);
      line(-100, 0, i*10, 100, 0, i*10);
    }
  }
  for (int i = -10; i <= 10; i++) {
    if (i == 0) {
      stroke(0, 0, 255);
      line(0, 0, -100, 0, 0, 100);
    } else {
      stroke(255, 255, 255);
      line(i*10, 0, -100, i*10, 0, 100);
    }
  }
}

PositionInterpolator cubeAnimation() {
  Animation cubeAnim = new Animation();
  ArrayList<PVector> position = new ArrayList<PVector>();
  float x = 0;
  float y = 0;
  float z;
  for (int i = 1; i <= 4; i++) {
    KeyFrame frame = new KeyFrame();
    frame.time = 0.5 * i;
    if (i == 1 || i == 3) {
      z = 0;
      position.add(new PVector(x, y, z));
      frame.points = position;
      cubeAnim.keyFrames.add(frame);
    } else if (i == 2) {
      z = -100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      cubeAnim.keyFrames.add(frame);
    } else if (i == 4) {
      z = 100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      cubeAnim.keyFrames.add(frame);
    }
  }
  PositionInterpolator cubeInterpolator = new PositionInterpolator();
  cubeInterpolator.animation = cubeAnim;
  cubeInterpolator.currentTime = 0;
  return cubeInterpolator;
}

Animation sphereAnimation() {
  Animation sphereAnim = new Animation();
  float x;
  float y;
  float z;
  ArrayList<PVector> position = new ArrayList<PVector>();
  for(int i = 1; i <= 4; i++) {
    KeyFrame frame = new KeyFrame();
    frame.time = i;
    if(i == 1) {
      x = -100;
      y = 0;
      z = 100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      sphereAnim.keyFrames.add(frame);
    }
    else if(i == 2) {
      x = -100;
      y = 0;
      z = -100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      sphereAnim.keyFrames.add(frame);
      
    }
    else if(i == 3) {
      x = 100;
      y = 0;
      z = -100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      sphereAnim.keyFrames.add(frame);
      
    }
    else if(i == 4) {
      x = 100;
      y = 0;
      z = 100;
      position.add(new PVector(x, y, z));
      frame.points = position;
      sphereAnim.keyFrames.add(frame);
    }
  }
  
  return sphereAnim;
  
}
