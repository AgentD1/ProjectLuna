// I didn't make this, just edited it a bit.
// Credit: Alex Poupakis, https://github.com/AlexPoupakis/mouse2DTransformations/blob/master/Mouse2DTransformations/src/template/library/MouseTransformed.java
// This is a very nice little piece of code. Processing doesn't natively include a way to transform a given point through the transformation matrix. This file 
// simulates the transformation matrix with complicated matrix maths or something. It allows us to do things like figure out where our mouse is in the game world.
// Thanks Alex Poupakis

// I edited the mouse mouseX and mouseY algorithms to use floats instead of ints for accuracy. ints suck. >:(

/**
 * This is a processing library used to transform the mouse matrix
 * and get the transformed mouse coordinates.
 * <p>
 * Note: for multiple sketch windows, multiple instances of the MouseTransformed class must be created.
 */

// It's called MouseTransformed because it used to only be able to transform the mouse X and Y. That was modified.
public class MouseTransformed {
  PApplet parent;
  private ArrayDeque<MouseParameters> mouseStack = new ArrayDeque<MouseParameters>();

  public MouseTransformed(PApplet parent) {
    this.parent = parent;
    mouseStack.addLast(new MouseParameters());

    parent.registerMethod("post", this);
  }

  public void post() {
    this.resetMouse();
  }

  /**
   * Pushes current transformation matrix onto the animation and mouse stack.
   * 
   * @see <a href="https://processing.org/reference/pushMatrix_.html">Processing's pushMatrix()</a>
   */
  public void pushMatrix() {
    parent.pushMatrix();
    this.pushMatrixMouse();
  }

  /**
   * Pushes current transformation matrix onto the mouse stack ONLY.
   * <p>
   * Author's Notice: Do not use this function alone. Changing only the mouse stack can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   */
  public void pushMatrixMouse() {
    mouseStack.addLast(new MouseParameters(mouseStack.getLast().totalOffsetX, mouseStack.getLast().totalOffsetY, mouseStack.getLast().totalRotate, mouseStack.getLast().totalScaleX, mouseStack.getLast().totalScaleY));
  }

  /**
   * Pops current transformation matrix off the animation and mouse stack.
   * 
   * @see <a href="https://processing.org/reference/popMatrix_.html">Processing's popMatrix()</a>
   */
  public void popMatrix() {
    if (mouseStack.size() > 1) {
      parent.popMatrix();
      this.popMatrixMouse();
    }
  }

  /**
   * Pops current transformation matrix off the mouse stack ONLY.
   * <p>
   * Author's Notice: Do not use this function alone. Changing only the mouse stack can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   */
  public void popMatrixMouse() {
    if (mouseStack.size() > 1) {
      mouseStack.removeLast();
    }
  }


  /**
   * Translate current animation and mouse matrices.
   * d
   * @param offsetX  Offset matrix origin to the left/right
   * @param offsetY  Offset matrix origin up/down
   * 
   * @see <a href="https://processing.org/reference/translate_.html">Processing's translate()</a>
   */
  public void translate(float offsetX, float offsetY) {
    parent.translate(offsetX, offsetY);
    this.translateMouse(offsetX, offsetY);
  }

  /**
   * Translate current mouse matrix ONLY.
   * <p>
   * Author's Notice: Do not use this function alone. Translating only the mouse matrix can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   * 
   * @param offsetX  Offset matrix origin to the left/right
   * @param offsetY  Offset matrix origin up/down
   */
  public void translateMouse(float offsetX, float offsetY) {
    mouseStack.getLast().totalOffsetX += cos((float)mouseStack.getLast().totalRotate)*(mouseStack.getLast().totalScaleX)*offsetX - sin((float)mouseStack.getLast().totalRotate)*(mouseStack.getLast().totalScaleY)*offsetY;
    mouseStack.getLast().totalOffsetY += cos((float)mouseStack.getLast().totalRotate)*(mouseStack.getLast().totalScaleX)*offsetY + sin((float)mouseStack.getLast().totalRotate)*(mouseStack.getLast().totalScaleY)*offsetX;
  }

  /**
   * Scale current animation and mouse matrices.
   * 
   * @param scale  Percentage to scale the transformation matrices
   * 
   * @see <a href="https://processing.org/reference/scale_.html">Processing's scale()</a>
   */
  public void scale(float scale) {
    parent.scale(scale);
    this.scaleMouse(scale);
  }

  /**
   * Scale current mouse matrix ONLY.
   * <p>
   * Author's Notice: Do not use this function alone. Scaling only the mouse matrix can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   * 
   * @param scale  Percentage to scale the mouse transformation matrix
   */
  public void scaleMouse(float scale) {
    mouseStack.getLast().totalScaleX *= scale;
    mouseStack.getLast().totalScaleY *= scale;
  }

  /**
   * Scale current animation and mouse matrices.
   * 
   * @param scaleX  Percentage to scale the transformation matrices in the X-axis
   * @param scaleY  Percentage to scale the transformation matrices in the Y-axis
   * 
   * @see <a href="https://processing.org/reference/scale_.html">Processing's scale()</a>
   */
  public void scale(float scaleX, float scaleY) {
    parent.scale(scaleX, scaleY);
    this.scaleMouse(scaleX, scaleY);
  }

  /**
   * Scale current mouse matrix ONLY.
   * <p>
   * Author's Notice: Do not use this function alone. Scaling only the mouse matrix can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   * 
   * @param scaleX  Percentage to scale the mouse transformation matrix in the X-axis
   * @param scaleY  Percentage to scale the mouse transformation matrix in the Y-axis
   */
  public void scaleMouse(float scaleX, float scaleY) {
    mouseStack.getLast().totalScaleX *= scaleX;
    mouseStack.getLast().totalScaleY *= scaleY;
  }

  /**
   * Rotate current animation and mouse matrices.
   * 
   * @param angle  Angle of rotation (in rad)
   * 
   * @see <a href="https://processing.org/reference/rotate_.html">Processing's rotate()</a>
   */
  public void rotate(double angle) {
    parent.rotate((float)angle);
    this.rotateMouse(angle);
  }

  /**
   * Rotate current animation and mouse matrices.
   * <p>
   * Author's Notice: Do not use this function alone. Rotating only the mouse matrix can, and in most cases will, present problems.
   *           This function is included for completeness purposes.
   * 
   * @param angle  Angle of rotation (in rad)
   */
  public void rotateMouse(double angle) {
    mouseStack.getLast().totalRotate += angle;
  }

  private void resetMouse() {
    mouseStack.getLast().reset();
  }

  /**
   * Calculates the mouse X-coordinate in current matrix (transformed or not).
   * <p>Extension of mouseX keyword.
   * 
   * @return Transformed cursor's X-coordinate
   * 
   * @see <a href="https://processing.org/reference/mouseX.html">Processing's mouseX</a>
   */

  // I changed this function a bit.

  public float mouseX() {
    return screenPointToWorldPointX(parent.mouseX, parent.mouseY);
  }

  /**
   * Calculates the mouse Y-coordinate in current matrix (transformed or not).
   * <p>
   * Extension of mouseY keyword.
   * 
   * @return Transformed cursor's Y-coordinate
   * 
   * @see <a href="https://processing.org/reference/mouseY.html">Processing's mouseY</a>
   */

  // I changed this function a bit too.
  public float mouseY() {
    return screenPointToWorldPointY(parent.mouseX, parent.mouseY);
  }

  // I (Jacob) made this function (The matrix math and stuff came from up above somewhere)
  public float screenPointToWorldPointX(float x, float y) {
    return cos((float)mouseStack.getLast().totalRotate)*(1/mouseStack.getLast().totalScaleX)*(x - mouseStack.getLast().totalOffsetX) + sin((float)mouseStack.getLast().totalRotate)*(1/mouseStack.getLast().totalScaleY)*(y - mouseStack.getLast().totalOffsetY);
  }

  // this one too
  public float screenPointToWorldPointY(float x, float y) {
    return cos((float)mouseStack.getLast().totalRotate)*(1/mouseStack.getLast().totalScaleY)*(y - mouseStack.getLast().totalOffsetY) - sin((float)mouseStack.getLast().totalRotate)*(1/mouseStack.getLast().totalScaleX)*(x - mouseStack.getLast().totalOffsetX);
  }
}


class MouseParameters {
  final float initialOffsetX, initialOffsetY, initialScaleX, initialScaleY;
  final double initialRotate;
  public float totalOffsetX, totalOffsetY, totalScaleX, totalScaleY;
  public double totalRotate;

  MouseParameters(float initialOffsetX, float initialOffsetY, double initialRotate, float initialScaleX, float initialScaleY) {
    this.initialOffsetX = initialOffsetX;
    this.initialOffsetY = initialOffsetY;
    this.initialRotate = initialRotate;
    this.initialScaleX = initialScaleX;
    this.initialScaleY = initialScaleY;
    reset();
  }

  MouseParameters() {
    initialOffsetX = 0;
    initialOffsetY = 0;
    initialRotate = 0;
    initialScaleX = 1;
    initialScaleY = 1;
  }

  public void reset() {
    totalOffsetX = initialOffsetX;
    totalOffsetY = initialOffsetY;
    totalRotate = initialRotate;
    totalScaleX = initialScaleX;
    totalScaleY = initialScaleY;
  }
}
