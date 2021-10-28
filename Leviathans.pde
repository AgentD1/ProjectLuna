public class LeviathanSpawner {
  public boolean spawnLeviathans = false;
  public float timeUntilLeviathans = Float.MAX_VALUE;
  float lastCX, lastCY;
  public void update() {
    if(!spawnLeviathans) {
      timeUntilLeviathans -= time.currentTimeSpeed;
      if(timeUntilLeviathans < 600) {
        c.x = lastCX;
        c.y = lastCY;
        lastCX = c.x;
        lastCY = c.y;
        c.x += random(-100, 100);
        c.y += random(-100, 100);
      }
      if(timeUntilLeviathans < 0) {
        spawnLeviathans = true;
        noLoop();
        Input.Reset();
        JOptionPane.showMessageDialog(null, "You feel a great rumbling in the ground. Suddenly, 3 massive beasts emerge from the ground!", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
        loop();
        c.x = lastCX;
        c.y = lastCY;
        
        Colony spawnOne = null;
        float mineralsNumber = 0;
        for(Tile t : map.tiles) {
          if(t.building instanceof Colony) {
            Colony c = (Colony) t.building;
            if(c.mineralsPerTurn > mineralsNumber) {
              spawnOne = c;
              mineralsNumber = c.mineralsPerTurn;
            }
          }
        }
        
        if(spawnOne == null) {
          println("No colonies!");
          return;
        }
        
        Leviathan l1 = new ColossalLeviathan(c.x * map.getTileWidth() + random(-600,600), c.x * map.getTileHeight() + random(-600,600));
        Leviathan l2 = new ColossalLeviathan(c.x * map.getTileWidth() + random(-600,600), c.x * map.getTileHeight() + random(-600,600));
        Leviathan l3 = new ColossalLeviathan(c.x * map.getTileWidth() + random(-600,600), c.x * map.getTileHeight() + random(-600,600));
        
        leviathans.add(l1);
        leviathans.add(l2);
        leviathans.add(l3);
      }
    } else {
      if(time.tickThisFrame) {
        float chanceOfSpawn = max(10, 10 * (program.mineralsPerTurn / 20));
        if(random(1,100) < chanceOfSpawn) {
          while(true) {
            float randomX = random(0, map.getMapWidth() * map.getTileWidth());
            float randomY = random(0, map.getMapHeight() * map.getTileHeight());
            for(Tile t : map.tiles) {
              if(t.building instanceof Colony) {
                if(pow(abs(randomX - t.x * map.getTileWidth()), 2) + pow(abs(randomY - t.y * map.getTileWidth()),2) < 400 * 400) {
                  continue;
                }
              }
            }
            Leviathan l;
            float random = random(1,100);
            if(random > 80) {
              l = new BurningLeviathan(randomX, randomY);
            } else if(random > 50) {
              l = new BouncerLeviathan(randomX, randomY);
            } else {
              l = new ColossalLeviathan(randomX, randomY);
            }
            notificationManager.CreateLeviathanSpawnNotifications(l);
            leviathans.add(l);
            break;
          }
        }
      }
    }
  }
}

public abstract class Leviathan {
  public PImage image;
  public String imageAsset;
  public float x, y, width, height;
  public float destructionPenalty, damageModifier;
  
  public Leviathan(String imageAsset) {
    this.imageAsset = imageAsset;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
    width = 100;
    height = 100;
  }
  
  public abstract void update();
  public abstract void draw();
}

public class ColossalLeviathan extends Leviathan {
  public float animationTime;
  public Object target;
  public float destX, destY;
  public ColossalLeviathan(float x, float y) {
    super("TypeALeviathan");
    damageModifier = 80;
    destructionPenalty = 80;
    this.x = x;
    this.y = y;
  }
  
  boolean blownThingsUpYet = false;
  public void update() {
    if(time.tickThisFrame) {
      animationTime = 0;
      blownThingsUpYet = false;
    }
    animationTime += time.currentTimeSpeed;
    if(target == null || time.tickThisFrame) {
      setTarget();
    }
    if(animationTime > 300 && !blownThingsUpYet) {
      blownThingsUpYet = true;
      if(pow(abs(x - destX),2) + pow(abs(y - destY),2) <= 10000) {
        attack(target, damageModifier);
      }
    }    
    setDestination();
    PVector direction = new PVector(destX - x, destY - y).setMag(globalCLeviathanMovement * time.currentTimeSpeed); // Figure out which direction we need to go, then make sure the magnitude is our movement speed.
    x += direction.x;
    y += direction.y;
    if (abs(x - destX) < globalCLeviathanMovement * time.currentTimeSpeed && abs(y - destY) < globalCLeviathanMovement * time.currentTimeSpeed) { // If we're close enough we will get there next frame, we might as well teleport. If we don't we'll overshoot and become jittery.
      x = destX;
      y = destY;
    }
  }
  public void draw() {
    pushStyle();
    image(image, x-width/2, y-height/2, width, height);
    popStyle();
  }
  
  public void setTarget() {
    if(colonyBuildingArtificialCity != null) {
      target = colonyBuildingArtificialCity;
      return;
    }
    Tile closestMine = null;
    float dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Mine) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestMine = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestMine != null) {
      target = closestMine;
      return;
    }
    
    if(drones.size() != 0) {
      CombatDrone closestCombatDrone = null;
      dist = 100000;
      for(Drone d : drones) {
        if(d instanceof CombatDrone) {
          if(abs(x - d.x) + abs(y - d.y) <= dist) {
            closestCombatDrone = (CombatDrone) d;
            dist = abs(x - d.x) + abs(y - d.y);
          }
        }
      }
      
      if(closestCombatDrone != null) {
        target = closestCombatDrone;
        return;
      }
    }
    
    // TODO lunar missiles check
    
    Tile closestColony = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Colony) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestColony = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestColony != null) {
      target = closestColony;
      return;
    }
    
    if(drones.size() != 0) {
      Drone closestDrone = null;
      dist = Float.MAX_VALUE;
      for(Drone d : drones) {
        if(pow(abs(x - d.x),2) + pow(abs(y - d.y),2) <= dist) {
          closestDrone = d;
          dist = pow(abs(x - d.x),2) + pow(abs(y - d.y),2);
        }
      }
      
      target = closestDrone;
      return;
    }
    
    Tile closestBuilding = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && !(t.building instanceof Anomaly)) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestBuilding = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestBuilding != null) {
      target = closestBuilding;
      return;
    }
    
    target = null;
  }
  
  public void setDestination() {
    PVector p = getLocationOfObject();
    if(p == null) {
      destX = x;
      destY = y;
      return;
    }
    destX = p.x;
    destY = p.y;
  }
  
  public PVector getLocationOfObject() {
    if(target == null) {
      return null;
    }
    if(target instanceof Drone) {
      Drone d = (Drone) target;
      return new PVector(d.x + d.width/2, d.y + d.height/2);
    }
    
    if(target instanceof Building) {
      Building b = (Building) target;
      return new PVector(b.myTile.x * map.getTileWidth() + map.getTileWidth()/2, b.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Tile) {
      Tile t = (Tile) target;
      return new PVector(t.x * map.getTileWidth() + map.getTileWidth()/2, t.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Colony) {
      Colony c = (Colony) target;
      return new PVector(c.myTile.x * map.getTileWidth() + map.getTileWidth()/2, c.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    return null;
  }}

public float LeviathanBSpringSpeed = 10f;
public class BouncerLeviathan extends Leviathan {
  public float animationTime;
  public Object target;
  public float destX, destY;
  public BouncerLeviathan(float x, float y) {
    super("TypeBLeviathan");
    damageModifier = 60;
    destructionPenalty = 60;
    this.x = x;
    this.y = y;
  }
  
  boolean blownThingsUpYet = false;
  boolean springing = false;
  
  public void update() {
    if(time.tickThisFrame) {
      animationTime = 0;
      blownThingsUpYet = false;
      if(time.tickNumber % 4 == 0) {
        springing = true;
      }
    }
    animationTime += time.currentTimeSpeed;
    if(target == null || time.tickThisFrame) {
      setTarget();
    }
    if(springing) {
      PVector direction = new PVector(destX - x, destY - y).setMag(LeviathanBSpringSpeed * time.currentTimeSpeed); // Figure out which direction we need to go, then make sure the magnitude is our movement speed.
      x += direction.x;
      y += direction.y;
      if (abs(x - destX) < LeviathanBSpringSpeed * time.currentTimeSpeed && abs(y - destY) < LeviathanBSpringSpeed * time.currentTimeSpeed) { // If we're close enough we will get there next frame, we might as well teleport. If we don't we'll overshoot and become jittery.
        x = destX;
        y = destY;
        springing = false;
      }
    } else {
      if(animationTime > 300 && !blownThingsUpYet) {
        blownThingsUpYet = true;
        if(pow(abs(x - destX),2) + pow(abs(y - destY),2) <= 10000) {
          attack(target, damageModifier);
        }
      }
      setDestination();
      PVector direction = new PVector(destX - x, destY - y).setMag(globalCLeviathanMovement * time.currentTimeSpeed); // Figure out which direction we need to go, then make sure the magnitude is our movement speed.
      x += direction.x;
      y += direction.y;
      if (abs(x - destX) < globalCLeviathanMovement * time.currentTimeSpeed && abs(y - destY) < globalCLeviathanMovement * time.currentTimeSpeed) { // If we're close enough we will get there next frame, we might as well teleport. If we don't we'll overshoot and become jittery.
        x = destX;
        y = destY;
      }
    }
  }
  public void draw() {
    pushStyle();
    if(springing) {
      fill(0,0,255,128);
      ellipseMode(CENTER);
      ellipse(x, y, width, height);
    }
    image(image, x-width/2, y-height/2, width, height);
    popStyle();
  }
  
  public void setTarget() {
    if(colonyBuildingArtificialCity != null) {
      target = colonyBuildingArtificialCity;
      return;
    }
    
    Tile closestColony = null;
    float dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Colony) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestColony = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestColony != null) {
      target = closestColony;
      return;
    }
    
    if(drones.size() != 0) {
      CombatDrone closestCombatDrone = null;
      dist = Float.MAX_VALUE;
      for(Drone d : drones) {
        if(d instanceof CombatDrone) {
          if(abs(x - d.x) + abs(y - d.y) <= dist) {
            closestCombatDrone = (CombatDrone) d;
            dist = abs(x - d.x) + abs(y - d.y);
          }
        }
      }
      
      if(closestCombatDrone != null) {
        target = closestCombatDrone;
        return;
      }
    }
    
    // TODO lunar missiles check
    
    
    if(drones.size() != 0) {
      Drone closestDrone = null;
      dist = Float.MAX_VALUE;
      for(Drone d : drones) {
        if(pow(abs(x - d.x),2) + pow(abs(y - d.y),2) <= dist) {
          closestDrone = d;
          dist = pow(abs(x - d.x),2) + pow(abs(y - d.y),2);
        }
      }
      
      target = closestDrone;
      return;
    }
    
    Tile closestMine = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Mine) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestMine = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestMine != null) {
      target = closestMine;
      return;
    }
    
    Tile closestBuilding = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && !(t.building instanceof Anomaly)) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestBuilding = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestBuilding != null) {
      target = closestBuilding;
      return;
    }
    
    target = null;
  }
  
  public void setDestination() {
    PVector p = getLocationOfObject();
    if(p == null) {
      destX = x;
      destY = y;
      return;
    }
    destX = p.x;
    destY = p.y;
  }
  
  public PVector getLocationOfObject() {
    if(target == null) {
      return null;
    }
    if(target instanceof Drone) {
      Drone d = (Drone) target;
      return new PVector(d.x + d.width/2, d.y + d.height/2);
    }
    
    if(target instanceof Building) {
      Building b = (Building) target;
      return new PVector(b.myTile.x * map.getTileWidth() + map.getTileWidth()/2, b.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Tile) {
      Tile t = (Tile) target;
      return new PVector(t.x * map.getTileWidth() + map.getTileWidth()/2, t.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Colony) {
      Colony c = (Colony) target;
      return new PVector(c.myTile.x * map.getTileWidth() + map.getTileWidth()/2, c.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    return null;
  }
}

public boolean paidOnLeviathanDeath = false;

// This function is used by Drones too, but we'll put it here because it has to go somewhere.
public void attack(Object o, float attackModifier) {
  if(o instanceof Leviathan) {
    float destructionPenalty = ((Leviathan)o).destructionPenalty;
    float overallModifier = attackModifier - destructionPenalty;
    if(random(1,100) + overallModifier > 50) {
      leviathans.remove(o);
      if(paidOnLeviathanDeath) {
        program.credits += 500;
      }
    }
  } else if(o instanceof Drone) {
    float destructionPenalty = ((Drone)o).destructionPenalty;
    float overallModifier = attackModifier - destructionPenalty;
    if(random(1,100) + overallModifier > 50) {
      drones.remove(o);
      program.credits += ((Drone)o).upkeep;
    }
  } else if(o instanceof Building) {
    float destructionPenalty = ((Building)o).destructionPenalty;
    float overallModifier = attackModifier - destructionPenalty;
    if(random(1,100) + overallModifier > 50) {
      ((Building)o).myTile.ClearBuilding();
    }
  } else if(o instanceof Tile) {
    float destructionPenalty = ((Tile)o).building.destructionPenalty;
    float overallModifier = attackModifier - destructionPenalty;
    if(random(1,100) + overallModifier > 50) {
      ((Tile)o).ClearBuilding();
    }
  }
}

public float globalCLeviathanMovement = 1/6f;

public class BurningLeviathan extends Leviathan {
  public float animationTime;
  public Object target;
  public float destX, destY;
  public BurningLeviathan(float x, float y) {
    super("TypeCLeviathan");
    damageModifier = 70;
    destructionPenalty = 60;
    this.x = x;
    this.y = y;
  }
  
  boolean blownThingsUpYet = false;
  public void update() {
    if(time.tickThisFrame) {
      animationTime = 0;
      blownThingsUpYet = false;
    }
    animationTime += time.currentTimeSpeed;
    if(target == null || time.tickThisFrame) {
      setTarget();
    }
    if(animationTime > 300 && !blownThingsUpYet) {
      blownThingsUpYet = true;
      
      SimpleDrone[] tempDrones = drones.toArray(new SimpleDrone[drones.size()]);
      for(Drone d : tempDrones) {
        if(pow(abs(x - d.x),2) + pow(abs(y - d.y),2) <= 150 * 150) {
          attack(d, damageModifier);
        }
      }
      for(int tileX = map.WorldPointToTileX(x); tileX < map.WorldPointToTileX(x) + 3; tileX++) {
        for(int tileY = map.WorldPointToTileY(y); tileY < map.WorldPointToTileY(y) + 3; tileY++) {
          if (x < 0 || x > map.width - 1 || y < 0 || y > map.height - 1) {
            continue;
          }
          if(map.getTile(tileX,tileY).GetBuilding() != null) {
            attack(map.getTile(tileX,tileY).GetBuilding(), damageModifier);
          }
        }
      }
    }
    setDestination();
    PVector direction = new PVector(destX - x, destY - y).setMag(globalCLeviathanMovement * time.currentTimeSpeed); // Figure out which direction we need to go, then make sure the magnitude is our movement speed.
    x += direction.x;
    y += direction.y;
    if (abs(x - destX) < globalCLeviathanMovement * time.currentTimeSpeed && abs(y - destY) < globalCLeviathanMovement * time.currentTimeSpeed) { // If we're close enough we will get there next frame, we might as well teleport. If we don't we'll overshoot and become jittery.
      x = destX;
      y = destY;
    }
  }
  public void draw() {
    pushStyle();
    ellipseMode(CENTER);
    if(animationTime < 300) {
      fill(255,0,0);
      stroke(255, 115, 0);
      strokeWeight(10);
    } else {
      fill(255,0,0, 255-((animationTime-300)/300 * 255));
      stroke(255, 115, 0, 255-((animationTime-300)/300 * 255));
      strokeWeight(10);
    }
    ellipse(x, y, animationTime/2, animationTime/2);
    image(image, x-width/2, y-height/2, width, height);
    popStyle();
  }
  
  public void setTarget() {
    if(colonyBuildingArtificialCity != null) {
      target = colonyBuildingArtificialCity;
      return;
    }
    Tile closestMine = null;
    float dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Mine) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestMine = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestMine != null) {
      target = closestMine;
      return;
    }
    
    if(drones.size() != 0) {
      CombatDrone closestCombatDrone = null;
      dist = 100000;
      for(Drone d : drones) {
        if(d instanceof CombatDrone) {
          if(abs(x - d.x) + abs(y - d.y) <= dist) {
            closestCombatDrone = (CombatDrone) d;
            dist = abs(x - d.x) + abs(y - d.y);
          }
        }
      }
      
      if(closestCombatDrone != null) {
        target = closestCombatDrone;
        return;
      }
    }
    
    // TODO lunar missiles check
    
    Tile closestColony = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && t.building instanceof Colony) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestColony = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestColony != null) {
      target = closestColony;
      return;
    }
    
    if(drones.size() != 0) {
      Drone closestDrone = null;
      dist = Float.MAX_VALUE;
      for(Drone d : drones) {
        if(pow(abs(x - d.x),2) + pow(abs(y - d.y),2) <= dist) {
          closestDrone = d;
          dist = pow(abs(x - d.x),2) + pow(abs(y - d.y),2);
        }
      }
      
      target = closestDrone;
      return;
    }
    
    Tile closestBuilding = null;
    dist = Float.MAX_VALUE;
    for(Tile t : map.tiles) {
      if(t.building != null && !(t.building instanceof Anomaly)) {
        if(pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2) <= dist) {
          closestBuilding = t;
          dist = pow(abs(x - t.x * map.getTileWidth()),2) + pow(abs(y - t.y * map.getTileHeight()),2);
        }
      }
    }
    
    if(closestBuilding != null) {
      target = closestBuilding;
      return;
    }
    
    target = null;
  }
  
  public void setDestination() {
    PVector p = getLocationOfObject();
    if(p == null) {
      destX = x;
      destY = y;
      return;
    }
    destX = p.x;
    destY = p.y;
  }
  
  public PVector getLocationOfObject() {
    if(target == null) {
      return null;
    }
    if(target instanceof Drone) {
      Drone d = (Drone) target;
      return new PVector(d.x + d.width/2, d.y + d.height/2);
    }
    
    if(target instanceof Building) {
      Building b = (Building) target;
      return new PVector(b.myTile.x * map.getTileWidth() + map.getTileWidth()/2, b.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Tile) {
      Tile t = (Tile) target;
      return new PVector(t.x * map.getTileWidth() + map.getTileWidth()/2, t.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(target instanceof Colony) {
      Colony c = (Colony) target;
      return new PVector(c.myTile.x * map.getTileWidth() + map.getTileWidth()/2, c.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    return null;
  }
}
