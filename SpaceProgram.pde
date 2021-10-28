public class SpaceProgram { // This is where the data about the resources is held. 
  public SpaceProgramProfile profile;
  
  // Resources
  
  public float credits = 100f; // This is the credit total
  public float science = 0f; // This is the science total
  public float minerals = 100f; // This is the mineral total
  public float food = 100f; // This is the food total
  public float water = 100f; // This is the water total
  public float metal = 0f; // This is the metal total
  public float alloy = 0f; // This is the alloy total
  public float electronics = 0f; // This is the electronics total
  
  public float creditsPerTurn = 0f; // This is the amount of credits per turn 
  public float sciencePerTurn = 0f; // This is the amount of science per turn 
  public float mineralsPerTurn = 0f; // This is the amount of minerals per turn 
  public float foodPerTurn = 6f; // This is the amount of food per turn 
  public float waterPerTurn = 6f; // This is the amount of water per turn 
  public float metalPerTurn = 0f; // This is the amount of metal per turn 
  public float alloyPerTurn = 0f; // This is the amount of alloy per turn 
  public float electronicsPerTurn = 0f; // This is the amount of electronicss per turn 
  
  public void update() {
    if(time.tickThisFrame) { // This is a base generation of food and water caused by government funding.
      food += 6;
      water += 6;
    }
  }
}

public class SpaceProgramProfile { // This is the variables related to the company which the player plays
  public String leaderImage;
}
