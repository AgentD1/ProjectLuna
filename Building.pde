// This file contains all Building classes and functions, except for Colony's because they're long and more advanced than regular buildings

public abstract class Building { // All Building's must inherit from this abstract Building class/
  public String name;
  public Tile myTile;
  
  public float destructionPenalty = 10;
  
  public Building(Tile tile) {
    myTile = tile;
  }
  
  // We chose to make an abstract class instead of an interface to simplify inheritence. Because of all these blank functions, 
  // buildings that don't want to do anything on update, updateTick, etc. don't even have to implement the function. Very nice
  public void update() {
    
  }
  
  public void updateTick() { // Triggers every tick
    
  }
  
  public void onAdded() {
    
  }
  
  public void onRemoved() {
    
  }
  
  public abstract void draw();
}

// It would probably be possible to combine SimpleBuilding and Building, since they're both abstract and in most cases we just convert from Building to SimpleBuilding anyway
// Ahh well. I guess if we ever needed to make a building that doesn't draw using an image, we could. But we never do. Future thinking I guess?
public abstract class SimpleBuilding extends Building {
  public float timeToBuild; // The amount of time the constructor bot will take to build this at default speeds
  public float timeAlive = 0; // The amount of time since this building was instansiated
  public boolean built = false; // Whether this building has been completed yet
  
  public boolean worked = false;
  
  public SimpleBuilding(Tile tile, String imageAssetName, float timeToBuild) { // Basic boring constructor. Nothing to explain here
    super(tile);
    imageAsset = imageAssetName;
    image = assetManager.getAssetByName(imageAsset).getImageAsset(); // Except maybe this. We havent used this line yet. This is a demonstration of how interacting with the AssetManager works
    name = "TestBuilding";
    this.timeToBuild = timeToBuild;
  }
  
  // Drawing-related stuff
  String imageAsset;
  public PImage image;
  
  public void update() {
    super.update();
    if(!built && timeAlive >= timeToBuild / globalConstructionSpeedModifier) { // If we completed building this frame, set built to true and call our child's onBuilt function (unless they didn't override the blank one)
      built = true;
      onBuilt();
    }
    timeAlive += time.currentTimeSpeed;
  }
  
  public void draw() {
    pushStyle();
    if(!built) {
      tint(255,0,0); // For now, incomplete buildings get a red tint
    }
    image(image, myTile.x * map.getTileWidth(), (myTile.y * map.getTileHeight()) - image.height); // The building is drawn with the bottom-left corner at (x,y) instead of the top-left. This ended up being useless but was designed so buildings could be taller than 100px
    popStyle();
  }
  
  public void onWorked() {
    
  }
  
  public void onUnWorked() {
    
  }
  
  public void onBuilt() {
    notificationManager.CreateBuildingCompletedNotification(this);
  }
  
  public void onRemoved() {
    if(worked) {
      onUnWorked();
    }
  }
}

float mineProduction = 3;

// This is the start of the lame section of the Building file. Everything is basically the same with a slight difference, being the resources produced, consumed, the image passed to SimpleBuilding, and the build time

public class Mine extends SimpleBuilding {
  float knownMineProduction;
  public Mine(Tile tile) {
    super(tile, "MineBuilding", 1200); // Pass our parent SimpleBuilding the required data
    name = "Mine";
    knownMineProduction = mineProduction;
    destructionPenalty = 40;
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    worked = true;
    if(built) {
      if(((SimpleTile)myTile).assetName.equals("MountainTile")) { // Since mines produce 1 more mineral on mountains, it checks here
        program.mineralsPerTurn += knownMineProduction + 1;
      } else {
        program.mineralsPerTurn += knownMineProduction;
      }
    }
  }
  // When the Mine is removed, all the resources it produced are no longer being produced
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    worked = false;
    if(built) {
      if(((SimpleTile)myTile).assetName.equals("MountainTile")) {
        program.mineralsPerTurn -= knownMineProduction + 1;
      } else {
        program.mineralsPerTurn -= knownMineProduction;
      }
    }
  }
  
  public void update() {
    super.update();
    if(built && worked && knownMineProduction != mineProduction) {
      onUnWorked();
      knownMineProduction = mineProduction;
      onWorked();
    }
  }
  
  public void updateTick() { // The SpaceProgram itself doesn't actually update the resource values every tick. The values in the variables like mineralsPerTurn are just for the UI. So, we need to add minerals manually each tick.
    super.updateTick();
    if(built && worked) {
      if(((SimpleTile)myTile).assetName.equals("MountainTile")) {
        program.minerals += mineProduction + 1;
      } else {
        program.minerals += mineProduction;
      }
    }
  }
}

// There will be no comments from here to the end of the page because everything is basically the same.

public float hydroponicsProduction = 3;

public class Hydroponics extends SimpleBuilding {
  public float knownHydroponicsProduction;
  
  public Hydroponics(Tile tile) {
    super(tile, "HydroponicsBuilding", 1200);
    knownHydroponicsProduction = hydroponicsProduction;
    name = "Hydroponics";
    destructionPenalty = 20;
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    worked = true;
    if(built) {
      program.foodPerTurn += knownHydroponicsProduction;
    }
  }
  
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    worked = false;
    if(built) {
      program.foodPerTurn -= knownHydroponicsProduction;
    }
  }
  
  public void update() {
    super.update();
    if(built && worked && knownHydroponicsProduction != hydroponicsProduction) {
      onUnWorked();
      knownHydroponicsProduction = hydroponicsProduction;
      onWorked();
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      program.food += knownHydroponicsProduction;
    }
  }
}

public float factoryProduction = 1;
public float factoryConsumption = 2;

public class Factory extends SimpleBuilding {
  public float knownFactoryProduction;
  public float knownFactoryConsumption;
  
  public Factory(Tile tile) {
    super(tile, "FactoryBuilding", 1800);
    knownFactoryProduction = factoryProduction;
    knownFactoryConsumption = factoryConsumption;
    name = "Factory";
    destructionPenalty = 30;
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    worked = true;
    if(built) {
      program.metalPerTurn += knownFactoryProduction;
      program.mineralsPerTurn -= knownFactoryConsumption;
    }
  }
  
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    worked = false;
    if(built) {
      program.metalPerTurn -= knownFactoryProduction;
      program.mineralsPerTurn += knownFactoryConsumption;
    }
  }
  
  public void update() {
    super.update();
    if(built && worked && (knownFactoryProduction != factoryProduction || knownFactoryConsumption != factoryConsumption)) {
      onUnWorked();
      knownFactoryProduction = factoryProduction;
      knownFactoryConsumption = factoryConsumption;
      onWorked();
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      program.metal += knownFactoryProduction;
      program.minerals -= knownFactoryConsumption;
    }
  }
}

public float alloyFactoryProduction = 1;
public float alloyFactoryConsumption = 2;

public class AlloyFactory extends SimpleBuilding {
  public float knownAlloyFactoryProduction;
  public float knownAlloyFactoryConsumption;
  
  public AlloyFactory(Tile tile) {
    super(tile, "AlloyFactoryBuilding", 2400);
    knownAlloyFactoryProduction = alloyFactoryProduction;
    knownAlloyFactoryConsumption = alloyFactoryConsumption;
    name = "Alloy Factory";
    destructionPenalty = 20;
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void update() {
    super.update();
    if(built && worked && (knownAlloyFactoryConsumption != alloyFactoryConsumption || knownAlloyFactoryProduction != alloyFactoryProduction)) {
      onUnWorked();
      knownAlloyFactoryProduction = alloyFactoryProduction;
      knownAlloyFactoryConsumption = alloyFactoryConsumption;
      onWorked();
    }
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    if(built) {
      worked = true;
      program.alloyPerTurn += knownAlloyFactoryProduction;
      program.metalPerTurn -= knownAlloyFactoryConsumption;
    }
  }
  
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    if(built) {
      worked = false;
      program.alloyPerTurn -= knownAlloyFactoryProduction;
      program.metalPerTurn += knownAlloyFactoryConsumption;
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      program.metal -= knownAlloyFactoryConsumption;
      program.alloy += knownAlloyFactoryProduction;
    }
  }
}

public float electronicsFactoryProduction = 1;
public float electronicsFactoryConsumption = 3;

public class ElectronicsFactory extends SimpleBuilding {
  public float knownElectronicsFactoryProduction;
  public float knownElectronicsFactoryConsumption;
  
  public ElectronicsFactory(Tile tile) {
    super(tile, "ElectronicsFactoryBuilding", 2400);
    knownElectronicsFactoryProduction = electronicsFactoryProduction;
    knownElectronicsFactoryConsumption = electronicsFactoryConsumption;
    name = "Electronics Factory";
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    worked = true;
    if(built) {
      program.electronicsPerTurn += knownElectronicsFactoryProduction;
      program.metalPerTurn -= knownElectronicsFactoryConsumption;
    }
  }
  
  public void update() {
    super.update();
    if(built && worked && (knownElectronicsFactoryConsumption != electronicsFactoryConsumption || knownElectronicsFactoryProduction != electronicsFactoryProduction)) {
      onUnWorked();
      knownElectronicsFactoryProduction = electronicsFactoryProduction;
      knownElectronicsFactoryConsumption = electronicsFactoryConsumption;
      onWorked();
    }
  }
  
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    worked = false;
    if(built) {
      program.electronicsPerTurn -= knownElectronicsFactoryProduction;
      program.metalPerTurn += knownElectronicsFactoryConsumption;
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      program.metal -= knownElectronicsFactoryConsumption;
      program.electronics += knownElectronicsFactoryProduction;
    }
  }
}

public float waterExtractorProduction = 4;

public class WaterExtractor extends SimpleBuilding {
  public float knownWaterExtractorProduction;
  public WaterExtractor(Tile tile) {
    super(tile, "WaterExtractorBuilding", 1800);
    knownWaterExtractorProduction = waterExtractorProduction;
    name = "Water Extractor";
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    if(worked || !built) {
      return;
    }
    worked = true;
    if(built) {
      if(((SimpleTile)myTile).assetName.equals("HeavyCraterTile")) {
        program.waterPerTurn += knownWaterExtractorProduction + 1;
      } else {
        program.waterPerTurn += knownWaterExtractorProduction;
      }
    }
  }
  
  public void onUnWorked() { 
    if(!worked) {
      return;
    }
    worked = false;
    if(built) {
      if(((SimpleTile)myTile).assetName.equals("HeavyCraterTile")) {
        program.waterPerTurn -= knownWaterExtractorProduction + 1;
      } else {
        program.waterPerTurn -= knownWaterExtractorProduction;
      }
    }
  }
  
  public void update() {
    super.update();
    if(built && !worked && knownWaterExtractorProduction != waterExtractorProduction) {
      onUnWorked();
      knownWaterExtractorProduction = waterExtractorProduction;
      onWorked();
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      if(((SimpleTile)myTile).assetName.equals("HeavyCraterTile")) {
        program.water += waterExtractorProduction + 1;
      } else {
        program.water += waterExtractorProduction;
      }
    }
  }
}

public float scienceOutpostProduction = 2;
public float scienceOutpostConsumption = 1;

public class ScienceOutpost extends SimpleBuilding {
  public float knownScienceOutpostProduction;
  public float knownScienceOutpostConsumption;

  public ScienceOutpost(Tile tile) {
    super(tile, "ScienceOutpostBuilding", 1800);
    knownScienceOutpostProduction = scienceOutpostProduction;
    knownScienceOutpostConsumption = scienceOutpostConsumption;
    name = "Science Outpost";
  }
  
  public void onBuilt() {
    super.onBuilt();
    //onWorked();
  }
  
  public void onWorked() {
    super.onWorked();
    if(worked || !built) {
      return;
    }
    if(built) {
      worked = true;
      println(frameCount);
      program.mineralsPerTurn -= knownScienceOutpostConsumption;
      program.sciencePerTurn += knownScienceOutpostProduction;
    }
  }
  
  public void onUnWorked() { 
    super.onUnWorked();
    if(!worked || !built) {
      return;
    }
    if(built) {
      worked = false;
      program.mineralsPerTurn += knownScienceOutpostConsumption;
      program.sciencePerTurn -= knownScienceOutpostProduction;
    }
  }
  
  public void update() {
    super.update();
    if(built && worked && (knownScienceOutpostConsumption != scienceOutpostConsumption || knownScienceOutpostProduction != scienceOutpostProduction)) {
      onUnWorked();
      knownScienceOutpostConsumption = scienceOutpostConsumption; 
      knownScienceOutpostProduction = scienceOutpostProduction;
      onWorked();
    }
  }
  
  public void updateTick() {
    super.updateTick();
    if(built && worked) {
      program.minerals -= scienceOutpostConsumption;
      program.science += scienceOutpostProduction;
    }
  }
}

// Haha I lied, here's a comment.
// Bet you didn't scroll all the way down here
// Well it's nice you're down here because now I can say hi
// hi

public class Anomaly extends SimpleBuilding {
  public int scienceValue;
  
  public Anomaly(Tile tile) {
    super(tile, (new String[] { "AnomalyA", "AnomalyB", "AnomalyC", "AnomalyD", "AnomalyE" })[floor(random(0,5))], 1800);
    scienceValue = floor(random(10,25));
    built = true;
    name = "Anomaly";
  }
}
