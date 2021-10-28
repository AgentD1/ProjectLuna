// The Camera file contains the Camera class, a class that represents the "camera" in 2d, the position and scale of the world. It isn't actually a camera, but it looks like one and acts like one.

public class Camera {
  MouseTransformed mouse = new MouseTransformed(applet); // We use MouseTransformed a lot in the Camera class. More will be explained in the MouseTransformed file.
  boolean transformed = false;

  public Camera() {
  }
  
  public float getWindowWidth() { // These functions allow classes who already have a width and height variable to access the window's width and height. They could do applet.width but that's lame. The Camera is cool.
    return width;
  }
  
  public float getWindowHeight() {
    return height;
  }

  public float x = 0f, y = 0f, scale = 1f, moveSpeed = 4f, scrollSpeed = 5f, rotation = 0f, zoomIntensity = 0.2f;
  
  public float getLeftX() { // This function gets the x of the left side of the camera in world position.
    return screenPointToWorldPointX(0f,0f);
  }
  public float getRightX() { // This function gets the x of the right side of the camera in world position.
    return screenPointToWorldPointX(width,0f);
  }
  public float getTopY() { // This function gets the y of the top side of the camera in world position.
    return screenPointToWorldPointY(0f,0f);
  }
  public float getBottomY() { // This function gets the y of the bottom side of the camera in world position.
    return screenPointToWorldPointY(0f,height);
  }

  public void update() {
    // This code moves the camera based on the keys pressed. The 1/scale means that the camera will appear to go faster when zoomed out more. Without this, moving would be unbearable at most zoom levels.
    if (Input.GetKey(65) || Input.GetKey(37)) { // A or Left Arrow
      x -= moveSpeed * 1/scale;
    }
    if (Input.GetKey(68) || Input.GetKey(39)) { // D
      x += moveSpeed * 1/scale;
    }
    if (Input.GetKey(87) || Input.GetKey(38)) { // W
      y -= moveSpeed * 1/scale;
    }
    if (Input.GetKey(83) || Input.GetKey(40)) { // S
      y += moveSpeed * 1/scale;
    }
    
    if (!Input.hasScrollWheelBeenIntercepted && !ui.displayTechTree && Input.GetMouseWheelChange() != 0) {
      float wheel = Input.GetMouseWheelChange() < 0 ? 1 : -1;

      float zoom = exp(wheel * zoomIntensity); // The exp is so that the camera zooms less the more zoomed in it is. This makes zooming very nice-feeling.
      
      scale *= zoom;
    }
  }


  // These functions all refer to the MouseTransformed's functions for transforming the viewpoint. More is explained there.
  public void pushMatrix() {
    mouse.pushMatrix();
  }

  public void popMatrix() {
    mouse.popMatrix();
  }

  public void translate(float x, float y) {
    mouse.translate(x, y);
  }

  public void rotate(float angle) {
    mouse.rotate(angle);
  }

  public void scale(float n) {
    mouse.scale(n);
  }

  public void scale(float x, float y) {
    mouse.scale(x, y);
  }
  
  // This function gets the X location of a specified x and y on the screen in the world space. Kind of like a 2d raycast through the screen down to the world.
  public float screenPointToWorldPointX(float x, float y) {
    boolean transformedToday = false;
    if(!transformed) { // the mouse.screenPointToWorldPointX function requires all the translations to have been done for it to work properly, so, if we aren't transformed, transform.
      transformedToday = true;
      beginTransformation();
    }
    float returnValue = mouse.screenPointToWorldPointX(x,y);
    if(transformedToday) { // If we had to transform in this function, undo it.
      endTransformation();
    }
    return returnValue;
  }
  
  // Same as above but with Y
  public float screenPointToWorldPointY(float x, float y) {
    boolean transformedToday = false;
    if(!transformed) {
      transformedToday = true;
      beginTransformation();
    }
    float returnValue = mouse.screenPointToWorldPointY(x,y);
    if(transformedToday) {
      endTransformation();
    }
    return returnValue;
  }

  // This function begins the transformation, meaning that things drawn in world space are now drawn to the screen properly.
  // Without this, the tiles at the far right (x=5000 or so) would be drawn so far to the right it would never be seen.
  public void beginTransformation() {
    transformed = true;
    mouse.pushMatrix(); // Store our current transformation so we can revert when we don't want to be transformed anymore
    
    mouse.translate(width/2,height/2); // This part makes sure that the screen scales from the centre instead of the top left corner
    mouse.scale(scale);
    mouse.translate(-width/2,-height/2);
    
    mouse.translate(-x, -y); // Translate and rotate normally
    mouse.rotate(rotation);
  }

  public void endTransformation() {
    transformed = false;
    mouse.popMatrix(); // Undo our transformation
  }
}
