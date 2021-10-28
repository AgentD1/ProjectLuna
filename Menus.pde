public class MainMenu {
  public TextButton play, rules, credits, exit, back, instructions;
  PFont font;
  
  boolean inRulesMenu = false, inCreditsMenu = false;
  
  PImage rulesImage, creditsImage, optionsImage;
  
  public MainMenu() { // float x, float y, String text, PFont font, float textSize, color fillColor, color strokeColor, color textColor, boolean stroke, OnPressedDelegate onPressed, int centeredHorizontal, int centeredVertical
    font = createFont("/Assets/Fonts/OpenSans-SemiBold.ttf", 20);
    OnPressedDelegate playd = new OnPressedDelegate() { public void onPressed() {
        inMainMenu = false;
        inCompanySelectScreen = true;
      } };
    play = new TextButton(width/2, 140, "Play Game", font, 24, color(74, 124, 232), color(0), color(0), true, playd, TextButton.CENTERED, TextButton.CENTEREDTOP);
    /*OnPressedDelegate optionsd = new OnPressedDelegate() { public void onPressed() {
        inMainMenu = false;
      } };
    options = new TextButton(width/2, 200, "Options", font, 24, color(74, 124, 232), color(0), color(0), true, null, TextButton.CENTERED, TextButton.CENTEREDTOP);*/
    OnPressedDelegate rulesd = new OnPressedDelegate() { public void onPressed() {
        inRulesMenu = true;
      } };
    rules = new TextButton(width/2, 200, "Rules", font, 24, color(74, 124, 232), color(0), color(0), true, rulesd, TextButton.CENTERED, TextButton.CENTEREDTOP);
    OnPressedDelegate creditsd = new OnPressedDelegate() { public void onPressed() {
        inCreditsMenu = true;
      } };
    credits = new TextButton(width/2, 260, "Credits", font, 24, color(74, 124, 232), color(0), color(0), true, creditsd, TextButton.CENTERED, TextButton.CENTEREDTOP);
    OnPressedDelegate exitd = new OnPressedDelegate() { public void onPressed() {
        exit();
      } };
    exit = new TextButton(width/2, 320, "Exit", font, 24, color(74, 124, 232), color(0), color(0), true, exitd, TextButton.CENTERED, TextButton.CENTEREDTOP);
    OnPressedDelegate backd = new OnPressedDelegate() { public void onPressed() {
        inMainMenu = true;
        inRulesMenu = false;
        inCreditsMenu = false;
      } };
    back = new TextButton(0, 0, "Back", font, 24, color(74, 124, 232), color(0), color(0), true, backd, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    OnPressedDelegate instructionsd = new OnPressedDelegate() { public void onPressed() {
        Input.Reset();
        link("https://sites.google.com/view/project-luna-tutorial/home");
      } };
    instructions = new TextButton(width/2, 380, "Instructions (Opens in a web browser)", font, 24, color(74, 124, 232), color(0), color(0), true, instructionsd, TextButton.CENTERED, TextButton.CENTEREDTOP);
    
    rulesImage = loadImage("/Assets/Menus/GameRules.png");
    creditsImage = loadImage("/Assets/Menus/Credits.png");
  }
  
  public void update() {
    if(inRulesMenu || inCreditsMenu) {
      back.update();
    } else {
      play.update();
      rules.update();
      credits.update();
      exit.update();
      instructions.update();
    }
  }
  
  public void draw() {
    pushStyle();
    if(inRulesMenu) {
      image(rulesImage,0,0,width,height);
      back.draw();
    } else if(inCreditsMenu) {
      image(creditsImage,0,0,width,height);
      back.draw();
    } else {
      background(0,0,255);
      fill(74, 134, 232);
      rect(10, 10, width - 20, 120);
      fill(0);
      textAlign(CENTER, TOP);
      textSize(90);
      text("PROJECT LUNA", width/2, 10);
      play.draw();
      rules.draw();
      credits.draw();
      exit.draw();
      instructions.draw();
    }
    popStyle();
  }
}

public class CompanySelectScreen {
  InvisibleButton cnsa, esa, nasa, spacex, isro, jaxa;
  PImage background;
  public CompanySelectScreen() {
    background = loadImage("/Assets/Menus/CompanySelectScreen.png");
    OnPressedDelegate cnsad = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "CNSALeader";
      } };
    cnsa = new InvisibleButton((1.5f/15f)*width, (2f/9f) * height, (6.5/15)*width, (2f/9f) * height, cnsad, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    OnPressedDelegate esad = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "ESALeader";
      } };
    esa = new InvisibleButton((1.5f/15f)*width, (4.5f/9f) * height, (6.5/15)*width, (2f/9f) * height, esad, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    OnPressedDelegate nasad = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "NASALeader";
      } };
    nasa = new InvisibleButton((1.5f/15f)*width, (7f/9f) * height, (6.5/15)*width, (2f/9f) * height, nasad, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    
    OnPressedDelegate spacexd = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "SpaceXLeader";
      } };
    spacex = new InvisibleButton((8.5f/15f)*width, (2f/9f) * height, (6.5/15)*width, (2f/9f) * height, spacexd, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    OnPressedDelegate isrod = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "ISROLeader";
      } };
    isro = new InvisibleButton((8.5f/15f)*width, (4.5f/9f) * height, (6.5/15)*width, (2f/9f) * height, isrod, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
    OnPressedDelegate jaxad = new OnPressedDelegate() { public void onPressed() {
        inCompanySelectScreen = false;
        program = new SpaceProgram();
        program.profile = new SpaceProgramProfile();
        program.profile.leaderImage = "JAXALeader";
      } };
    jaxa = new InvisibleButton((8.5f/15f)*width, (7f/9f) * height, (6.5/15)*width, (2f/9f) * height, jaxad, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
  }
  
  public void update() {
    cnsa.update();
    esa.update();
    nasa.update();
    spacex.update();
    isro.update();
    jaxa.update();
  }
  public void draw() {
    image(background, 0, 0, width, height);
  }
}

public class VictoryScreen {
  TextButton mainMenu, credits;
  PImage image;
  public VictoryScreen() {
    image = assetManager.getAssetByName("VictoryScreen").getImageAsset();
    OnPressedDelegate mainMenud = new OnPressedDelegate() { public void onPressed() {
        mm = new MainMenu();  
        inVictoryScreen = false;
        inMainMenu = true;
      } };
    mainMenu = new TextButton(0, height, "Main Menu", assetManager.getAssetByName("OpenSans").getFontAsset(), 24, color(142, 124, 195), color(0), color(0), true, mainMenud, TextButton.CENTEREDLEFT, TextButton.CENTEREDBOTTOM);
    OnPressedDelegate creditsd = new OnPressedDelegate() { public void onPressed() {
        mm = new MainMenu();  
        inMainMenu = true;
        inVictoryScreen = false;
        mm.inCreditsMenu = true;
      } };
    credits = new TextButton(width, height, "Credits", assetManager.getAssetByName("OpenSans").getFontAsset(), 24, color(142, 124, 195), color(0), color(0), true, creditsd, TextButton.CENTEREDRIGHT, TextButton.CENTEREDBOTTOM);
  }
  public void update() {
    mainMenu.update();
    credits.update();
  }
  public void draw() {
    image(image, 0, 0, width, height);
    mainMenu.draw();
    credits.draw();
  }
}
