// This is the static Input class. It can be accessed from anywhere and allows you easy access to functions to read the keys currently being pressed, among other things.
// The Input class gets around a common problem in Processing where you can only hold 1 key at a time. This class also keeps track of the keys last frame so you can
// tell if a key was only just pressed or released this frame. The same can be done with the mouse buttons.
public static class Input {
  // These arrays contain the keys pressed this frame and last frame
  static boolean[] currentKeys = new boolean[530];
  static boolean[] previousKeys = new boolean[530];

  // These ones are for the mose buttons
  static boolean[] currentMouseButtons = new boolean[40]; // 40 mouse buttons seems like more than enough mouse buttons. I've seen mice with tons of buttons. They're pretty cool but I have no idea what you would use around 35 of them for.
  static boolean[] previousMouseButtons = new boolean[40];
  
  // When we click a button, we "intercept" the mouse click, meaning that theoretically no game objects will respond to the click. There is no proper stack for mouse and keyboard events like in javascript, but we can pretend
  public static boolean hasInputBeenIntercepted = false;
  public static boolean hasScrollWheelBeenIntercepted = false;
  
  static int mouseWheel = 0;
  static boolean mouseWheelChangedThisFrame = false;

  Input() {
    java.util.Arrays.fill(currentKeys, false); // Set all the arrays to completely false
    java.util.Arrays.fill(previousKeys, false);
    java.util.Arrays.fill(currentMouseButtons, false);
    java.util.Arrays.fill(previousMouseButtons, false);
  }

  // keycodes can be found at https://keycode.info/. If you'd rather, you can do java.awt.event.KeyEvent.VK_whatever : https://docs.oracle.com/javase/6/docs/api/java/awt/event/KeyEvent.html )

  // Stuff nobody should use except the game manager
  public static void UpdateInput() {     // This clones the current keys to the previous keys. This should be called right before draw() ends in the main file.
    previousKeys = currentKeys.clone();  // This is important since we need to know the keys we pressed last frame
    previousMouseButtons = currentMouseButtons.clone();   // It's probably not very efficient but I don't care
    mouseWheelChangedThisFrame = false;
    hasScrollWheelBeenIntercepted = false;
    hasInputBeenIntercepted = false;
  }
  
  public static void Reset() {
    java.util.Arrays.fill(currentKeys, false); // Set all the arrays to completely false
    java.util.Arrays.fill(previousKeys, false);
    java.util.Arrays.fill(currentMouseButtons, false);
    java.util.Arrays.fill(previousMouseButtons, false);
  }

  public static void MouseButtonPressed(int button) {
    if (button == 37) { // Left mouse button should be 0 but it's 37 for some reason
      button = 0;
    }
    if (button == 39) { // Right mouse button should be 1 but it's 39 for some reason
      button = 1;
    }
    currentMouseButtons[button] = true;
  }

  public static void MouseButtonReleased(int button) {
    if (button == 37) { // same thing but with released
      button = 0;
    }
    if (button == 39) {
      button = 1;
    }
    currentMouseButtons[button] = false;
  }

  public static void MouseWheelSpun(int mouseWheelValue) {
    mouseWheelChangedThisFrame = true;
    mouseWheel = mouseWheelValue;
  }

  public static void KeyPressed(int keycode) {
    currentKeys[keycode] = true;
  }

  public static void KeyReleased(int keycode) {
    currentKeys[keycode] = false;
  }
  

  //Stuff anyone can use for input
  
  public static boolean GetKey(int keycode) {
    if(hasInputBeenIntercepted) {
      return false;
    }
    return currentKeys[keycode];
  }

  public static boolean GetKeyDown(int keycode) {
    return currentKeys[keycode] && !previousKeys[keycode];
  }

  public static boolean GetKeyUp(int keycode) {
    return !currentKeys[keycode] && previousKeys[keycode];
  }

  public static boolean GetMouseButton(int button) {
    return currentMouseButtons[button];
  }

  public static boolean GetMouseButtonDown(int button) {
    return currentMouseButtons[button] && !previousMouseButtons[button];
  }

  public static boolean GetMouseButtonUp(int button) {
    return !currentMouseButtons[button] && previousMouseButtons[button];
  }
  
  public static int GetMouseWheelChange() {
    if(mouseWheelChangedThisFrame == false) {
      return 0;
    }
    return mouseWheel;
  }
}

void mousePressed() {
  Input.MouseButtonPressed(mouseButton);
}

void mouseReleased() {
  Input.MouseButtonReleased(mouseButton);
}

void keyPressed() {
  if (key == ESC) {
    key = 0;
    Input.KeyPressed(ESC);
  } else {
    Input.KeyPressed(keyCode);
  }
}

void keyReleased() {
  Input.KeyReleased(keyCode);
}

void mouseWheel(MouseEvent e) {
  Input.MouseWheelSpun(e.getCount());
}
