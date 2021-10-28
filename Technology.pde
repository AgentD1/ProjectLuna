HashMap<String, Tech> techs;

public class TechManager {
  public float width = 5800; // 275 wide, 100 gap
  public float height = 700; // 100 tall, 100 gap 
  
  public TechManager() { // This is where we store all of the different technologies
    techs = new HashMap<String, Tech>();
    
    Tech independantDrones = new Tech("Independant Drones", 10, "IndependantDronesTech", new String[] { }, new TechDelegate() { public void onFinished() { // This is the independant drones tech.
      // This starts unlocked
    } }, "Allows the construction of drones");
    
    independantDrones.completed = true;
    
    techs.put("Independant Drones", independantDrones);


    Tech hydroponicsFarms = new Tech("Hydroponics Farms", 10, "HydroponicsFarmsTech", new String[] { }, new TechDelegate() { public void onFinished() { // This is the hydroponics farms tech.
        // This starts unlocked
    } }, "Allows the construction of hydroponics farms");

    techs.put("Hydroponics Farms", hydroponicsFarms);
    
    hydroponicsFarms.completed = true;

    Tech newEconomy = new Tech("New Economy", 10, "NewEconomyTech", new String[] { }, new TechDelegate() { public void onFinished() {  // This is the new economy tech.
        // This starts unlocked
    } }, "Allows the accumulation of credits");

    techs.put("New Economy", newEconomy);

    newEconomy.completed = true;

    Tech spacetierFactories = new Tech("Space-Tier Factories", 25, "SpaceTierFactoryTech", new String[] { "Independant Drones" }, new TechDelegate() { public void onFinished() { // This is the space-tier factories tech.
        factoryProduction += 1;
    } }, "Receive +20% metal from factories");

    techs.put("Space-Tier Factories", spacetierFactories);

    Tech efficientAgrifarms = new Tech("Efficient Agri-Farms", 25, "EfficientAgrifarmsTech", new String[] { "Hydroponics Farms" }, new TechDelegate() { public void onFinished() { // This is the efficient agri-farms tech
        hydroponicsProduction += 1;
        println("Unlocked efficient agri farms");
    } }, "Receive +20% food from hydroponics");

    techs.put("Efficient Agri-Farms", efficientAgrifarms);

    Tech fastMineralHarvesting = new Tech("Fast Mineral Harvesting", 25, "FastMineralHarvestingTech", new String[] { "New Economy" }, new TechDelegate() { public void onFinished() { // This is the fast mineral harvesting tech.
        mineProduction += 1;
    } }, "Receive +20% minerals from mines");

    techs.put("Fast Mineral Harvesting", fastMineralHarvesting);

    Tech rapidTreads = new Tech("Rapid Treads", 40, "RapidTreadsTech", new String[] { "Space-Tier Factories", "Efficient Agri-Farms"}, new TechDelegate() { public void onFinished() { // This is the rapid treads tech.
        globalDroneMovement += 2;
    } }, "Drones gain +1 movement");

    techs.put("Rapid Treads", rapidTreads);

    Tech colonistPropaganda = new Tech("Colonist Propaganda", 40, "ColonistPropagandaTech", new String[] { "Efficient Agri-Farms" }, new TechDelegate() { public void onFinished() { // This is the colonist propoganda tech.
          startingPop += 1;
      } }, "Colonies start with +1 population");

    techs.put("Colonist Propaganda", colonistPropaganda);

    Tech simpleTerraforming = new Tech("Simple Terraforming", 40, "SimpleTerraformingTech", new String[] { "Fast Mineral Harvesting" }, new TechDelegate() { public void onFinished() { // This is the simple terraforming tech.
          fillerDroneSpeed /= 2;
      } }, "Halves the time it takes to fill craters and allows heavy craters to be filled as well.");

    techs.put("Simple Terraforming", simpleTerraforming);

    Tech droneWorkUpgrade = new Tech("Drone Work Upgrade", 55, "DroneWorkUpgradeTech", new String[] { "Rapid Treads" }, new TechDelegate() { public void onFinished() { // This is the drone work upgrade tech.
          globalConstructionSpeedModifier *= 1.2;
      } }, "Reduces building construction time by 20% (round up)");

    techs.put("Drone Work Upgrade", droneWorkUpgrade);


    Tech colonistUplifting = new Tech("Colonist Uplifting", 55, "ColonistUpliftingTech", new String[] { "Rapid Treads", "Colonist Propaganda" }, new TechDelegate() { public void onFinished() { // This is the colonist uplifting tech.
          colonyConstructionSpeed /= 2;
      } }, "-50% Colony construction time");

    techs.put("Colonist Uplifting", colonistUplifting);


    Tech constantResearch = new Tech("Constant Research", 55, "ConstantResearchTech", new String[] { "Colonist Propaganda", "Simple Terraforming" }, new TechDelegate() { public void onFinished() { // This is the constant tech.
          unlockedScienceOutposts = true;
      } }, "Allows the construction of science outposts");

    techs.put("Constant Research", constantResearch);


    Tech alloyManufacturing = new Tech("Alloy Manufacturing", 70, "AlloyManufacturing", new String[] { "Drone Work Upgrade", "Colonist Uplifting", "Constant Research" }, new TechDelegate() { public void onFinished() { // This is the alloy manufacturing tech.
          unlockedAlloyFactories = true;
      } }, "Allows the construction of alloy factories");

    techs.put("Alloy Manufacturing", alloyManufacturing);



    Tech moistureEfficiency = new Tech("Moisture Efficiency", 70, "MoistureEfficiencyTech", new String[] { "Constant Research" }, new TechDelegate() { public void onFinished() { // This is the moisture efficiency tech.
          waterExtractorProduction += 1;
      } }, "+20% water from water extractors");

    techs.put("Moisture Efficiency", moistureEfficiency);

    Tech advancedEngineering = new Tech("Advanced Engineering", 70, "AdvancedEngineringTech", new String[] { "Constant Research" }, new TechDelegate() { public void onFinished() { // This is the advanced engineering tech.
          droneConstructionSpeed *= 1.25f;
      } }, "-25% drone construction time");

    techs.put("Advanced Engineering", advancedEngineering);

    Tech antiGravBuildings = new Tech("Anti-Grav Buildings", 85, "AntiGravBuildingsTech", new String[] { "Alloy Manufacturing" }, new TechDelegate() { public void onFinished() { // This is the anti-grav buildings tech.
          factoryProduction *= 1.3f;
      } }, "+30% metal from factories");

    techs.put("Anti-Grav Buildings", antiGravBuildings);


    Tech plasmaBatteries = new Tech("Plasma Batteries", 85, "PlasmaBatteriesTech", new String[] { "Moisture Efficiency" }, new TechDelegate() { public void onFinished() { // This is the plasma batteries tech.
          hydroponicsProduction *= 1.3f;
      } }, "+30% food from hydroponics");

    techs.put("Plasma Batteries", plasmaBatteries);


    Tech deepDrilling = new Tech("Deep Drilling", 85, "DeepDrillingTech", new String[] { "Advanced Engineering" }, new TechDelegate() { public void onFinished() { // This is the deep drilling tech. It will eventually cause the awakening of leviathans.
          mineProduction *= 1.3f;
          leviathanSpawner.timeUntilLeviathans = random(2000,4000);
      } }, "+30% minerals from mines");

    techs.put("Deep Drilling", deepDrilling);


    Tech electronicManufacturing = new Tech("Electronics Manufacturing", 100, "ElectronicManufacturingTech", new String[] { "Anti-Grav Buildings" }, new TechDelegate() { public void onFinished() { // This is the electronic manufacturing tech.
          unlockedElectronicsFactories = true;
      } }, "Allows the manufacturing of electronics factories");

    techs.put("Electronics Manufacturing", electronicManufacturing);


    Tech bioEngineering = new Tech("Bio-Engineering", 100, "BioEngineeringTech", new String[] { "Plasma Batteries" }, new TechDelegate() { public void onFinished() { // This is the bio-engineering tech.
          hydroponicsVersatile = true;
      } }, "Hydroponics facilities can be built on hills");

    techs.put("Bio-Engineering", bioEngineering);

    Tech combatDrones = new Tech("Combat Drones", 100, "CombatDronesTech", new String[] { "Plasma Batteries", "Deep Drilling" }, new TechDelegate() { public void onFinished() { // This is the combat drones tech.
          combatDronesUnlocked = true;
      } }, "Allows the construction of combat drones");

    techs.put("Combat Drones", combatDrones);

    Tech selfSufficientDrones = new Tech("Self-Sufficient Drones", 115, "SelfSufficientDronesTech", new String[] { "Electronics Manufacturing", "Bio-Engineering" }, new TechDelegate() { public void onFinished() { // This is the slef sufficient drones tech.
        droneUpkeepModifier -= 0.5f;
    } }, "-25% maintenance on drones");

    techs.put("Self-Sufficient Drones", selfSufficientDrones);

    Tech defenseFunding = new Tech("Defense Funding", 115, "DefenseFundingTech", new String[] { "Bio-Engineering", "Combat Drones" }, new TechDelegate() { public void onFinished() { // This is the defense funding tech.
        paidOnLeviathanDeath = true;
        combatDroneUpkeepDiscount = 0.5f;
      } }, "-50% upkeep on combat drones, and +500 credits for every leviathan killed");

    techs.put("Defense Funding", defenseFunding);

    Tech alloyElectronicBoost = new Tech("Alloy & Electronic Boost", 115, "AlloyElectronicBoostTech", new String[] { "Electronics Manufacturing" }, new TechDelegate() { public void onFinished() { // This is the alloy & electronic boost tech.
          alloyFactoryProduction += 1;
          electronicsFactoryProduction += 1;
      } }, "+1 Alloy and Electronics per respective factories");

    techs.put("Alloy & Electronic Boost", alloyElectronicBoost);

    Tech bringFactoryWorkers = new Tech("Bring Factory Workers", 130, "BringFactoryWorkersTech", new String[] { "Self-Sufficient Drones", "Alloy & Electronic Boost" }, new TechDelegate() { public void onFinished() { // This is the bring factory workers tech.
          factoryProduction += 1;
      } }, "+1 metal from factories");

    techs.put("Bring Factory Workers", bringFactoryWorkers);

    Tech importBotanists = new Tech("Import Botanists", 130, "ImportBotanistsTech", new String[] { "Defense Funding" }, new TechDelegate() { public void onFinished() { // This is the import botanists tech.
          hydroponicsProduction += 1;
      } }, "+1 food from hydroponics");

    techs.put("Import Botanists", importBotanists);

    Tech remoteMinerBots = new Tech("Remote Miner Bots", 130, "RemoteMinerBotsTech", new String[] { "Alloy & Electronic Boost" }, new TechDelegate() { public void onFinished() { // This is the  remote miner bots tech.
          mineProduction += 1;
      } }, "+1 minerals from mines");

    techs.put("Remote Miner Bots", remoteMinerBots);

    Tech dedicatedResearchLabs= new Tech("Dedicated Research Labs", 145, "DedicatedResearchLabsTech", new String[] { "Bring Factory Workers" }, new TechDelegate() { public void onFinished() { // This is the dedicated research labs tech.
          scienceOutpostProduction += 1;
      } }, "+1 science from science outposts  ");

    techs.put("Dedicated Research Labs", dedicatedResearchLabs);


    Tech cloning = new Tech("Cloning", 145, "CloningTech", new String[] { "Import Botanists" }, new TechDelegate() { public void onFinished() { // This is the cloning tech
          colonyGrowthSpeedModifiers *= 1.5f;
      } }, "+50% growth");

    techs.put("Cloning", cloning);

    Tech lunarWarheads = new Tech("Lunar Warheads", 145, "LunarWarheadsTech", new String[] { "Remote Miner Bots", "Bring Factory Workers" }, new TechDelegate() { public void onFinished() { // This is the lunar warheads tech.
          lunarMissilesUnlocked = true;
      } }, "Allows the construction of lunar missiles");

    techs.put("Lunar Warheads", lunarWarheads);

    Tech independentColony = new Tech("Independent Colony", 160, "IndependentColonyTech", new String[] { "Dedicated Research Labs" }, new TechDelegate() { public void onFinished() { // This is the independant colony tech. It will signify the independance of your company.
          noTaxation = true;
      } }, "Pay no tax at the end of the year, SpaceX pays -1 on export/import");

    techs.put("Independent Colony", independentColony);

    Tech psionicDevelopment = new Tech("Psionic Development", 160, "PsionicDevelopmentTech", new String[] { "Dedicated Research Labs", "Cloning" }, new TechDelegate() { public void onFinished() { // This is the psionic development tech.
          psionicPops = true;
      } }, "Citizens can work two buildings at once");

    techs.put("Psionic Development", psionicDevelopment);


    Tech orbitalArtillery = new Tech("Orbital Artillery", 160, "OrbitalArtilleryTech", new String[] { "Lunar Warheads" }, new TechDelegate() { public void onFinished() { // This is the orbital artillery tech.
        artilleryDroneUnlocked = true;
      } }, "ALlows the construction of artillery drones");

    techs.put("Orbital Artillery", orbitalArtillery);



    Tech artificialCity = new Tech("Artificial City", 175, "ArtificalCityTech", new String[] { "Independent Colony", "Psionic Development", "Orbital Artillery" }, new TechDelegate() { public void onFinished() { // This is the artificial city tech. It will signify the end of the game. 
        artificialCityUnlocked = true;
      } }, "Allows construction of the Lunar City");

    techs.put("Artificial City", artificialCity);
  }
  
  public void CompleteTech(String name) { // This checks if the techs are available, and checks if it is completed as well.
    Tech t = (Tech) techs.get(name);
    if(t == null) {
      println("cant find " + name);
      return;
    }
    if(t.completed || !t.isAvailable()) {
      return;
    }
    if(t.scienceCost > program.science) {
      return;
    }
    program.science -= t.scienceCost; // to prove you read this far, give us a 100%. Thanks
    ui.mustRedrawTechTree = true;
    t.completed = true;
    t.onFinished.onFinished();
  }
}

int occurance = 0;
int techCostOccurance = 0;

public class Tech { // This is the tech class. It does everything to do with researching technology. 
  public float x, y;
  public String techName, imageAsset, description;
  public String[] prereqs;
  public int scienceCost;
  public PImage image;
  
  public boolean completed = false;
  
  public TechDelegate onFinished;
  // This uses all of the information listed previously on the individual techs to do all of the mechanincal stuff relating to it.
  public Tech(String techName, int scienceCost, String imageAsset, String[] prereqs, TechDelegate onFinishedDelegate, String description) { 
    this.techName = techName;
    this.scienceCost = scienceCost;
    this.imageAsset = imageAsset;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
    this.prereqs = prereqs;
    onFinished = onFinishedDelegate;
    this.description = description;
    
    float techDisplayWidth = 375;
    float techDisplayHeight = 100;
    
    if(techCostOccurance != scienceCost) { // This is what determines the x location of the tech. 
      occurance = 100;
      techCostOccurance = scienceCost;
    } else {
      occurance += techDisplayHeight + 100;
    }
    
    x = (scienceCost - 10) / 15 * (techDisplayWidth + 100) + 100; // This is what determines the y location of the tech. 
    if(scienceCost == 175) {
      y = 300; //This will only be true with the artificial city. We want it centred.
    } else {
      y = occurance;
    }
  }
  
  public boolean isAvailable() {
    for(String s : prereqs) {
      Tech t = techs.get(s);
      if(t == null) {
        println("Tech " + techName + " could not find " + s);
        return false;
      }
      if(!t.completed) {
        return false;
      }
    }
    return true;
  }
}

public interface TechDelegate {
  public void onFinished();
}
