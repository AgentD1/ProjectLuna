// This file contains all the classes and functions related to notifications

public class NotificationManager { // This is the class which stores information for notifications
  public ArrayList<Notification> notifications = new ArrayList<Notification>();
  public NotificationManager() {
    
  }
  
  public void CreateBuildingCompletedNotification(Building b) { // This is the function for the completed building notification
    Notification n = new Notification(((SimpleBuilding)b).imageAsset);
    n.title = b.name + " completed!";
    n.description = "Construction drone has completed " + b.name;
    n.objectToCenterOn = b;
    notifications.add(n);
  }
  
  public void CreateAnomalyResearchedNotification(ScienceDrone d, float science) { // This is the function for the anomaly researched notification
    Notification n = new Notification(d.imageAsset);
    n.title = "Anomaly Completed!";
    n.description = "You gained " + science + " science";
    n.objectToCenterOn = d;
    notifications.add(n);
  }
  
  public void CreateDroneIdleNotifications(Drone d) { // This is the function for the idle drone notification
    Notification n = new Notification(((SimpleDrone)d).imageAsset);
    n.title = "Drone is Idle";
    n.description = "Drone has finished work and is ready for new orders";
    n.objectToCenterOn = d;
    notifications.add(n);
  }
  
  public void CreateColonyIdleNotifications(Colony c) { // This is the function for the completed colony notification
    Notification n = new Notification("ColonyBuilding");
    n.title = "Colony Focus Complete";
    n.description = "Colony has completed its focus and is ready for another";
    n.objectToCenterOn = c;
    notifications.add(n);
  }
  
  public void CreateLeviathanSpawnNotifications(Leviathan l) { // This is the function for the completed colony notification
    Notification n = new Notification(l.imageAsset);
    n.title = "A new leviathan has spawned!";
    n.description = "Look out!";
    n.objectToCenterOn = l;
    notifications.add(n);
  }
  
  public void CreateWarningWarningNotifications() {
    Notification n = new Notification(program.profile.leaderImage);
    n.title = "You aren't making a profit";
    n.description = "The end of the month is soon and you need " + (market.requiredCreditsThisTurn - program.credits) + " more credits!";
    notifications.add(n);
  }
  
  public void CreateGotAWarningNotifications() {
    Notification n = new Notification(program.profile.leaderImage);
    n.title = "You got a warning!";
    n.description = "If you fail to make a profit " + (3 - market.warnings) + " more times, you will be shut down!";
    notifications.add(n);
  }
}

public class Notification { // This is the class which manages notifications
  public PImage image; // This is where the images for the notifications are accessed
  public String imageAsset;
  public String title, description;
  
  public Object objectToCenterOn;
  
  public Notification(String imageAsset) {
    this.imageAsset = imageAsset;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
  }
  
  public void center() {
    if(objectToCenterOn == null) {
      return;
    }
    
    PVector location = centerOn(); // This is the vector which centres the camera on where the ojbect is taking place. 
    if(location != null) {
      c.beginTransformation();
      c.x = location.x - width / 2;
      c.y = location.y - height / 2;
      c.endTransformation();
      return;
    }
    if(objectToCenterOn instanceof Tech) { // This is when the object which is to be centred on is the tech tree.
      ui.displayTechTree = true; // Since we can't centre on the tech tree on the map, we instead open the tech tree. 
    }
  }
  
  PVector centerOn() {
    if(objectToCenterOn == null) {
      return null;
    }
    if(objectToCenterOn instanceof Drone) { // This is when it centres on the drone
      Drone d = (Drone) objectToCenterOn;
      return new PVector(d.x + d.width/2, d.y + d.height/2);
    }
    
    if(objectToCenterOn instanceof Building) {  // This is when it centres on a building
      Building b = (Building) objectToCenterOn;
      return new PVector(b.myTile.x * map.getTileWidth() + map.getTileWidth()/2, b.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(objectToCenterOn instanceof Tile) { // This is when it centres on a tile
      Tile t = (Tile) objectToCenterOn;
      return new PVector(t.x * map.getTileWidth() + map.getTileWidth()/2, t.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(objectToCenterOn instanceof Colony) { // This is where it centres on a colony
      Colony c = (Colony) objectToCenterOn;
      return new PVector(c.myTile.x * map.getTileWidth() + map.getTileWidth()/2, c.myTile.y * map.getTileHeight() - map.getTileHeight()/2);
    }
    
    if(objectToCenterOn instanceof Leviathan) { // This is where it centres on a colony
      Leviathan l = (Leviathan) objectToCenterOn;
      return new PVector(l.x, l.y);
    }
    
    return null;
  }
}
