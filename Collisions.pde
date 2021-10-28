// This file contains the static Collisions class, which contains functions for testing collisions between various basic shapes.

public static class Collisions { 
  // Check if a rectangle is touching another rectangle
  public static boolean RectRectCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    return (x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2); // Using the AABB (Axis-Aligned Bounding Box) algorithm to check for collision between 2 rectangles
  }
  // Check if a rectangle is touching a circle
  public static boolean RectCircleCollision(float x1, float y1, float w, float h, float x2, float y2, float r) { // Check if the rectangle is colliding with the circle
    float testX = x2, testY = y2; // I don't know the name for this algorithm but I like it and it's efficient
    if (x2 < x1) {
      testX = x1;
    } else if (x2 > x1 + w) {
      testX = x1 + w;
    }
    if (y2 < y1) {
      testY = y1;
    } else if (y2  > y1 + h) {
      testY = y1 + h;
    }
    float distanceX = x2 - testX;
    float distanceY = y2 - testY;
    float distanceSqr = (distanceX*distanceX) + (distanceY*distanceY);
    return distanceSqr <= r * r;
  }
  // Check if a rectangle is touching a point
  public static boolean RectPointCollision(float x1, float y1, float w, float h, float x2, float y2) {
    return (x2 >= x1 && // This algorithm is pretty simple
      x2 <= x1 + w &&
      y2 >= y1 &&
      y2 <= y1 + h);
  }
  // Check if a circle is touching another circle
  public static boolean CircleCircleCollision(float x1, float y1, float r1, float x2, float y2, float r2) {
    float distanceSqr = abs((x2-x1)+(y2-y1)); // This algorithm just checks if the distance between the circles is less than their radiuses added
    return distanceSqr <= (r1+r2)*(r1+r2);
  }
  // Check if a circle is touching a point
  public static boolean CirclePointCollision(float x1, float y1, float r1, float x2, float y2) {
    float distanceSqr = abs((x2-x1)+(y2-y1)); // This algorithm checks if the point's distance to the circle is less than the radius
    return distanceSqr <= r1*r1;
  }
}
