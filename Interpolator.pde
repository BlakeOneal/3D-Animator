abstract class Interpolator
{
  Animation animation;

  // Where we at in the animation?
  float currentTime = 0;

  // To interpolate, or not to interpolate... that is the question
  boolean snapping = false;

  void SetAnimation(Animation anim)
  {
    animation = anim;
  }

  void SetFrameSnapping(boolean snap)
  {
    snapping = snap;
  }

  void UpdateTime(float time)
  {
    // TODO: Update the current time
    currentTime += time;
    
    // Check to see if the time is out of bounds (0 / Animation_Duration)
    if (currentTime > animation.GetDuration()) {
      currentTime -= animation.GetDuration();
    }
    else if(currentTime <= 0) {
      currentTime += animation.GetDuration();
    }

    // If so, adjust by an appropriate amount to loop correctly
  }

  // Implement this in derived classes
  // Each of those should call UpdateTime() and pass the time parameter
  // Call that function FIRST to ensure proper synching of animations
  abstract void Update(float time);
}

class ShapeInterpolator extends Interpolator
{
  // The result of the data calculations - either snapping or interpolating
  PShape currentShape;

  // Changing mesh colors
  color fillColor;

  PShape GetShape()
  {
    return currentShape;
  }

  void Update(float time)
  {
    UpdateTime(time);
    currentShape = createShape();
    currentShape.beginShape(TRIANGLE);
    currentShape.noStroke();
    ArrayList<KeyFrame> keyFrames = animation.keyFrames;
    KeyFrame currentKeyFrame;
    if (snapping && currentTime <= animation.keyFrames.get(0).time) {
      currentKeyFrame = animation.keyFrames.get(keyFrames.size() - 1);
      for (int i = 0; i < currentKeyFrame.points.size(); i++)
      {
        currentShape.fill(fillColor);
        currentShape.vertex(currentKeyFrame.points.get(i).x, currentKeyFrame.points.get(i).y, currentKeyFrame.points.get(i).z);
      }
      currentShape.endShape();
    } else if (snapping) {
      currentKeyFrame = keyFrames.get(0);
      int index = 0;
      for (int i = 0; i < keyFrames.size(); i++) {
        KeyFrame curr = keyFrames.get(i);
        float diff1 = currentTime - curr.time;
        if (diff1 >= 0) {
          currentKeyFrame = curr;
          index = i;
        }
      }
      currentKeyFrame = keyFrames.get(index);
      for (int i = 0; i < currentKeyFrame.points.size(); i++)
      {
        currentShape.fill(fillColor);
        currentShape.vertex(currentKeyFrame.points.get(i).x, currentKeyFrame.points.get(i).y, currentKeyFrame.points.get(i).z);
      }
      currentShape.endShape();
    } else if (!snapping) {
      float difference = 999;
      float difference2 = 999;
      int lower = 0;
      int upper = 0;
      if (currentTime <= keyFrames.get(0).time) {
        KeyFrame next = keyFrames.get(0);
        KeyFrame prev = keyFrames.get(keyFrames.size() - 1);
        float ratio = currentTime / keyFrames.get(0).time;
        for (int i = 0; i < next.points.size(); i++) {
          currentShape.fill(fillColor);
          float xVal = (prev.points.get(i).x) + ((next.points.get(i).x - prev.points.get(i).x) * ratio);
          float yVal = (prev.points.get(i).y) + ((next.points.get(i).y - prev.points.get(i).y) * ratio);
          float zVal = (prev.points.get(i).z) + ((next.points.get(i).z - prev.points.get(i).z) * ratio);
          currentShape.vertex(xVal, yVal, zVal);
        }
        currentShape.endShape();
      } else {
        for (int i = 0; i < keyFrames.size(); i++) {
          KeyFrame curr = keyFrames.get(i);
          if (curr.time - currentTime < difference && curr.time - currentTime >= 0) {
            upper = i;
            difference = curr.time - currentTime;
          }
          if (currentTime - curr.time < difference2 && currentTime - curr.time >= 0) {
            lower = i;
            difference2 = currentTime - curr.time;
          }
        }
        for (int i = 0; i < keyFrames.get(upper).points.size(); i++)
        {
          currentShape.fill(fillColor);
          float ratio = (currentTime - keyFrames.get(lower).time) / (keyFrames.get(upper).time - keyFrames.get(lower).time);
          float xVal = (keyFrames.get(lower).points.get(i).x) + ((keyFrames.get(upper).points.get(i).x - keyFrames.get(lower).points.get(i).x) * ratio);
          float yVal = (keyFrames.get(lower).points.get(i).y) + ((keyFrames.get(upper).points.get(i).y - keyFrames.get(lower).points.get(i).y) * ratio);
          float zVal = (keyFrames.get(lower).points.get(i).z) + ((keyFrames.get(upper).points.get(i).z - keyFrames.get(lower).points.get(i).z) * ratio);
          currentShape.vertex(xVal, yVal, zVal);
        }
        currentShape.endShape();
      }
    }
      
    }
    // TODO: Create a new PShape by interpolating between two existing key frames
    // using linear interpolation
  }



class PositionInterpolator extends Interpolator
{
  PVector currentPosition;

  void Update(float time)
  {
    UpdateTime(time);
    ArrayList<KeyFrame> keyFrames = animation.keyFrames;
    if (currentTime == 0 && !snapping) {
      currentPosition = keyFrames.get(0).points.get(0);
    }
    if (!snapping) {
      boolean set = false;
      float difference = 999;
      float difference2 = 999;
      int lower = 0;
      int upper = 0;
      if (currentTime < keyFrames.get(0).time) {
        KeyFrame next = keyFrames.get(0);
        PVector nextPos = next.points.get(0);
        KeyFrame prev = keyFrames.get(keyFrames.size() - 1);
        PVector prevPos = prev.points.get(keyFrames.size() - 1);
        float ratio = currentTime / keyFrames.get(0).time;
        float xVal = (prevPos.x) + ((nextPos.x - prevPos.x) * ratio);
        float yVal = (prevPos.y) + ((nextPos.y - prevPos.y) * ratio);
        float zVal = (prevPos.z) + ((nextPos.z - prevPos.z) * ratio);
        currentPosition = new PVector(xVal, yVal, zVal);
        set = true;
      } else {
        for (int i = 0; i < keyFrames.size(); i++) {
          KeyFrame curr = keyFrames.get(i);
          if (curr.time - currentTime < difference && curr.time - currentTime >= 0)
          {
            upper = i;
            difference = curr.time - currentTime;
          }
          if (currentTime - curr.time < difference2 && currentTime - curr.time >= 0) {
            lower = i;
            difference2 = currentTime - curr.time;
          }
        }
        if (!set) {
          float ratio = (currentTime - keyFrames.get(lower).time) / (keyFrames.get(upper).time - keyFrames.get(lower).time);
          PVector nextPos = keyFrames.get(upper).points.get(upper);
          PVector prevPos = keyFrames.get(lower).points.get(lower);


          float xVal = (prevPos.x) + ((nextPos.x - prevPos.x) * ratio);
          float yVal = (prevPos.y) + ((nextPos.y - prevPos.y) * ratio);
          float zVal = (prevPos.z) + ((nextPos.z - prevPos.z) * ratio);
          currentPosition = new PVector(xVal, yVal, zVal);
        }
      }
    } else if (snapping && currentTime <= keyFrames.get(0).time) {
      currentPosition = keyFrames.get(keyFrames.size() - 1).points.get(keyFrames.size() - 1);
    } else if (snapping) {
      KeyFrame currentFrame = keyFrames.get(0);
      int index = 0;
      for (int i = 0; i < keyFrames.size(); i++) {
        KeyFrame curr = keyFrames.get(i);
        float diff1 = currentTime - curr.time;
        if (diff1 >= 0) {
          currentFrame = curr;
          index = i;
        }
      }
      currentPosition = currentFrame.points.get(index);
    }
    // The same type of process as the ShapeInterpolator class... except
    // this only operates on a single point
  }
}
