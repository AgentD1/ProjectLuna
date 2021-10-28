// This file contains the Drone class and all its children

import javax.swing.*; // This allows us to use the JOptionPane static methods for showing dialog boxes quickly and easily.

Drone selectedDrone; // This global-scope variable contains the drone that is currently selected (the one that's been clicked on).

float droneUpkeepModifier = 0;

// The abstract Drone class contains all the basic things a Drone needs.
public abstract class Drone {
  public float x, y, width, height;
  
  public float destructionPenalty = 10;
  
  public float upkeep = 0 + droneUpkeepModifier;
  
  public DroneAction[] droneActions; // Drone Actions are explained at the bottom where the DroneAction class is declared


  public abstract void update(); // Drones (unlike buildings) must have an update function. A drone with no update is a stupid drone. Noone likes stupid drones.
  public abstract void draw(); // Drones need to be drawn too.
}

public float globalDroneMovement = 1/3f;

// Honestly SimpleDrone could have been combined with drone for the same reason as Building's and SimpleBuilding's but it's ok
public class SimpleDrone extends Drone {
  public String imageAsset;
  public float destX, destY;
  public boolean canMove = true;
  PImage image;

  public SimpleDrone(String imageAsset, float x, float y, float width, float height) {
    this.imageAsset = imageAsset;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    destX = x;
    destY = y;
    droneActions = new DroneAction[] {  };
    println(program.creditsPerTurn);
  }
  
  public void stopMoving() {
    destX = x;
    destY = y;
  }

  public void update() { 
    upkeep = 1 + droneUpkeepModifier;
    // Input.hasInputBeenIntercepted is explained more in Input.
    if (Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted && Collisions.RectPointCollision(x, y, width, height, c.screenPointToWorldPointX(mouseX, mouseY), c.screenPointToWorldPointY(mouseX, mouseY))) {
      selectedDrone = this; // If we've been clicked, we are now the selected drone!
      ui.recalculateDroneValues(); // Since a new drone has been selected, we must tell the UI it needs to update its values with this drone instead of the old one
    }
    if (selectedDrone == this) {
      // If we click somewhere than on the drone, then this drone isn't selected anymore
      if (Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted && !Collisions.RectPointCollision(x, y, width, height, c.screenPointToWorldPointX(mouseX, mouseY), c.screenPointToWorldPointY(mouseX, mouseY))) {
        selectedDrone = null;
      }
      if (Input.GetMouseButtonDown(1) && !Input.hasInputBeenIntercepted) { // We can set our destination coordinates to the place we clicked, making sure we don't end up out of bounds
        destX = constrain(c.screenPointToWorldPointX(mouseX, mouseY) - width/2, -width*0.49, (map.getMapWidth() * map.getTileWidth()) - width*0.51);
        destY = constrain(c.screenPointToWorldPointY(mouseX, mouseY) - height/2, -width*1.49, (map.getMapHeight() * map.getTileHeight()) - height*1.51);
      }
    }

    if (canMove && (x != destX || y != destY)) { // If we can move and we aren't at our destination, let's get going before it gets late and dark.
      PVector direction = new PVector(destX - x, destY - y).setMag(globalDroneMovement * time.currentTimeSpeed); // Figure out which direction we need to go, then make sure the magnitude is our movement speed.
      x += direction.x;
      y += direction.y;
      if (abs(x - destX) < globalDroneMovement * time.currentTimeSpeed && abs(y - destY) < globalDroneMovement * time.currentTimeSpeed) { // If we're close enough we will get there next frame, we might as well teleport. If we don't we'll overshoot and become jittery.
        x = destX;
        y = destY;
        if(selectedDrone != this) {
          notificationManager.CreateDroneIdleNotifications(this); // We've stopped moving now. Let's tell the user that this drone can move again.
        }
      }
    }
    
    if(time.tickThisFrame) {
      program.credits -= upkeep;
    }
  }

  public void draw() {
    pushStyle();
    if (selectedDrone == this) {
      fill(255,0,0,32);
      noStroke();
      Tile t = map.WorldPointToTile(x+width/2,y+height/2);
      rect(t.x*map.getTileWidth(), (t.y-1)*map.getTileHeight(), map.getTileWidth(), map.getTileHeight()); // We draw a box on the tile we're on to indicate to the user where the drone is.
      strokeWeight(8);
      stroke(0);
      line(x+width/2, y+height/2, destX+width/2, destY+height/2); // We draw a line to the destination so users know where we're going.
      noStroke();
      fill(0,255,255, 64);
      ellipseMode(CORNER);
      ellipse(x, y, width, height); // And we draw a semi-transparent circle under the image to show we are selected.
    }
    image(image, x, y, width, height); // We draw the drone no matter whether we're selected or not.
    popStyle();
  }
}

public float globalConstructionSpeedModifier = 1f;
public boolean unlockedScienceOutposts = false;
public boolean unlockedAlloyFactories = false;
public boolean unlockedElectronicsFactories = false;
public boolean hydroponicsVersatile = false;

public class ConstructorDrone extends SimpleDrone {
  public float buildProgress = 0f; // This is how far away this drone is from finishing building whatever it's building
  
  public ConstructorDrone(float x, float y, float width, float height) {
    super("ConstructionDrone", x, y, width, height);
    
    destructionPenalty = 30;
    upkeep = 1 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    
    // Below this, we create all our DroneAction's. This is kind of boring and each one is basically the same, so I'll only comment this top one, unless there's something special.
    
    DroneAction constructMine = new DroneAction("MineBuilding"); // This DroneAction is dedicated to building a mine.
    constructMine.name = "Mine"; // Name it appropriately, this is the name that shows up on the UI when the drone is selected.
    
    // Here's where we could totally use a lambda statement. Unfortunately, processing doesn't support all the Java 8 features. That came out in 2014. Jeez. So, we don't get nice things. We can't use lambdas so this section has to be soooooooooooooooo long. 
    // Ugh
    // This is the delegate which handles what happens when the button is pressed. Unfortunately we can't just use the UI's OnPressed because we need to input a drone. Once again, no nice things for us.
    constructMine.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2); // Figure out what tile me need to build a mine on
      if(t.GetBuilding() != null) { // If there is already a building in the spot we want to build, let's make sure it's ok to replace it with a helpful friendly dialog box.
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop(); // Processing will continue to loop and call draw while the JOptionPane is open, so let's stop that for a bit.
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION); // This is a very convenient 1-liner for displaying a dialog box and pausing the game. Nice.
        loop(); // It's shown, so we can resume looping.
        if(result == 1) { // The JOptionPane.showConfirmDialog returns an int corresponding to the button we pressed. YES is 0 and NO is 1. If we pressed NO then we can just return.
          return;
        }
      }
      t.SetBuilding(new Mine(t));  // Build a mine on the tile
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier; // It's ok to assume all these types here. There's no chance of them being wrong, since Mine is always a SimpleBuilding and this function is only called on ConstructorDrones
      ((ConstructorDrone)drone).stopMoving(); // No more moving
      ((ConstructorDrone)drone).canMove = false; // Please
    } };
    
    // This is a delegate that returns if the button should not even be there (0), show up but be disabled and greyed out (1), or work properly (2)
    constructMine.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("MountainTile") || t.assetName.equals("HighlandsTile") || t.assetName.equals("MariaTile")) { // We check if the tile is a Mountain, Highlands, or Maria
        return 2; // You can build on those tiles so it's ok to build a mine here
      } else {
        return 1; // You can't build a mine here. Show it but grey it out please.
      }
    } };
    constructMine.myDrone = this;
    
    // Everything after this until the next comment is just the same as above but with different values.
    
    DroneAction constructHydroponics = new DroneAction("HydroponicsBuilding");
    constructHydroponics.name = "Hydroponics";
    constructHydroponics.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new Hydroponics(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructHydroponics.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("FlatTile") || t.assetName.equals("MariaTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructHydroponics.myDrone = this;
    
    DroneAction constructFactory = new DroneAction("FactoryBuilding");
    constructFactory.name = "Factory";
    constructFactory.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new Factory(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructFactory.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("FlatTile") || t.assetName.equals("MariaTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructFactory.myDrone = this;
    
    DroneAction constructAlloyFactory = new DroneAction("AlloyFactoryBuilding");
    constructAlloyFactory.name = "Alloy Factory";
    constructAlloyFactory.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new AlloyFactory(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructAlloyFactory.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(unlockedAlloyFactories == false) {
        return 0;
      } else if(t.assetName.equals("FlatTile") || t.assetName.equals("MariaTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructAlloyFactory.myDrone = this;
    
    DroneAction constructElectronicsFactory = new DroneAction("ElectronicsFactoryBuilding");
    constructElectronicsFactory.name = "Electronics Factory";
    constructElectronicsFactory.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new ElectronicsFactory(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructElectronicsFactory.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(unlockedElectronicsFactories == false) {
        return 0;
      } else if(t.assetName.equals("FlatTile") || t.assetName.equals("MariaTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructElectronicsFactory.myDrone = this;
    
    DroneAction constructWaterExtractor = new DroneAction("WaterExtractorBuilding");
    constructWaterExtractor.name = "Water Extractor";
    constructWaterExtractor.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new WaterExtractor(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructWaterExtractor.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("CraterTile") || t.assetName.equals("HeavyCraterTile") || t.assetName.equals("DugCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructWaterExtractor.myDrone = this;
    
    DroneAction constructScienceOutpost = new DroneAction("ScienceOutpostBuilding");
    constructScienceOutpost.name = "Science Outpost";
    constructScienceOutpost.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.SetBuilding(new ScienceOutpost(t)); 
      ((ConstructorDrone)drone).buildProgress = ((SimpleBuilding) t.GetBuilding()).timeToBuild / globalConstructionSpeedModifier;
      ((ConstructorDrone)drone).stopMoving();
      ((ConstructorDrone)drone).canMove = false;
    } };
    constructScienceOutpost.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(unlockedScienceOutposts == false) {
        return 0;
      } else 
      if(t.assetName.equals("FlatTile") || t.assetName.equals("MariaTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructScienceOutpost.myDrone = this;
    
    // Deconstruction is a bit different.
    DroneAction deconstruct = new DroneAction("DeconstructIcon");
    deconstruct.name = "Deconstruct / Cancel";
    deconstruct.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to deconstruct this?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      t.ClearBuilding(); // Just clear the building if the user is ok with it.
    } };
    deconstruct.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.GetBuilding() != null && !(t.GetBuilding() instanceof Anomaly)) {
        return 2;
      } else {
        return 0; // We don't want the button to even show if there isn't anything to deconstruct.
      }
    } };
    deconstruct.myDrone = this;
    
    // Put it all in our public droneActions array so the UI can use it
    droneActions = new DroneAction[] { constructMine, constructHydroponics, constructFactory, constructAlloyFactory, constructElectronicsFactory, constructWaterExtractor, constructScienceOutpost, deconstruct };
  }
  
  public void update() {
    upkeep = 1 + droneUpkeepModifier;
    super.update();
    buildProgress -= time.currentTimeSpeed;
    if(buildProgress <= 0 || map.WorldPointToTile(x+width/2,y+width/2).GetBuilding() == null) { // If we aren't building anything or whatever we've been building has been cancelled, we can move again.
      buildProgress = -1;
      canMove = true;
    }
  }
  
  public void draw() {
    super.draw();
    if(buildProgress >= 0) { // The drone has a red circle when it's constructing something.
      pushStyle();
      fill(255,0,0,64);
      noStroke();
      ellipseMode(CORNER);
      ellipse(x, y, width, height);
      popStyle();
    }
  }
}

public float colonyConstructionSpeed = 1f;

public float combatDroneUpkeepDiscount = 0f;

public class ColonyDrone extends SimpleDrone {
  public float buildProgress = Float.MAX_VALUE;
  
  public ColonyDrone(float x, float y, float width, float height) {
    super("ColonyDrone", x, y, width, height);
    
    destructionPenalty = 50;
    upkeep = 1 + droneUpkeepModifier - combatDroneUpkeepDiscount;
    program.creditsPerTurn -= upkeep;
    
    DroneAction constructColony = new DroneAction("ColonyBuilding");
    constructColony.name = "Build Colony";
    
    constructColony.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      Tile t = map.WorldPointToTile(drone.x+drone.width/2,drone.y+drone.width/2);
      if(t.GetBuilding() != null) {
        if(t.GetBuilding() instanceof Anomaly) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You can't replace anomalies. Research it with a Science Drone first.", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          return;
        }
        noLoop();
        Input.Reset();
        int result = JOptionPane.showConfirmDialog(null, "Are you sure you want to replace the current tile improvement?", "ProjectLuna", JOptionPane.YES_NO_OPTION);
        loop();
        if(result == 1) {
          return;
        }
      }
      if(!((ColonyDrone)drone).isThisAValidColonyLocation()) {
        noLoop();
        Input.Reset();
        JOptionPane.showMessageDialog(null, "You can't build colonies who's territories overlap!", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
        loop();
        return;
      }
      // Build a mine on the tile
      ((ColonyDrone)drone).built = false;
      ((ColonyDrone)drone).startedBuilding = true;
      ((ColonyDrone)drone).buildProgress = 3600f / colonyConstructionSpeed;
      ((ColonyDrone)drone).stopMoving();
      ((ColonyDrone)drone).canMove = false;
    } };
    
    constructColony.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(!t.assetName.equals("MountainTile") && !t.assetName.equals("HeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    constructColony.myDrone = this;
    
    droneActions = new DroneAction[] { constructColony };
    
  }
  
  boolean built = false;
  boolean startedBuilding = false;
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier - combatDroneUpkeepDiscount;
    buildProgress -= time.currentTimeSpeed;
    if(buildProgress <= 0 && built == false) {
      built = true;
      buildProgress = -1;
      canMove = true;
      Tile t = map.WorldPointToTile(x+width/2,y+width/2);
      t.SetBuilding(new Colony(t));
      drones.remove(this);
    }
  }
  
  public void draw() {
    super.draw();
    if(buildProgress >= 0 && startedBuilding) {
      pushStyle();
      fill(255,0,0,64);
      noStroke();
      ellipseMode(CORNER);
      ellipse(x, y, width, height);
      popStyle();
    }
  }
  
  boolean isThisAValidColonyLocation() {
    valid = true;
    drawTilesOut(map.WorldPointToTile(x+width/2,y+width/2).x, map.WorldPointToTile(x+width/2,y+width/2).y, 6);
    return valid;
  }
  boolean valid = true;
  public void drawTilesOut(int x, int y, int distance) {
    if(valid == false) {
      return;
    }
    Tile t = map.getTile(x, y);
    if (t.GetBuilding() instanceof Colony) {
      valid = false;
      return;
    }
    
    if (distance == 0) {
      return;
    }
    if (t.x > 0) {
      drawTilesOut(t.x - 1, t.y, distance - 1);
    }
    if (t.x + 1 < map.getMapWidth()) {
      drawTilesOut(t.x + 1, t.y, distance - 1);
    }
    if (t.y > 0) {
      drawTilesOut(t.x, t.y - 1, distance - 1);
    }
    if (t.y + 1 < map.getMapHeight()) {
      drawTilesOut(t.x, t.y + 1, distance - 1);
    }
  }  
}

public float fillerDroneSpeed = 1f;

public class FillerDrone extends SimpleDrone {
  public float buildProgress = Float.MAX_VALUE;
  public FillerDrone(float x, float y, float width, float height) {
    super("FillerDrone", x, y, width, height);
    
    upkeep = 1 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    destructionPenalty = 30;
    
    DroneAction fillCrater = new DroneAction("FilledCraterTile");
    fillCrater.name = "Fill Crater";
    
    fillCrater.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      // Build a mine on the tile
      ((FillerDrone)drone).built = false;
      ((FillerDrone)drone).startedBuilding = true;
      ((FillerDrone)drone).buildProgress = 1800f * fillerDroneSpeed;
      ((FillerDrone)drone).stopMoving();
      ((FillerDrone)drone).canMove = false;
    } };
    
    fillCrater.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("CraterTile") || t.assetName.equals("HeavyCraterTile") || t.assetName.equals("DugCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    fillCrater.myDrone = this;
      
    
    DroneAction digCrater = new DroneAction("DugCraterTile");
    digCrater.name = "Dig Crater";
    
    digCrater.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      // Build a mine on the tile
      ((FillerDrone)drone).built = false;
      ((FillerDrone)drone).startedBuilding = true;
      ((FillerDrone)drone).buildProgress = 2400f * fillerDroneSpeed;
      ((FillerDrone)drone).stopMoving();
      ((FillerDrone)drone).canMove = false;
    } };
    
    digCrater.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.assetName.equals("FlatTile") || t.assetName.equals("FilledCraterTile") || t.assetName.equals("FilledHeavyCraterTile")) {
        return 2;
      } else {
        return 1;
      }
    } };
    digCrater.myDrone = this;
    
    droneActions = new DroneAction[] { fillCrater, digCrater };
  }
  
  boolean built = false;
  boolean startedBuilding = false;
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier;
    buildProgress -= time.currentTimeSpeed;
    if(buildProgress <= 0 && !built && startedBuilding) {
      built = true;
      buildProgress = -1;
      canMove = true;
      SimpleTile myTile = (SimpleTile)map.WorldPointToTile(x+width/2,y+width/2);
      if(myTile.assetName.equals("CraterTile") || myTile.assetName.equals("DugCraterTile")) {
        myTile.assetName = "FilledCraterTile";
        myTile.sprite = assetManager.getAssetByName("FilledCraterTile").getImageAsset();
      } else if(myTile.assetName.equals("HeavyCraterTile")) {
        myTile.assetName = "FilledHeavyCraterTile";
        myTile.sprite = assetManager.getAssetByName("FilledHeavyCraterTile").getImageAsset();
      } else if(myTile.assetName.equals("FlatTile") || myTile.assetName.equals("FilledHeavyCraterTile") || myTile.assetName.equals("FilledCraterTile")) {
        myTile.assetName = "DugCraterTile";
        myTile.sprite = assetManager.getAssetByName("DugCraterTile").getImageAsset();
      }
    }
  }
  
  public void draw() {
    super.draw();
    if(buildProgress >= 0 && startedBuilding && !built) {
      pushStyle();
      fill(255,0,0,64);
      noStroke();
      ellipseMode(CORNER);
      ellipse(x, y, width, height);
      popStyle();
    }
  }
}

public float anomalyModifier = 0f;

public class ScienceDrone extends SimpleDrone {
  public float buildProgress = 0f;
  
  public ScienceDrone(float x, float y, float width, float height) {
    super("ScienceDrone", x, y, width, height);
    
    destructionPenalty = 10;
    upkeep = 1 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    
    DroneAction researchAnomaly = new DroneAction("AnomalyResearchButton");
    researchAnomaly.name = "Research Anomaly";
    
    researchAnomaly.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      ((ScienceDrone)drone).built = false;
      ((ScienceDrone)drone).startedBuilding = true;
      ((ScienceDrone)drone).buildProgress = 1200;
      ((ScienceDrone)drone).stopMoving();
      ((ScienceDrone)drone).canMove = false;
    } };
    
    researchAnomaly.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      SimpleTile t = (SimpleTile) map.WorldPointToTile(d.x+d.width/2,d.y+d.width/2);
      if(t.GetBuilding() != null && t.GetBuilding() instanceof Anomaly && (!((ScienceDrone)d).startedBuilding || ((ScienceDrone)d).built)) {
        return 2;
      } else {
        return 1;
      }
    } };
    researchAnomaly.myDrone = this;
    
    droneActions = new DroneAction[] { researchAnomaly };
  }
  
  public boolean built = false;
  public boolean startedBuilding = false;
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier;
    buildProgress -= time.currentTimeSpeed;
    if(buildProgress <= 0 && built == false && startedBuilding == true) {
      startedBuilding = false;
      built = true;
      buildProgress = -1;
      canMove = true;
      Anomaly a = (Anomaly) map.WorldPointToTile(x+width/2,y+width/2).GetBuilding();
      map.WorldPointToTile(x+width/2,y+width/2).ClearBuilding();
      program.science += a.scienceValue + anomalyModifier;
      notificationManager.CreateAnomalyResearchedNotification(this,a.scienceValue);
      ui.mustRedrawTechTree = true;
    }
  }
  
  public void draw() {
    super.draw();
    if(buildProgress >= 0 && startedBuilding) {
      pushStyle();
      fill(255,0,0,64);
      noStroke();
      ellipseMode(CORNER);
      ellipse(x, y, width, height);
      popStyle();
    }
  }
}

public boolean combatDronesUnlocked = false;

public class CombatDrone extends SimpleDrone {
  public float timeSinceFired = 100;
  public Leviathan target = null;
  public boolean selectingTarget = false;
  
  public float damageModifier = 70;
  
  public float range = 150;
  
  public CombatDrone(float x, float y, float width, float height) {
    super("CombatDrone", x, y, width, height);
    
    destructionPenalty = 50;
    upkeep = 1 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    
    DroneAction setTarget = new DroneAction("AnomalyResearchButton");
    setTarget.name = "SetTarget";
    
    setTarget.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      ((CombatDrone)drone).selectingTarget = true;
    } };
    
    setTarget.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      if(((CombatDrone)d).selectingTarget) {
        return 0;
      } else {
        return 2;
      }
    } };
    setTarget.myDrone = this;
    
    droneActions = new DroneAction[] { setTarget };
  }
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier;
    timeSinceFired += time.currentTimeSpeed;
    
    if(selectingTarget) {
      selectedDrone = this;
      if(Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted) {
        println("yeetsu");
        for(Leviathan l : leviathans) {
          if(Collisions.RectPointCollision(l.x - l.width/2, l.y - l.height/2, l.width, l.height, c.screenPointToWorldPointX(mouseX,mouseY), c.screenPointToWorldPointY(mouseX,mouseY))) {
            target = l;
          }
        }
        selectingTarget = false;
      }
      if(Input.GetMouseButtonDown(1)) {
        selectingTarget = false;
      }
    } 
    
    if(time.tickThisFrame) {
      if(target != null && pow(abs(target.x - (x + width/2)), 2) + pow(abs(target.y - (y + height/2)), 2) <= range * range) {
        attack(target, damageModifier);
        timeSinceFired = 0;
        laserX = target.x;
        laserY = target.y;
      }
    }
  }
  
  float laserX, laserY;
  
  public void draw() {
    super.draw();
    pushStyle();
    if(target != null && !leviathans.contains(target)) {
      target = null;
    }
    if(timeSinceFired < 10) {
      stroke(0,255,255);
      strokeWeight(7);
      line(x + width/2, y + width/2, laserX, laserY);
    }
    if(selectedDrone == this) {
      if(target != null) {
        stroke(255,0,0);
        strokeWeight(5);
        line(x + width/2, y + width/2, target.x, target.y);
      }
    }
    if(selectingTarget) {
      stroke(255, 0, 0);
      strokeWeight(5);
      noFill();
      ellipseMode(CENTER);
      ellipse(x + width/2, y + height/2, range * 2, range * 2);
    }
    popStyle();
  }
}

public boolean artilleryDroneUnlocked = false;

public class ArtilleryDrone extends SimpleDrone {
  public float timeSinceFired = 100;
  public Leviathan target = null;
  public boolean selectingTarget = false;
  
  public float damageModifier = 80;
  
  public ArtilleryDrone(float x, float y, float width, float height) {
    super("ArtilleryDrone", x, y, width, height);
    
    destructionPenalty = 20;
    upkeep = 2 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    
    DroneAction setTarget = new DroneAction("AnomalyResearchButton");
    setTarget.name = "SetTarget";
    
    setTarget.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      ((ArtilleryDrone)drone).selectingTarget = true;
    } };
    
    setTarget.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      if(((ArtilleryDrone)d).selectingTarget) {
        return 0;
      } else {
        return 2;
      }
    } };
    setTarget.myDrone = this;
    
    droneActions = new DroneAction[] { setTarget };
  }
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier;
    timeSinceFired += time.currentTimeSpeed;
    
    if(selectingTarget) {
      selectedDrone = this;
      if(Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted) {
        for(Leviathan l : leviathans) {
          if(Collisions.RectPointCollision(l.x - l.width/2, l.y - l.height/2, l.width, l.height, c.screenPointToWorldPointX(mouseX,mouseY), c.screenPointToWorldPointY(mouseX,mouseY))) {
            target = l;
          }
        }
        selectingTarget = false;
      }
      if(Input.GetMouseButtonDown(1)) {
        selectingTarget = false;
      }
    }
    
    if(time.tickThisFrame) {
      if(target != null) {
        attack(target, damageModifier);
        timeSinceFired = 0;
        laserX = target.x;
        laserY = target.y;
      }
    }
  }
  
  float laserX, laserY;
  
  public void draw() {
    super.draw();
    pushStyle();
    if(target != null && !leviathans.contains(target)) {
      target = null;
    }
    if(timeSinceFired < 60) {
      stroke(0,255,255);
      if(timeSinceFired < 20) {
        strokeWeight(timeSinceFired * 1.5);
      } else if(timeSinceFired < 40) {
        strokeWeight(30);
      } else {
        strokeWeight(60 - (timeSinceFired - 20) * 1.5);
      }
      line(x + width/2, y + width/2, laserX, laserY);
    }
    if(selectedDrone == this) {
      if(target != null) {
        stroke(255,0,0);
        strokeWeight(5);
        line(x + width/2, y + width/2, target.x, target.y);
      }
    }
    popStyle();
  }
}

boolean lunarMissilesUnlocked = false;

public class LunarMissile extends SimpleDrone {
  public Leviathan target = null;
  public boolean selectingTarget = false;
  
  public float damageModifier = 100;
  
  public LunarMissile(float x, float y, float width, float height) {
    super("LunarMissile", x, y, width, height);
    
    destructionPenalty = 50;
    upkeep = 1 + droneUpkeepModifier;
    program.creditsPerTurn -= upkeep;
    
    DroneAction fire = new DroneAction("AnomalyResearchButton");
    fire.name = "Fire";
    
    fire.onClick = new OnDroneActionPressedDelegate() { public void OnPressed(Drone drone) { 
      ((LunarMissile)drone).selectingTarget = true;
    } };
    
    fire.canBeRun = new DroneActionCanBeRunDelegate() { public int canBeRun(Drone d) {
      if(((LunarMissile)d).selectingTarget) {
        return 0;
      } else {
        return 2;
      }
    } };
    fire.myDrone = this;
    
    droneActions = new DroneAction[] { fire };
  }
  
  public void update() {
    super.update();
    upkeep = 1 + droneUpkeepModifier;
    
    if(selectingTarget) {
      selectedDrone = this;
      if(Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted) {
        for(Leviathan l : leviathans) {
          if(Collisions.RectPointCollision(l.x - l.width/2, l.y - l.height/2, l.width, l.height, c.screenPointToWorldPointX(mouseX,mouseY), c.screenPointToWorldPointY(mouseX,mouseY))) {
            target = l;
            attack(target, damageModifier);
            drones.remove(this);
            return;
          }
        }
        selectingTarget = false;
      }
      if(Input.GetMouseButtonDown(1)) {
        selectingTarget = false;
      }
    } 
    
    if(time.tickThisFrame) {
      if(target != null) {
        attack(target, damageModifier);
      }
    }
  }
  
  public void draw() {
    super.draw();
  }
}

public class DroneAction {
  public OnDroneActionPressedDelegate onClick; // DroneActions need the onClick and canBeRun delegates and also a reference to the drone it operates on
  public DroneActionCanBeRunDelegate canBeRun;
  public Drone myDrone;
  
  public DroneAction(String imageAsset) {
    pimage = assetManager.getAssetByName(imageAsset).getImageAsset();
    this.imageAsset = imageAsset;
  }
  
  // These are for the UI to show the DroneAction options properly
  public String imageAsset;
  public PImage pimage;
  public String name;
}

public interface OnDroneActionPressedDelegate {
  public void OnPressed(Drone drone);
}

public interface DroneActionCanBeRunDelegate {
  public int canBeRun(Drone drone); // Return 0 for hide, 1 for show but grey, and 2 for can be run
}
