// This file contains the Map class, along with all the Tile-related classes

class Map {
  Tile[] tiles;

  public int getTileWidth() {
    return 100;
  }

  public int getTileHeight() {
    return 100;
  }

  public Tile getTile(int x, int y) {
    if (x < 0 || x > width - 1 || y < 0 || y > height - 1) {
      return null;
    }
    return tiles[y*width+x];
  }

  public void setTile(Tile t, int x, int y) {
    if (x < 0 || x > width - 1|| y < 0 || y > height - 1) {
      return;
    }
    tiles[y*width+x] = t;
  }

  int width;
  public int getMapWidth() {
    return width;
  }

  int height;
  public int getMapHeight() {
    return height;
  }

  int positionIntToX(int positionInt) {
    return round(positionInt / width);
  }

  int positionIntToY(int positionInt) {
    return positionInt % width;
  }
  
  int WorldPointToTileX(float x) {
    return floor(x / getTileWidth());
  }
  
  int WorldPointToTileY(float y) {
    return floor(y / getTileHeight()) + 1;
  }
  
  Tile WorldPointToTile(float x, float y) {
    return getTile(WorldPointToTileX(x),WorldPointToTileY(y));
  }

  public Map(int width, int height) {
    this.width = width;
    this.height = height;
    map = this;
    tiles = new Tile[width*height];

    OpenSimplexNoise noise = new OpenSimplexNoise();
    float seed = random(-100000f, 100000f);

    for (int i = 0; i < width*height; i++) {
      float value = map(noise.eval(round(i / width) / 5f, i % width / 5f, seed), -1f, 1f, 0f, 100f);
      //float value = pow(noise.eval(round(i / width) / 5f, i % width / 5f, seed),-1);
      if (value > 80f) {
        tiles[i] = new SimpleTile("MountainTile", i % width, round(i / width));
      } else if (value > 60f) {
        tiles[i] = new SimpleTile("HighlandsTile", i % width, round(i / width));
      } else if (value > 40f) {
        tiles[i] = new SimpleTile("FlatTile", i % width, round(i / width));
      } else if (value > 20f) {
        tiles[i] = new SimpleTile("CraterTile", i % width, round(i / width));
      } else {
        tiles[i] = new SimpleTile("HeavyCraterTile", i % width, round(i / width));
      }
    }
    
    generateMaria(int(random(2,4)), 100);
    
    generateScience(390);
  }
  
  void generateMaria(int iterations, int minimumMariaTiles) {
    int i = 0;
    int mariaTiles = 0;
    while(true) {
      mariaTiles += generateMariaTrail(int(random(0,width)),int(random(0,height)));
      i++;
      if(i > iterations && mariaTiles > minimumMariaTiles) {
        break;
      }
    }
  }
  
  int generateMariaTrail(int xOrigin, int yOrigin) {
    PVector direction = PVector.random2D(applet).setMag(getTileWidth());
    float currentX = xOrigin * getTileWidth(), currentY = yOrigin * getTileHeight();
    int mariaTiles = 0;
    while(true) {
      currentX += direction.x;
      currentY += direction.y;
      if(currentX < 0 || currentX > getMapWidth() * getTileWidth() || currentY < 0 || currentY > getMapHeight() * getTileHeight()) {
        break;
      }
      direction.add(PVector.random2D(applet).setMag(random(0f,getTileWidth()/2)));
      direction.setMag(getTileWidth());
      int currentIntX = WorldPointToTileX(currentX);
      int currentIntY = WorldPointToTileY(currentY);
      if(currentIntX < 0 || currentIntX > getMapWidth() || currentIntY < 0 || currentIntY + 1 > getMapHeight()) {
        break;
      }
      int currentArrayPosition = currentIntY * width + currentIntX;
      tiles[currentArrayPosition] = new SimpleTile("MariaTile", currentIntX, currentIntY);
      mariaTiles++;
    }
    return mariaTiles;
  }
  
  void generateScience(int requiredScience) { 
    int currentScience = 0;
    while(requiredScience > currentScience) {
      while(true) {
        int x = floor(random(0,width));
        int y = floor(random(0,height));
        if(getTile(x,y).GetBuilding() == null) {
          Anomaly a = new Anomaly(getTile(x,y));
          currentScience += a.scienceValue;
          getTile(x,y).SetBuilding(a);
          break;
        }
      }
    }
  }

  public void update() {
    for (int i = 0; i < tiles.length; i++) {
      tiles[i].update();
    }
  }

  public void draw() {
    for (int i = 0; i < tiles.length; i++) {
      tiles[i].draw();
    }
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].building != null) {
        tiles[i].building.draw();
      }
    }
    
    
  }
}

abstract class Tile {
  int x;
  public int getX() {
    return x;
  }

  int y;
  public int getY() {
    return y;
  }
  public Tile(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  Building building;
  public Building GetBuilding() {
    return building;
  }
  public void SetBuilding(Building b) {
    if(building != null) {
      building.onRemoved();
    }
    building = b;
    building.onAdded();
  }
  public void ClearBuilding() {
    if(building != null) {
      building.onRemoved();
    }
    building = null;
  }

  public abstract void update();

  public abstract void draw();
}

public class SimpleTile extends Tile {
  public String assetName;
  public String getImage() {
    return assetName;
  }
  public void setImage(String s) {
    assetName = s;
    sprite = assetManager.getAssetByName(assetName).getImageAsset();
  }

  public PImage sprite;


  public SimpleTile(String imageAsset, int x, int y) {
    this(imageAsset, x, y, null);
  }

  public SimpleTile(String imageAsset, int x, int y, Building b) {
    super(x, y);
    assetName = imageAsset;
    sprite = assetManager.getAssetByName(imageAsset).getImageAsset();
    building = b;
  }

  public void update() {
    if (building != null) {
      building.update();
      if (time.tickThisFrame && building != null) {
        building.updateTick();
      }
    }
    //placeholder
  }

  public void draw() {
    // frustum culling
    if (x * map.getTileWidth() > c.getRightX() || (x + 1) * map.getTileWidth() < c.getLeftX() || (y - 1) * map.getTileHeight() > c.getBottomY() || y * map.getTileHeight() < c.getTopY()) {
      return;
    }
    
    pushStyle();
    /*if(c.screenPointToWorldPointX(mouseX,mouseY) > x * map.getTileWidth() && c.screenPointToWorldPointX(mouseX,mouseY) < (x + 1) * map.getTileWidth() && c.screenPointToWorldPointY(mouseX,mouseY) > y * map.getTileWidth() && c.screenPointToWorldPointY(mouseX,mouseY) < (y + 1) * map.getTileWidth()) {
      tint(255,0,0);
    }*/
    
    image(sprite, x * map.getTileWidth(), (y * map.getTileHeight()) - sprite.height);
    popStyle();
  }
}
