/////////////////////////////////////////////////////////////////////////////////////
// Hi Mr Hollister.                                                                //
// I'm not using the naming conventions and you said that's ok. Thanks.            //
// Sorry for taking so long. Hopefully it was worth it                             //
// Also, the code contains spoilers for the end of the game. Proceed with caution. //
/////////////////////////////////////////////////////////////////////////////////////

// Also, when you resize the window, since you're obviously gonna want to see how epic it is that our UI scales depending on the window size, only drag the bottom right. The others don't really work for JFrame reasons or something.

// Declare all the global variables
PApplet applet; // We need this in case we ever have to refer to the base PApplet from a subclass. Usually, we could use "this" to get the PApplet, but we need a reference so that classes we've made work.
Map map;                   // This stores the map
AssetManager assetManager; // This stores the asset manager
Camera c;                  // Etc.
Time time;
UIManager ui;
SpaceProgram program;
TechManager techManager;
NotificationManager notificationManager;
Market market;
LeviathanSpawner leviathanSpawner;

ArrayList<SimpleDrone> drones;

ArrayList<Leviathan> leviathans;

boolean inMainMenu = true;
MainMenu mm;

boolean inVictoryScreen = false;
VictoryScreen vs = null;

boolean inCompanySelectScreen = false;
CompanySelectScreen css;

void setup() {
  size(1280,720); // 1280x720 is a nice size. It's 720p. It's also the width of the school monitors  .
  surface.setResizable(true); // Allow the user to resize the window so that if 1280x720 is too big or too small, they can change it.
  noSmooth(); // Our pixel art needs to look like pixel art, not a blurred mush of garbage. No smoothing please.
  
  applet = this; // Set up the reference to the PApplet for later
  
  // Oh boy. This line is fun. We need a reference to the native JFrame because processing doesn't support minimum sizes for windows (why?) nor does it provide a way to easily get the underlying JFrame (why again?)
  // So, we convert the PApplet's surface (PSurface) to a PSurfaceAWT.SmoothCanvas (IDK what that even is), then we convert it to a JFrame, then we set the minimum size
  // Also, all the java.awt stuff uses Dimensions instead of just 2 floats or ints, so we get to make one of those I guess.
  ((javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame()).setMinimumSize(new java.awt.Dimension(800,339)); // 800x339 is just about the smallest size possible before the UI starts breaking
}

void initialSetup() {  
  // Initialize all the required stuff with values
  assetManager = new AssetManager();
  time = new Time();
  c = new Camera();
  map = new Map(50, 50); // 50x50 map is nice. I guess if we ever need to change it we can do it easily here
  drones = new ArrayList<SimpleDrone>();
  float startX = random(1000, 4000);
  float startY = random(1000, 4000);
  c.x = startX;
  c.y = startY;
  techManager = new TechManager();
  notificationManager = new NotificationManager();
  ui = new UIManager();
  drones.add(new ConstructorDrone(startX + 50f,startY + 50f,100f,100f));
  drones.add(new ScienceDrone(startX + 150f,startY + 50f,100f,100f));
  drones.add(new ColonyDrone(startX + 250f,startY + 50f,100f,100f));
  market = new Market();
  leviathans = new ArrayList<Leviathan>();
  leviathanSpawner = new LeviathanSpawner();
}

void draw() {
  if(inVictoryScreen) {
    vs.update();
    vs.draw();
    frameCount = 0;
    Input.UpdateInput();
    return;
  }
  if(inCompanySelectScreen) {
    if(css == null) {
      css = new CompanySelectScreen();
    }
    css.update();
    css.draw();
    frameCount = 0;
    Input.UpdateInput();
    return;
  }
  if(inMainMenu) {
    if(mm == null) {
      mm = new MainMenu();
    }
    mm.update();
    mm.draw();
    frameCount = 0;
    Input.UpdateInput();
    return;
  }
  // This section is layed out like this so that the loading screen shows up. Usually, the screen will be black or not be there at all until it has loaded properly. 
  // By doing it like this, the first frame shows up quickly and before any of the time-consuming things start, like loading the images and initializing everything.
  // There is no frameCount 0 so we do the loading screen on 1, set up the game on 2, and then render normally after 2.
  if(frameCount == 1) {
    pushStyle();
    stroke(0);
    rect(0,0,width,height);
    textAlign(CENTER,CENTER);
    fill(0);
    text("Loading...", width/2,height/2);
    popStyle();
    return;
  }
  // initialSetup has to be on a different frame than the loading screen since stuff only gets drawn to the screen after everything in draw has happened.
  if(frameCount == 2) {
    initialSetup();
    return;
  }
  background(#151429); // This background colour is nice.
  
  if(selectedDrone != null && !drones.contains(selectedDrone)) {
    selectedDrone = null;
  }
  if(selectedColony != null && selectedColony.myTile.building != selectedColony) {
    selectedColony = null;
  }
  
  time.update(); // NEEDS to be first so that later update()s can use time.tickThisFrame
  
  // Update everything we have.
  ui.update();
  c.update();
  map.update();
  program.update();
  SimpleDrone[] tempDrones = drones.toArray(new SimpleDrone[drones.size()]);
  for(Drone d : tempDrones) {
    d.update();
  }
  
  Leviathan[] tempLeviathans = leviathans.toArray(new Leviathan[leviathans.size()]);
  for(Leviathan l : tempLeviathans) {
    l.update();
  }
  
  leviathanSpawner.update();
  
  c.beginTransformation(); // Tell the camera that it's time to do all its translations because we're drawing stuff in world space
  
  map.draw(); // Map calls draw on all the tiles and buildings so we don't need to do it here.
  
  tempDrones = drones.toArray(new SimpleDrone[drones.size()]);
  for(Drone d : tempDrones) {
    d.draw();
  }
  
  tempLeviathans = leviathans.toArray(new Leviathan[leviathans.size()]);
  for(Leviathan l : tempLeviathans) {
    l.draw();
  }
  
  c.endTransformation(); // We're drawing UI now. We're gonna do that in screen space. Let's tell the camera it doesn't need to translate all our stuff to world space anymore.
  
  ui.draw();
  
  Input.UpdateInput(); // Needs to go last so that the input updates after everything is done. Doing it at the start of draw doesn't work. I don't know why. It's probably fine. 
}
