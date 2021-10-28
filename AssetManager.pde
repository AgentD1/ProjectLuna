// This file contains all Asset and Asset Managing related functions and classes.

import java.util.*; // Now we can use HashMaps (Java dictionaries)

// This class manages all our assets (duh)
// It means we (hopefully) will NEVER load something twice. Very efficient.
// Here's a basic description of how it works: At the start it loads all the assets (images, fonts, sounds if we had sounds but we don't) and stores them
// We can now reference the assets without either loading them again or cluttering up the global scope with thousands of PImages
public class AssetManager {
  HashMap<String, Asset> assets;
  
  public AssetManager() {
    assets = new HashMap<String, Asset>(); // Assets will always be referred to by name, so the HashMap will link Strings to Assets
    
    // Here we create all our assets with the convenient function below.
    
    // Fonts
    createAsset("OpenSans", "/Assets/Fonts/OpenSans-SemiBold.ttf", "font"); // Our chosen font, the semi-bold version of open sans
    
    // Tiles (Components of the map)
    createAsset("FlatTile", "/Assets/Tiles/Flat.png", "image"); // This creates the flat tile asset, which allows factories, hydroponics, and science outposts to be build on it
    createAsset("CraterTile", "/Assets/Tiles/Crater.png", "image"); // This creates the crater tile asset, which allows a water extractor to be build on it
    createAsset("MountainTile", "/Assets/Tiles/Mountainous.png", "image"); // This creates the mountain tile asset, which allows for mines to be built on it (with +1 minerals)
    createAsset("HighlandsTile", "/Assets/Tiles/Highlands.png", "image"); // This creates the highlands tile asset, which allows for mines to be built on it
    createAsset("HeavyCraterTile", "/Assets/Tiles/HeavyCrater.png", "image"); // This creates the heavy crater tile asset, which allows a water extractor to be built on it (with +1 water)
    createAsset("MariaTile", "/Assets/Tiles/Maria.png", "image"); // This creates the maria tile asset, which allows for mines, factories, hydroponics and science outposts
    createAsset("FilledCraterTile", "/Assets/Tiles/filledcrater.png", "image"); // This creates the filled crater tile asset, which replaces the crater tile and has the properties of a flat tile
    createAsset("FilledHeavyCraterTile", "/Assets/Tiles/filledheavycrater.png", "image"); // This creates the filled heavy crater tile asset, which replaces the heavy crater and has the properties of a flat tile
    createAsset("DugCraterTile", "/Assets/Tiles/DugCrater.png", "image"); // This creates the dug crater tile asset, which replaces the flat tile and has the properties of a crater tile
    
    // Anomalies (Anomalies are scientific objects that can be scanned for science points, which in turn can be converted into technologies
    createAsset("AnomalyA", "/Assets/Buildings/AnomalyA.png", "image"); // This is the first anomaly
    createAsset("AnomalyB", "/Assets/Buildings/AnomalyB.png", "image"); // This is the second
    createAsset("AnomalyC", "/Assets/Buildings/AnomalyC.png", "image"); // This is the third
    createAsset("AnomalyD", "/Assets/Buildings/AnomalyD.png", "image"); // This is the fourth
    createAsset("AnomalyE", "/Assets/Buildings/AnomalyE.png", "image"); // This is the fifth
    
    // Buildings (The improvements that create resources for the player and are worked by the colonies)
    createAsset("MineBuilding", "/Assets/Buildings/Mine.png", "image"); // This creates the mine asset, which generates 3 minerals
    createAsset("HydroponicsBuilding", "/Assets/Buildings/hydroponics.png", "image"); // This creates the hydroponics facility asset, which generates 3 food
    createAsset("FactoryBuilding", "/Assets/Buildings/factory.png", "image"); // This creates the factory asset, which consume 3 minerals and produce two metals
    createAsset("WaterExtractorBuilding", "/Assets/Buildings/waterextractor.png", "image"); // This creates the water extractor asset, which produce 4 water
    createAsset("ScienceOutpostBuilding", "/Assets/Buildings/ScienceOutpost.png", "image"); // This creates the science outpost asset, which consumes 1 mineral and produces 1 science
    createAsset("AlloyFactoryBuilding", "/Assets/Buildings/alloyfactory.png", "image"); // This creates the alloy factory asset, which consumes 2 metal and produces 1 alloy
    createAsset("ElectronicsFactoryBuilding", "/Assets/Buildings/electronicsfactory.png", "image"); // This creates the electronics factory asset, which consumes 3 metal and produces 1 electronics
    
    createAsset("ColonyBuilding", "/Assets/Buildings/colony.png", "image"); // This creates the colony tile asset, the centre of the game
    
    // Companies
    createAsset("SpaceXLeader", "/Assets/Companies/spacexleader.png", "image");
    createAsset("CNSALeader", "/Assets/Companies/CNSAProfile.png", "image");
    createAsset("ESALeader", "/Assets/Companies/ESAProfile.png", "image");
    createAsset("NASALeader", "/Assets/Companies/NASAProfile.png", "image");
    createAsset("ISROLeader", "/Assets/Companies/ISROProfile.png", "image");
    createAsset("JAXALeader", "/Assets/Companies/JAXAProfile.png", "image");
    
    // Button Images
    createAsset("PauseButton", "/Assets/Buttons/Pause.png", "image"); // This creates the button which needs to be pressed in order to pause the game
    createAsset("HalfSpeedButton", "/Assets/Buttons/HalfSpeed.png", "image"); // This creates the button which needs to be pressed in order to reach half speed
    createAsset("FullSpeedButton", "/Assets/Buttons/FullSpeed.png", "image"); // This creates the button which needs to be pressed in order to reach full speed
    createAsset("DoubleSpeedButton", "/Assets/Buttons/DoubleSpeed.png", "image"); // This creates the button which needs to be pressed in order to reach double speed
    createAsset("CheckedBoxButton", "/Assets/Buttons/checkedcheckbox.png", "image"); // This creates the checked button asset
    createAsset("UncheckedBoxButton", "/Assets/Buttons/emptycheckbox.png", "image"); // This creates unchecked button asset
    createAsset("AnomalyResearchButton", "/Assets/Buttons/AnomalyResearchIcon.png", "image"); // This creates the button which needs to be pressed in order to research an anomaly
    createAsset("DeconstructIcon", "/Assets/Buttons/DeconstructIcon.png", "image"); // This creates the button which needs to be pressed in order to deconstruct or cancel a building
    
    // Other UI Images
    createAsset("FocusesColonyUI", "/Assets/Buttons/colonyfocus.png", "image"); // This creates the colony focus button, which allows a colony to focus a certain resource
    createAsset("VictoryScreen", "/Assets/Menus/VictoryScreen.png", "image"); // This creates the colony focus button, which allows a colony to focus a certain resource
   
    // Market
    createAsset("AlloyMarketIcon", "/Assets/Market/AlloyMarketIcon.png", "image");
    createAsset("ElectronicsMarketIcon", "/Assets/Market/ElectronicsMarketIcon.png", "image");
    createAsset("MetalMarketIcon", "/Assets/Market/MetalMarketIcon.png", "image");
    createAsset("MineralMarketIcon", "/Assets/Market/MineralMarketIcon.png", "image");
    createAsset("ScienceMarketIcon", "/Assets/Market/ScienceMarketIcon.png", "image");
    createAsset("WaterMarketIcon", "/Assets/Market/WaterMarketIcon.png", "image");
    createAsset("FoodMarketIcon", "/Assets/Market/FoodMarketIcon.png", "image");
    
    // Drones
    createAsset("ConstructionDrone", "/Assets/Drones/constructiondrone.png", "image"); // This the construction drone image, the drone which makes buildings
    createAsset("FillerDrone", "/Assets/Drones/fillerdrone.png", "image"); // This creates the filler drone image, the drone who digs and fills craters
    createAsset("ColonyDrone", "/Assets/Drones/colonydrone.png", "image"); // This creates the colony drone image, the drone which creates colonies
    createAsset("ScienceDrone", "/Assets/Drones/sciencedrone.png", "image"); // This creates the science drone, the drone which scans anomalies and generates research
    createAsset("CombatDrone", "/Assets/Drones/combatdrone.png", "image");
    createAsset("ArtilleryDrone", "/Assets/Drones/artillerydrone.png", "image");
    createAsset("LunarMissile", "/Assets/Drones/lunarmissile.png", "image");
    
    // Leviathans
    createAsset("TypeALeviathan", "/Assets/Leviathans/TypeALeviathan.png", "image");
    createAsset("TypeBLeviathan", "/Assets/Leviathans/TypeBLeviathan.png", "image");
    createAsset("TypeCLeviathan", "/Assets/Leviathans/TypeCLeviathan.png", "image");
    
    // Techs (The following are the different technology icons of the game) 
    createAsset("IndependantDronesTech", "/Assets/Tech/1.png", "image");
    createAsset("HydroponicsFarmsTech", "/Assets/Tech/2.png", "image");
    createAsset("NewEconomyTech", "/Assets/Tech/3.png", "image");
    createAsset("SpaceTierFactoryTech", "/Assets/Tech/4.png", "image");
    createAsset("EfficientAgrifarmsTech", "/Assets/Tech/5.png", "image");
    createAsset("FastMineralHarvestingTech", "/Assets/Tech/6.png", "image");
    createAsset("RapidTreadsTech", "/Assets/Tech/7.png", "image");
    createAsset("ColonistPropagandaTech", "/Assets/Tech/8.png", "image");
    createAsset("SimpleTerraformingTech", "/Assets/Tech/9.png", "image");
    createAsset("DroneWorkUpgradeTech", "/Assets/Tech/10.png", "image");
    createAsset("ColonistUpliftingTech", "/Assets/Tech/11.png", "image");
    createAsset("ConstantResearchTech", "/Assets/Tech/12.png", "image");
    createAsset("AlloyManufacturing", "/Assets/Tech/13.png", "image");
    createAsset("MoistureEfficiencyTech", "/Assets/Tech/14.png", "image");
    createAsset("AdvancedEngineringTech", "/Assets/Tech/15.png", "image");
    createAsset("AntiGravBuildingsTech", "/Assets/Tech/16.png", "image");
    createAsset("PlasmaBatteriesTech", "/Assets/Tech/17.png", "image");
    createAsset("DeepDrillingTech", "/Assets/Tech/18.png", "image");
    createAsset("ElectronicManufacturingTech", "/Assets/Tech/19.png", "image");
    createAsset("BioEngineeringTech", "/Assets/Tech/20.png", "image");
    createAsset("CombatDronesTech", "/Assets/Tech/21.png", "image");
    createAsset("SelfSufficientDronesTech", "/Assets/Tech/22.png", "image");
    createAsset("AlloyElectronicBoostTech", "/Assets/Tech/23.png", "image");
    createAsset("DefenseFundingTech", "/Assets/Tech/24.png", "image");
    createAsset("BringFactoryWorkersTech", "/Assets/Tech/25.png", "image");
    createAsset("ImportBotanistsTech", "/Assets/Tech/26.png", "image");
    createAsset("RemoteMinerBotsTech", "/Assets/Tech/28.png", "image");
    createAsset("DedicatedResearchLabsTech", "/Assets/Tech/27.png", "image");
    createAsset("CloningTech", "/Assets/Tech/29.png", "image");
    createAsset("LunarWarheadsTech", "/Assets/Tech/30.png", "image");
    createAsset("IndependentColonyTech", "/Assets/Tech/31.png", "image");
    createAsset("PsionicDevelopmentTech", "/Assets/Tech/32.png", "image");
    createAsset("OrbitalArtilleryTech", "/Assets/Tech/33.png", "image");
    createAsset("ArtificalCityTech", "/Assets/Tech/34.png", "image");
  }
  
  // We don't want to make our HashMap public incase we break things. We never want to unload anything just in case something still uses it. Below are helper functions to provide specific public functionality to manipulate the HashMap.
  
  public Asset getAssetByName(String name) { // Get an asset by name
    return assets.get(name);
  }
  
  public void addAsset(Asset asset) { // Add an already created asset to the HashMap (I don't think we ever use this outside of AssetManager, but what's the worst that could happen)
    assets.put(asset.name, asset);
  }
  
  void createAsset(String name, String path, String type) { // This function is used so we don't have to create and add every asset seperately in the constructor.
    Asset a = new Asset(name, path, type);
    addAsset(a);
  }
}

// This class loads and acts as a container for an asset loaded from disk.
public class Asset {
  Object asset; // Assets can be several things that have basically nothing to do with each other. Object is the only type that can hold this. (PImage, PFont are completely unrelated)
  public String name;
  
  public Asset(String name, String path, String type) { // The constructor will do a different thing depending on what type is requested
    type = type.toLowerCase();
    this.name = name;
    if(type.equals("pimage") || type.equals("image")) { // It would have been a lot nice to be able to supply a Type variable to the constructor so we could do type == PImage, but in java Types are not types. This is kinda hard to word.
                                                        // In C#, my usual language, a Type is a type that can be stored and compared. Check it out if you care: https://docs.microsoft.com/en-us/dotnet/api/system.type?view=netframework-4.8
      PImage image = loadImage(path); // Load the image how you would usually load an image
      if(image == null) { // If it's null, lets let us know that before we start trying to use it in the code
        println("Asset " + name + " Image path " + path + " doesn't work");
      }
      asset = image;
    }
    if(type.equals("font")) { // Same as above but with loading a font instead of an image
      PFont font = createFont(path, 24);
      if(font == null) {
        println("Asset " + name + " Font path " + path + " doesn't work");
      }
      asset = font;
    }
  }
  
  public PImage getImageAsset() { // These functions save us from doing (PImage) ourAsset.asset or whatever else depending on the type. asset is private anyway.
    return (PImage) asset;
  }
  
  public PFont getFontAsset() { // This does the above but if the asset is a font. If we had more time and I was smarter, we could have made this work better. Right now, if you do getFontAsset on an image asset, it will throw a ClassCastException. Fun.
    return (PFont) asset;
  }
}
