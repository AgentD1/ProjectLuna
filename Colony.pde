// There's a lot of C word files, aren't there?
// Very cool
// This file contains everything Colony related. Technically, a colony is a building and would thus go in Building, but colonies are complex and there's over 500 lines in here. So no.

Colony selectedColony;

Colony colonyBuildingArtificialCity = null;

public enum FocusType { 
  MINERALS, FOOD, WATER, METAL, ALLOY, ELECTRONICS, SCIENCE // These are the different resources in the game.
}

public float startingPop = 1.2; // This is the current starting population of a colony
public float colonyGrowthSpeedModifiers = 1f;

public float droneConstructionSpeed = 1f;

public boolean updateColonies = false;

public boolean psionicPops = false;

public class Colony extends Building {
  public float pop = startingPop;
  float lastPop = pop;

  public String name; // This is the variable for the name of the colony

  float foodUsedPerTurn = 0; // This is the variable which measures food resources per turn
  float waterUsedPerTurn = 0; // This is the variable which measures water resources per turn

  int workRadius = 4; // This is the radius in which the colony can work buildings

  public boolean ignoreNegatives = false; // This is the code that allows for the colony to ignore negative resources
  public FocusType focus = FocusType.MINERALS; // This is the focus for the mineral type

  FocusType lastFocus = focus;

  public ColonyFocus currentDroneBuilding; // This is which drone you are supposed to be building

  ArrayList<Building> surroundingBuildings; 

  float foodPerTurn, waterPerTurn, mineralsPerTurn, metalPerTurn, alloyPerTurn, electronicsPerTurn, sciencePerTurn; // These are the variables for the food per turn

  PImage image;
  public Colony(Tile tile) { // This is the constructor for the colony. Nothing interesting here.
    super(tile);
    updatePerTurnValues();
    image = assetManager.getAssetByName("ColonyBuilding").getImageAsset();
    //currentDroneBuilding = new CreateConstructionDroneFocus(this); // This was for testing and is now unneccessary. Uncomment it if you want to have it default to building construction drones I guess?
  }

  public void onAdded() { // This is the constructor for the name of the colony
    name = "1234567890123456789012345678901234567890";
    while (name == null || name.length() > 20 || name.length() < 3) {
      noLoop();
      Input.Reset();
      name = JOptionPane.showInputDialog("Name your colony! Between 3 and 20 characters please.");
      loop();
    }
    updatePerTurnValues();
  }

  public void onRemoved() { // This is where we remove the colony if it is too small
    pop = 0;
    updatePerTurnValues();
  }

  public void update() { // This is where we check if the colony has been selected
    if (Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted && Collisions.RectPointCollision(myTile.x * map.getTileWidth(), (myTile.y-1) * map.getTileHeight(), map.getTileWidth(), map.getTileHeight(), c.screenPointToWorldPointX(mouseX, mouseY), c.screenPointToWorldPointY(mouseX, mouseY))) {
      selectedColony = this; // If we've been clicked, we are now the selected colony!
      ui.recalculateColonyValues();
    }
    if (selectedColony == this) {
      // If we click somewhere than on the colony, then this colony isn't selected anymore
      if (Input.GetMouseButtonDown(0) && !Input.hasInputBeenIntercepted && !Collisions.RectPointCollision(myTile.x * map.getTileWidth(), (myTile.y-1) * map.getTileHeight(), map.getTileWidth(), map.getTileHeight(), c.screenPointToWorldPointX(mouseX, mouseY), c.screenPointToWorldPointY(mouseX, mouseY))) {
        selectedColony = null;
      }
    }

    if (checkedTiles == null || checkedTiles.size() == 0) {
      checkedTiles = new ArrayList<Tile>();
      drawTilesOut(myTile.x, myTile.y, workRadius);
    }
    
    ArrayList<Building> tempBuildings = new ArrayList<Building>();

    for (Tile t : checkedTiles) {
      if (t.GetBuilding() != null) {
        if (t.GetBuilding() instanceof Colony) {
          continue;
        }
        tempBuildings.add(t.GetBuilding());
      }
    }
    
    
    if(currentDroneBuilding != null) {
      currentDroneBuilding.update();
    }
      
    if (tempBuildings.size() != surroundingBuildings.size() || !tempBuildings.containsAll(surroundingBuildings) || lastFocus != focus || lastPop != pop ) {
      updatePerTurnValues();
    }

    if (!time.tickThisFrame) {
      return;
    }
    // This is how we handle the growth of colonies
    if (program.foodPerTurn >= 20 && program.waterPerTurn >= 20) { 
      pop += 0.2 * colonyGrowthSpeedModifiers;
    } else if (program.foodPerTurn >= 10 && program.waterPerTurn >= 10) {
      pop += 0.1 * colonyGrowthSpeedModifiers;
    } else if (program.foodPerTurn >= 5 && program.waterPerTurn >= 5) {
      pop += 0.05 * colonyGrowthSpeedModifiers;
    } else if (program.foodPerTurn >= 1 && program.waterPerTurn >= 1) {
      pop += 0.01 * colonyGrowthSpeedModifiers;
    }
    // This is how we handle the starvation of colonies
    if ((program.foodPerTurn <= -20 && program.food <= 0) || (program.waterPerTurn <= -20 && program.water <= 0)) {
      pop -= 0.2 * colonyGrowthSpeedModifiers;
    } else if ((program.foodPerTurn <= -10 && program.food <= 0) || (program.waterPerTurn <= -10 && program.water <= 0)) {
      pop -= 0.1 * colonyGrowthSpeedModifiers;
    } else if ((program.foodPerTurn <= -5 && program.food <= 0) || (program.waterPerTurn <= -5 && program.water <= 0)) {
      pop -= 0.05 * colonyGrowthSpeedModifiers;
    } else if ((program.foodPerTurn < 0 && program.food <= 0) || (program.waterPerTurn < 0 && program.water <= 0)) {
      pop -= 0.01 * colonyGrowthSpeedModifiers;
    }
    
    if(pop > 20) {
      destructionPenalty = 120;
    } else if(pop > 15) {
      destructionPenalty = 110;
    } else if(pop > 10) {
      destructionPenalty = 100;
    } else if(pop > 5) {
      destructionPenalty = 90;
    } else {
      destructionPenalty = 80;
    }

    updatePerTurnValues();

    program.food -= foodUsedPerTurn;
    program.water -= waterUsedPerTurn;

    if (pop < 1) {
      myTile.ClearBuilding();
    }
    
    lastFocus = focus;
    lastPop = pop;
  }

  public void updatePerTurnValues() { // This is how we change how we calculated colony consumption of food and water per turn and re-load it
    program.foodPerTurn += foodUsedPerTurn;
    program.waterPerTurn += waterUsedPerTurn;

    foodUsedPerTurn = floor(pop) * 0.5;
    waterUsedPerTurn = floor(pop) * 0.5;

    program.foodPerTurn -= foodUsedPerTurn;
    program.waterPerTurn -= waterUsedPerTurn;
    
    if (checkedTiles == null || checkedTiles.size() == 0) {
      checkedTiles = new ArrayList<Tile>();
      drawTilesOut(myTile.x, myTile.y, workRadius);
    }
    
    surroundingBuildings = new ArrayList<Building>();

    for (Tile t : checkedTiles) {
      if (t.GetBuilding() != null) {
        if (t.GetBuilding() instanceof Colony) {
          continue;
        }
        surroundingBuildings.add(t.GetBuilding());
      }
    }
    
    if (surroundingBuildings != null) {
      for (Building b : surroundingBuildings) {
        ((SimpleBuilding)b).onUnWorked();
      }
    }

    float foodPerTurnRN = program.foodPerTurn, waterPerTurnRN = program.waterPerTurn, mineralsPerTurnRN = program.mineralsPerTurn, metalPerTurnRN = program.metalPerTurn, alloyPerTurnRN = program.alloyPerTurn, electronicsPerTurnRN = program.electronicsPerTurn, sciencePerTurnRN = program.sciencePerTurn;


    int availablePops = floor(pop);
    if(psionicPops) {
      availablePops *= 2;
    }

    // Self sustainability
    if (!ignoreNegatives) {
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.foodPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Hydroponics && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }

      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.waterPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof WaterExtractor && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }

      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.mineralsPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Mine && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }

      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.metalPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Factory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }

      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.alloyPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof AlloyFactory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }

      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (program.electronicsPerTurn >= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof ElectronicsFactory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    }

    if (focus == FocusType.MINERALS) { // This is the focus for minerals
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Mine && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.FOOD) { // This is the focus for food
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Hydroponics && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.WATER) { // This is the focus for water
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof WaterExtractor && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.METAL) { // This is the focus for metal
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof Factory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.ALLOY) { // This is the focus for alloy
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof AlloyFactory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.ELECTRONICS) { // This is the focus for electronics
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof ElectronicsFactory && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    } else if (focus == FocusType.SCIENCE) { // This is the focus for science
      for (Tile t : checkedTiles) {
        if (t.GetBuilding() != null) {
          if (availablePops <= 0) {
            break;
          }
          if (t.GetBuilding() instanceof Colony) {
            continue;
          }
          SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
          if (b instanceof ScienceOutpost && !b.worked) {
            b.onWorked();
            availablePops--;
          }
        }
      }
    }

    for (Tile t : checkedTiles) {
      if (t.GetBuilding() != null) {
        if (availablePops <= 0) {
          break;
        }
        if (t.GetBuilding() instanceof Colony) {
          continue;
        }
        SimpleBuilding b = (SimpleBuilding) t.GetBuilding();
        if (!b.worked) {
          b.onWorked();
          availablePops--;
        }
      }
    }

    foodPerTurn = program.foodPerTurn - foodPerTurnRN - floor(pop) * 0.5; // This is how the colony food per turn is calculated
    waterPerTurn = program.waterPerTurn - waterPerTurnRN - floor(pop) * 0.5; // This is how the colony water per turn is calculated
    mineralsPerTurn = program.mineralsPerTurn - mineralsPerTurnRN; // This is how the colony minerals per turn is calculated
    metalPerTurn = program.metalPerTurn - metalPerTurnRN; // This is how the colony metal per turn is calculated
    alloyPerTurn = program.alloyPerTurn - alloyPerTurnRN; // This is how the colony alloy per turn is calculated
    electronicsPerTurn = program.electronicsPerTurn - electronicsPerTurnRN; // This is how the colony electronica per turn is calculated
    sciencePerTurn = program.sciencePerTurn - sciencePerTurnRN; // This is how the colony science per turn is calculated

    if (availablePops > 0) {
    }
  }

  public void draw() { // This is where the colony is drawn
    pushStyle();
    if (checkedTiles == null || checkedTiles.size() == 0) {
      checkedTiles = new ArrayList<Tile>();
      drawTilesOut(myTile.x, myTile.y, workRadius);
    }
    if (selectedColony == this) {
      fill(255, 255, 0, 64);
      ellipseMode(CORNER);
      ellipse(myTile.x * map.getTileWidth(), myTile.y * map.getTileHeight() - map.getTileHeight(), map.getTileWidth(), map.getTileHeight());
    }
    stroke(0);
    strokeWeight(4);
    for (Tile t : checkedTiles) { // This is where the colony's borders are drawn
      boolean leftBlocked = checkedTiles.contains(map.getTile(t.x-1, t.y));
      boolean rightBlocked = checkedTiles.contains(map.getTile(t.x+1, t.y));
      boolean topBlocked = checkedTiles.contains(map.getTile(t.x, t.y-1));
      boolean bottomBlocked = checkedTiles.contains(map.getTile(t.x, t.y+1));
      if (!leftBlocked) {
        line(t.x * map.getTileWidth(), (t.y-1) * map.getTileHeight(), t.x * map.getTileWidth(), t.y * map.getTileHeight());
      }
      if (!rightBlocked) {
        line((t.x+1) * map.getTileWidth(), (t.y-1) * map.getTileHeight(), (t.x+1) * map.getTileWidth(), t.y * map.getTileHeight());
      }
      if (!topBlocked) {
        line(t.x * map.getTileWidth(), (t.y-1) * map.getTileHeight(), (t.x+1) * map.getTileWidth(), (t.y-1) * map.getTileHeight());
      }
      if (!bottomBlocked) {
        line(t.x * map.getTileWidth(), t.y * map.getTileHeight(), (t.x+1) * map.getTileWidth(), t.y * map.getTileHeight());
      }
    } 
    noStroke();
    if (selectedColony == this) {
      fill(255, 255, 0, 32);
      for (Tile t : checkedTiles) {
        rect(t.x * map.getTileWidth(), t.y * map.getTileHeight() - map.getTileHeight(), map.getTileWidth(), map.getTileHeight()); // This draws the inner territory of the colony
      }
    }
    textAlign(CENTER, BOTTOM);
    textSize(24);
    fill(255, 255, 255);
    if (ui.debugDisplay) { // This displays the population of the colony
      text(pop, myTile.x * map.getTileWidth() + map.getTileWidth()/2, myTile.y * map.getTileHeight() - image.height);
    } else {
      text(floor(pop), myTile.x * map.getTileWidth() + map.getTileWidth()/2, myTile.y * map.getTileHeight() - image.height);
    }
    image(image, myTile.x * map.getTileWidth(), (myTile.y * map.getTileHeight()) - image.height);
    popStyle();
  }

  public ArrayList<Tile> checkedTiles; // This recursively loops over the tiles to find out which tiles are within the territory

  void drawTilesOut(int x, int y, int distance) {
    Tile t = map.getTile(x, y);
    if (distance == 0) {
      return;
    }
    if (!checkedTiles.contains(t)) {
      checkedTiles.add(t);
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

public abstract class ColonyFocus { // This is a class which allows us to focus on certain resources
  public Colony myColony;
  public float timeLeft;
  public String name;
  public PImage image;
  public ColonyFocus(Colony myColony, float time, String imageAsset) {
    timeLeft = time;
    this.myColony = myColony;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
  }

  public void update() {
    timeLeft -= time.currentTimeSpeed * droneConstructionSpeed;
    if(timeLeft <= 0) {
      myColony.currentDroneBuilding = null;
      notificationManager.CreateColonyIdleNotifications(myColony);
      onComplete();
    }
  }

  public abstract void onComplete();
}

public class CreateColonyDroneFocus extends ColonyFocus { // This allows the colony to create colony drones
  public CreateColonyDroneFocus(Colony myColony) {
    super(myColony, 4200f, "ColonyDrone");
    name = "Build Colony Drone";
  }
  public void onComplete() {
    drones.add(new ColonyDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateConstructionDroneFocus extends ColonyFocus { // This allows the colony to create a construction drone
  public CreateConstructionDroneFocus(Colony myColony) {
    super(myColony, 3600f, "ConstructionDrone");
    name = "Build Constructor Drone";
  }
  public void onComplete() {
    drones.add(new ConstructorDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateFillerDroneFocus extends ColonyFocus { // This allows the colony to create a filler drone
  public CreateFillerDroneFocus(Colony myColony) {
    super(myColony, 3000f, "FillerDrone");
    name = "Build Filler Drone";
  }
  public void onComplete() {
    drones.add(new FillerDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateScienceDroneFocus extends ColonyFocus { // This allows the colony to create a science drone
  public CreateScienceDroneFocus(Colony myColony) {
    super(myColony, 3000f, "ScienceDrone");
    name = "Build Science Drone";
  }
  public void onComplete() {
    drones.add(new ScienceDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateCombatDroneFocus extends ColonyFocus { // This allows the colony to create a science drone
  public CreateCombatDroneFocus(Colony myColony) {
    super(myColony, 4200f, "CombatDrone");
    name = "Build Combat Drone";
  }
  public void onComplete() {
    drones.add(new CombatDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateArtilleryDroneFocus extends ColonyFocus { // This allows the colony to create a science drone
  public CreateArtilleryDroneFocus(Colony myColony) {
    super(myColony, 4800f, "ArtilleryDrone");
    name = "Build Artillery Drone";
  }
  public void onComplete() {
    drones.add(new ArtilleryDrone(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public class CreateLunarMissileFocus extends ColonyFocus { // This allows the colony to create a science drone
  public CreateLunarMissileFocus(Colony myColony) {
    super(myColony, 1800f, "LunarMissile");
    name = "Build Lunar Missile";
  }
  public void onComplete() {
    drones.add(new LunarMissile(myColony.myTile.x * map.getTileWidth(), myColony.myTile.y * map.getTileWidth(), 100f, 100f));
  }
}

public boolean artificialCityUnlocked = false;

public class CreateArtificalCityFocus extends ColonyFocus { // This allows the colony to create a science drone
  public CreateArtificalCityFocus(Colony myColony) {
    super(myColony, 12000f, "ArtificalCityTech");
    name = "Build Artifical City";
    colonyBuildingArtificialCity = myColony;
  }
  public void onComplete() {
    ui.ShowVictoryScreen();
  }
}
