public boolean noTaxation = false; //<>//

public class UIManager {
  float width; // These values are used to easily store the screen's width and height.
  float height;// This can be used to determine if the screen has changed size

  float lastTimeSpeed; // Keeping hold of this value means we can switch which time button to highlight if the user uses 1,2,3, and space to change the time speed

  boolean debugDisplay = false;

  public boolean displayTechTree = false;
  public boolean mustRedrawTechTree = false;

  Tile lastDroneTile;
  Building lastDroneBuilding;

  // The following variables are used to store various values that would need to be calculated every frame otherwise
  // That speeds things up nicely. Nice.

  float topBarHeight;
  float eachBarSection;
  float textSize;
  float timeBarDistanceFromLeft;

  ImageButton pauseButton;
  ImageButton fullSpeedButton;
  ImageButton halfSpeedButton;
  ImageButton doubleSpeedButton;

  int availableDroneActions;
  ImageButton[] droneActionImageButtons;

  float droneActionHeight;
  float droneActionPadding;
  float droneActionPanelWidth;
  float droneActionPanelHeight;
  float droneActionPanelY;
  float droneActionTextHeight;

  CheckBox colonyUIIgnoreNegativesCheckbox;


  float colonyUITabHeight;
  float colonyUITabY;
  float colonyUITabWidth;
  float colonyUITabX;
  float colonyUIIgnoreNegativesY;
  float colonyUIIgnoreNegativesHeight;
  float colonyUIIgnoreNegativesFontSize;
  float colonyUINameFontSize;

  InvisibleButton focusMineralButton, focusFoodButton, focusWaterButton, focusAlloyButton, focusElectronicsButton, focusScienceButton, focusMetalButton, colonyFocusButton;

  TextButton marketButton, techTreeButton;

  PGraphics techTreePG;
  
  boolean setupCompaniesYet = false;

  public void update() {
    if(!setupCompaniesYet) {
      if(program.profile.leaderImage == "CNSALeader") {
        factoryProduction += 2;
      } else if(program.profile.leaderImage == "ESALeader") {
        anomalyModifier += 2;
      } else if(program.profile.leaderImage == "NASALeader") {
        scienceOutpostConsumption -= 0.5f;
        alloyFactoryConsumption -= 0.5f;
        factoryConsumption -= 0.5f;
        electronicsFactoryConsumption -= 0.5f;
      } else if(program.profile.leaderImage == "ISROLeader") {
        startingPop += 1;
      } else if(program.profile.leaderImage == "JAXALeader") {
        globalDroneMovement += 1/6f;
      }
      setupCompaniesYet = true;
    }
    if (width == 0 || width != c.getWindowWidth() || height != c.getWindowHeight()) { // Make sure all our values are up to date
      width = c.getWindowWidth();
      height = c.getWindowHeight();
      recalculateValues();
    }
    
    if(marketButton == null) {
      OnPressedDelegate marketd = new OnPressedDelegate() { public void onPressed() {
        displayMarket = !displayMarket;
      } };
      marketButton = new TextButton(0, topBarHeight, "Show/Hide Market", assetManager.getAssetByName("OpenSans").getFontAsset(), 24, color(255), color(0), color(0), true, marketd, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);
      OnPressedDelegate techTreed = new OnPressedDelegate() { public void onPressed() {
        displayTechTree = !displayTechTree;
      } };
      techTreeButton = new TextButton(0, topBarHeight + 44, "Show/Hide Tech Tree", assetManager.getAssetByName("OpenSans").getFontAsset(), 24, color(255), color(0), color(0), true, techTreed, TextButton.CENTEREDLEFT, TextButton.CENTEREDTOP);

    }

    width = c.getWindowWidth();
    height = c.getWindowHeight();

    if (time.tickThisFrame) {
      ui.mustRedrawTechTree = true;
    }

    if (Input.GetKeyDown(90)) {
      displayTechTree = !displayTechTree;
    }

    // Update all the buttons

    pauseButton.update();
    halfSpeedButton.update();
    fullSpeedButton.update();
    doubleSpeedButton.update();

    if (selectedColony != null) {
      colonyUIIgnoreNegativesCheckbox.update();
      selectedColony.ignoreNegatives = colonyUIIgnoreNegativesCheckbox.checked;
      focusAlloyButton.update();
      focusMineralButton.update();
      focusScienceButton.update();
      focusWaterButton.update();
      focusFoodButton.update();
      focusElectronicsButton.update();
      focusMetalButton.update();
      colonyFocusButton.update();
    }

    if (selectedDrone != null) {
      for (ImageButton ib : droneActionImageButtons) {
        ib.update();
      }
    }

    updateMarket();

    if (displayTechTree) {
      updateTechTree();
    } else if (notificationManager.notifications.size() != 0) {
      updateNotifications();
    }
    
    marketButton.update();
    techTreeButton.update();
  }
  boolean displayMarket = false;
  boolean notifiedYetAboutWarnings = false;
  void updateMarket() {
    if(Input.GetKeyDown(77)) {
      displayMarket = !displayMarket;
    }
    if(time.timeSinceLastTick > 400 && program.credits < market.requiredCreditsThisTurn && !notifiedYetAboutWarnings) {
      notificationManager.CreateWarningWarningNotifications();
      notifiedYetAboutWarnings = true;
    }
    if(time.tickThisFrame && program.credits < market.requiredCreditsThisTurn) {
      notificationManager.CreateGotAWarningNotifications();
    }
    
    if(time.tickThisFrame) {
      notifiedYetAboutWarnings = false;
      if(program.credits < market.requiredCreditsThisTurn) {
        program.credits = 0;
        market.warnings++;
        if(market.warnings == 4) {
          noLoop();
          Input.Reset();
          JOptionPane.showMessageDialog(null, "You have been shut down for not turning a profit for too long!", "ProjectLuna", JOptionPane.INFORMATION_MESSAGE);
          loop();
          inMainMenu = true;
        }
      } else {
        program.credits -= market.requiredCreditsThisTurn;
      }
      if(!program.profile.leaderImage.equals("SpaceXLeader") && !noTaxation) {
        market.requiredCreditsThisTurn += 5;
      }
      if(noTaxation) {
        market.requiredCreditsThisTurn = 0;
      }
    }
    if(!displayMarket || !Input.GetMouseButtonDown(0)) {
      return;
    }
    float titleSize = fitTextWidth("System Market", assetManager.getAssetByName("OpenSans").getFontAsset(), width * 0.6, 24);

    float buySellPanelSegment = width * 0.7 * 0.25;
    float buySellPanelX = width * 0.5 - width * 0.35;
    float buySellPanelY = titleSize * 1.2 + topBarHeight + 11;

    float currentX = buySellPanelX + buySellPanelSegment * 0.5;
    float currentY = buySellPanelY;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.scienceMarketValue) {
        program.science += 1;
        program.credits -= market.scienceMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.scienceMarketValue * 10) {
        program.science += 10;
        program.credits -= market.scienceMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.scienceMarketValue * 100) {
        program.science += 100;
        program.credits -= market.scienceMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.science >= 1) {
        program.science -= 1;
        program.credits += market.scienceMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.science >= 10) {
        program.science -= 10;
        program.credits += market.scienceMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.science >= 100) {
        program.science -= 100;
        program.credits += market.scienceMarketValue * 100;
      }
    }

    currentX = buySellPanelX + buySellPanelSegment * 1.5;
    currentY = buySellPanelY;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.mineralsMarketValue) {
        program.minerals += 1;
        program.credits -= market.mineralsMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.mineralsMarketValue * 10) {
        program.minerals += 10;
        program.credits -= market.mineralsMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.mineralsMarketValue * 100) {
        program.minerals += 100;
        program.credits -= market.mineralsMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.minerals >= 1) {
        program.minerals -= 1;
        program.credits += market.mineralsMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.minerals >= 10) {
        program.minerals -= 10;
        program.credits += market.mineralsMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.minerals >= 100) {
        program.minerals -= 100;
        program.credits += market.mineralsMarketValue * 100;
      }
    }

    currentX = buySellPanelX + buySellPanelSegment * 2.5;
    currentY = buySellPanelY;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.foodMarketValue) {
        program.food += 1;
        program.credits -= market.foodMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.foodMarketValue * 10) {
        program.food += 10;
        program.credits -= market.foodMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.foodMarketValue * 100) {
        program.food += 100;
        program.credits -= market.foodMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.food >= 1) {
        program.food -= 1;
        program.credits += market.foodMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.food >= 10) {
        program.food -= 10;
        program.credits += market.foodMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.food >= 100) {
        program.food -= 100;
        program.credits += market.foodMarketValue * 100;
      }
    }

    currentX = buySellPanelX + buySellPanelSegment * 3.5;
    currentY = buySellPanelY;
    
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.waterMarketValue) {
        program.water += 1;
        program.credits -= market.waterMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.waterMarketValue * 10) {
        program.water += 10;
        program.credits -= market.waterMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.waterMarketValue * 100) {
        program.water += 100;
        program.credits -= market.waterMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.water >= 1) {
        program.water -= 1;
        program.credits += market.waterMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.water >= 10) {
        program.water -= 10;
        program.credits += market.waterMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.water >= 100) {
        program.water -= 100;
        program.credits += market.waterMarketValue * 100;
      }
    }
    
    currentX = buySellPanelX + buySellPanelSegment * 1;
    currentY = buySellPanelY + height * 0.25;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.metalMarketValue) {
        program.metal += 1;
        program.credits -= market.metalMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.metalMarketValue * 10) {
        program.metal += 10;
        program.credits -= market.metalMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.metalMarketValue * 100) {
        program.metal += 100;
        program.credits -= market.metalMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.metal >= 1) {
        program.metal -= 1;
        program.credits += market.metalMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.metal >= 10) {
        program.metal -= 10;
        program.credits += market.metalMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.metal >= 100) {
        program.metal -= 100;
        program.credits += market.metalMarketValue * 100;
      }
    }

    currentX = buySellPanelX + buySellPanelSegment * 2;
    currentY = buySellPanelY + height * 0.25;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.alloyMarketValue) {
        program.alloy += 1;
        program.credits -= market.alloyMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.alloyMarketValue * 10) {
        program.alloy += 10;
        program.credits -= market.alloyMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.alloyMarketValue * 100) {
        program.alloy += 100;
        program.credits -= market.alloyMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.alloy >= 1) {
        program.alloy -= 1;
        program.credits += market.alloyMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.alloy >= 10) {
        program.alloy -= 10;
        program.credits += market.alloyMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.alloy >= 100) {
        program.alloy -= 100;
        program.credits += market.alloyMarketValue * 100;
      }
    }

    currentX = buySellPanelX + buySellPanelSegment * 3;
    currentY = buySellPanelY + height * 0.25;

    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.electronicsMarketValue) {
        program.electronics += 1;
        program.credits -= market.electronicsMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.electronicsMarketValue * 10) {
        program.electronics += 10;
        program.credits -= market.electronicsMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.credits >= market.electronicsMarketValue * 100) {
        program.electronics += 100;
        program.credits -= market.electronicsMarketValue * 100;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.electronics >= 1) {
        program.electronics -= 1;
        program.credits += market.electronicsMarketValue;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.electronics >= 10) {
        program.electronics -= 10;
        program.credits += market.electronicsMarketValue * 10;
      }
    }
    if (Collisions.RectPointCollision(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22, mouseX, mouseY)) {
      if(program.electronics >= 100) {
        program.electronics -= 100;
        program.credits += market.electronicsMarketValue * 100;
      }
    }
  }

  void recalculateValues() {
    topBarHeight = heightPercentMinimum(0.05, 60);
    eachBarSection = widthPercentMinimum(0.0625, 60);
    // Electronics is the longest text in the top bar and all the segments must have the same font size.
    textSize = fitTextWidth("Electronics", assetManager.getAssetByName("OpenSans").getFontAsset(), eachBarSection * 0.9, 24);
    timeBarDistanceFromLeft = width - topBarHeight - (eachBarSection * 3);

    OnPressedDelegate pauseDelegate = new OnPressedDelegate() { 
      public void onPressed() {
        time.speedButtonPressed(0f);
      }
    };
    pauseButton = new ImageButton(timeBarDistanceFromLeft + eachBarSection * 0.365, topBarHeight * 0.75, topBarHeight * 0.5, topBarHeight * 0.5, "PauseButton", color(0), color(0), false, pauseDelegate, ImageButton.CENTERED, ImageButton.CENTERED); 

    OnPressedDelegate halfSpeedDelegate = new OnPressedDelegate() { 
      public void onPressed() {
        time.speedButtonPressed(0.5f);
      }
    };
    halfSpeedButton = new ImageButton(timeBarDistanceFromLeft + eachBarSection * 0.365 * 3, topBarHeight * 0.75, topBarHeight * 0.5, topBarHeight * 0.5, "HalfSpeedButton", color(0), color(0), false, halfSpeedDelegate, ImageButton.CENTERED, ImageButton.CENTERED); 

    OnPressedDelegate fullSpeedDelegate = new OnPressedDelegate() { 
      public void onPressed() {
        time.speedButtonPressed(1f);
      }
    };
    fullSpeedButton = new ImageButton(timeBarDistanceFromLeft + eachBarSection * 0.365 * 5, topBarHeight * 0.75, topBarHeight * 0.5, topBarHeight * 0.5, "FullSpeedButton", color(0), color(0), false, fullSpeedDelegate, ImageButton.CENTERED, ImageButton.CENTERED); 

    OnPressedDelegate doubleSpeedDelegate = new OnPressedDelegate() { 
      public void onPressed() {
        time.speedButtonPressed(2f);
      }
    };
    doubleSpeedButton = new ImageButton(timeBarDistanceFromLeft + eachBarSection * 0.365 * 7, topBarHeight * 0.75, topBarHeight * 0.5, topBarHeight * 0.5, "DoubleSpeedButton", color(0), color(0), false, doubleSpeedDelegate, ImageButton.CENTERED, ImageButton.CENTERED);   

    if (time.currentTimeSpeed == 0f) {
      pauseButton.stroke = true;
      pauseButton.strokeColor = color(0, 255, 0);
    } else if (time.currentTimeSpeed == 0.5f) {
      halfSpeedButton.stroke = true;
      halfSpeedButton.strokeColor = color(0, 255, 0);
    } else if (time.currentTimeSpeed == 1f) {
      fullSpeedButton.stroke = true;
      fullSpeedButton.strokeColor = color(0, 255, 0);
    } else if (time.currentTimeSpeed == 2f) {
      doubleSpeedButton.stroke = true;
      doubleSpeedButton.strokeColor = color(0, 255, 0);
    } 

    if (selectedDrone != null) {
      recalculateDroneValues();
    }

    if (selectedColony != null) {
      recalculateColonyValues();
    }
  }

  public void recalculateDroneValues() {
    availableDroneActions = 0;
    for (DroneAction da : selectedDrone.droneActions) {
      if (da.canBeRun.canBeRun(selectedDrone) != 0) {
        availableDroneActions++;
      }
    }
    droneActionImageButtons = new ImageButton[availableDroneActions];
    lastDroneTile = map.WorldPointToTile(selectedDrone.x+selectedDrone.width/2, selectedDrone.y+selectedDrone.height/2);
    lastDroneBuilding = lastDroneTile.GetBuilding();
    pushStyle();
    droneActionHeight = heightPercentMinimum(0.05, 20);
    droneActionTextHeight = fitTextHeight(assetManager.getAssetByName("OpenSans").getFontAsset(), droneActionHeight * 0.75, 24);
    textSize(droneActionTextHeight);
    droneActionPadding = 5;
    droneActionPanelWidth = getLongestDroneActionText(selectedDrone) + 30 + droneActionHeight;
    droneActionPanelHeight = (droneActionHeight + droneActionPadding) * availableDroneActions;
    droneActionPanelY = height - (droneActionHeight + droneActionPadding) * availableDroneActions;
    popStyle();
    int i = 0;
    for (DroneAction action : selectedDrone.droneActions) {
      if (action.canBeRun.canBeRun(selectedDrone) == 0) {
        continue;
      }
      action.myDrone = selectedDrone;
      OnPressedDelegate onPressed = new OnPressedDelegate() {
        DroneAction a;
        public void SetValues(Object[] objects) {
          a = (DroneAction) objects[0];
        }
        public void onPressed() {
          a.onClick.OnPressed(a.myDrone);
        }
      };
      onPressed.SetValues(new Object[] { action });
      droneActionImageButtons[i] = new ImageButton(droneActionPadding, droneActionPanelY + (droneActionHeight + droneActionPadding) * i + droneActionPadding, droneActionHeight, droneActionHeight, action.imageAsset, color(0), color(0), false, onPressed, ImageButton.CENTEREDLEFT, ImageButton.CENTEREDTOP);
      droneActionImageButtons[i].enabled = action.canBeRun.canBeRun(selectedDrone) != 1;
      droneActionImageButtons[i].leftPaddingClickable = droneActionPadding;
      droneActionImageButtons[i].rightPaddingClickable = droneActionPanelWidth - droneActionHeight - droneActionPadding;
      i++;
    } //<>// //<>//
  }

  public void recalculateColonyValues() {
    colonyUITabHeight = height * 0.8;
    colonyUITabY = heightPercentMinimum(0.1, 60);
    colonyUITabWidth = eachBarSection * 3;
    colonyUINameFontSize = constrain(fitTextWidth(selectedColony.name, assetManager.getAssetByName("OpenSans").getFontAsset(), colonyUITabWidth - 10, 24), 0, 36);
    colonyUITabX = timeBarDistanceFromLeft;
    colonyUIIgnoreNegativesY = colonyUITabY + 36 + 2 + (24 + 4) * 7;
    colonyUIIgnoreNegativesHeight = colonyUITabWidth/5;
    colonyUIIgnoreNegativesFontSize = fitTextWidth("Ignore Negatives", assetManager.getAssetByName("OpenSans").getFontAsset(), colonyUITabWidth - (colonyUITabWidth/12 + colonyUIIgnoreNegativesHeight) - 10, 24);
    colonyUIIgnoreNegativesCheckbox = new CheckBox(colonyUITabX + colonyUITabWidth/12, colonyUIIgnoreNegativesY, colonyUIIgnoreNegativesHeight, colonyUIIgnoreNegativesHeight, "CheckedBoxButton", "UncheckedBoxButton", selectedColony.ignoreNegatives, CheckBox.CENTEREDLEFT, CheckBox.CENTEREDTOP);
    //image(lol, colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, colonyUITabWidth - 10, (colonyUITabWidth - 10f)*(float(lol.height)/float(lol.width)));
    OnPressedDelegate alloy = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.ALLOY;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    alloy.SetValues(new Object[] {selectedColony});
    focusAlloyButton = new InvisibleButton(colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, alloy, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    OnPressedDelegate minerals = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.MINERALS;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    minerals.SetValues(new Object[] {selectedColony});
    focusMineralButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, minerals, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    OnPressedDelegate water = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.WATER;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    water.SetValues(new Object[] {selectedColony});
    focusWaterButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 2, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, water, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);


    OnPressedDelegate science = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.SCIENCE;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    science.SetValues(new Object[] {selectedColony});
    focusScienceButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 3, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, science, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    OnPressedDelegate metal = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.METAL;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    metal.SetValues(new Object[] {selectedColony});
    focusMetalButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 0.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, metal, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    OnPressedDelegate food = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.FOOD;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    food.SetValues(new Object[] {selectedColony});
    focusFoodButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 1.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, food, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);


    OnPressedDelegate electronics = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        myColony.focus = FocusType.ELECTRONICS;
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    electronics.SetValues(new Object[] {selectedColony});
    focusElectronicsButton = new InvisibleButton(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 2.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, electronics, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    OnPressedDelegate selectNewColonyFocus = new OnPressedDelegate() {
      Colony myColony;
      public void onPressed() {
        String[] choices = { "Constructor Drone", "Filler Drone", "Science Drone", "Colony Drone", "Cancel Current", null, null, null, null };
        if(combatDronesUnlocked) {
          choices[5] = "Combat Drone";
        }
        if(artilleryDroneUnlocked) {
          choices[6] = "Artillery Drone";
        }
        if(lunarMissilesUnlocked) {
          choices[7] = "Lunar Missile";
        }
        if(artificialCityUnlocked) {
          choices[8] = "Artificial City";
        }
        
        noLoop();
        String chosen = (String) JOptionPane.showInputDialog(null, "What do you want to build?", "ProjectLuna", JOptionPane.QUESTION_MESSAGE, null, choices, choices[0]);
        loop();
        Input.Reset();
        if (chosen != null) {
          if (chosen.equals("Constructor Drone")) {
            myColony.currentDroneBuilding = new CreateConstructionDroneFocus(myColony);
          } else if (chosen.equals("Colony Drone")) {
            myColony.currentDroneBuilding = new CreateColonyDroneFocus(myColony);
          } else if (chosen.equals("Filler Drone")) {
            myColony.currentDroneBuilding = new CreateFillerDroneFocus(myColony);
          } else if (chosen.equals("Science Drone")) { // CreateScienceDroneFocus
            myColony.currentDroneBuilding = new CreateScienceDroneFocus(myColony);
          } else if (chosen.equals("Combat Drone")) {
            myColony.currentDroneBuilding = new CreateCombatDroneFocus(myColony);
          } else if(chosen.equals("Artillery Drone")) {
            myColony.currentDroneBuilding = new CreateArtilleryDroneFocus(myColony);
          } else if(chosen.equals("Lunar Missile")){
            myColony.currentDroneBuilding = new CreateLunarMissileFocus(myColony);
          } else if(chosen.equals("Artificial City")) {
            myColony.currentDroneBuilding = new CreateArtificalCityFocus(myColony);
          } else {
            myColony.currentDroneBuilding = null;
          }
        }
      }
      public void SetValues(Object[] objects) {
        myColony = (Colony) objects[0];
      }
    };
    selectNewColonyFocus.SetValues(new Object[] { selectedColony });
    colonyFocusButton = new InvisibleButton(colonyUITabX + 5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/2, colonyUITabWidth - 10, 50, selectNewColonyFocus, InvisibleButton.CENTEREDLEFT, InvisibleButton.CENTEREDTOP);

    //colonyFocusButton
  }

  public void draw() {
    // draw top bar
    pushStyle();
    fill(200, 200, 200, 128);
    rect(0, 0, width, topBarHeight);
    // Divide the top in to 16, with minimums
    noFill();
    stroke(0);
    textFont(assetManager.getAssetByName("OpenSans").getFontAsset());
    // Draw Leader Profile
    image(assetManager.getAssetByName(program.profile.leaderImage).getImageAsset(), 0, 0, eachBarSection, topBarHeight);

    // Set up for text, get a constant size
    textAlign(CENTER, CENTER);
    textSize(textSize);
    // Draw credits
    fill(255, 255, 0);
    rect(eachBarSection, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Credits\n" + (int)program.credits + " (" + formatPerTurn(program.creditsPerTurn) + ")", eachBarSection * 1.5, topBarHeight/2);
    // Draw Science
    fill(0, 110, 255);
    rect(eachBarSection * 2, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Science\n" + (int)program.science + " (" + formatPerTurn(program.sciencePerTurn) + ")", eachBarSection * 2.5, topBarHeight/2);
    // Draw Minerals
    fill(255, 0, 0);
    rect(eachBarSection * 3, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Minerals\n" + (int)program.minerals + " (" + formatPerTurn(program.mineralsPerTurn) + ")", eachBarSection * 3.5, topBarHeight/2);
    // Draw Food
    fill(106, 168, 79);
    rect(eachBarSection * 4, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Food\n" + (int)program.food + " (" + formatPerTurn(program.foodPerTurn) + ")", eachBarSection * 4.5, topBarHeight/2);
    // Draw Water
    fill(164, 194, 244);
    rect(eachBarSection * 5, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Water\n" + (int)program.water + " (" + formatPerTurn(program.waterPerTurn) + ")", eachBarSection * 5.5, topBarHeight/2);
    // Draw Metal
    fill(183, 183, 183);
    rect(eachBarSection * 6, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Metal\n" + (int)program.metal + " (" + formatPerTurn(program.metalPerTurn) + ")", eachBarSection * 6.5, topBarHeight/2);
    // Draw Alloy
    fill(103, 78, 167);
    rect(eachBarSection * 7, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Alloy\n" + (int)program.alloy + " (" + formatPerTurn(program.alloyPerTurn) + ")", eachBarSection * 7.5, topBarHeight/2);
    // Draw Electronics
    fill(246, 178, 107);
    rect(eachBarSection * 8, 0, eachBarSection, topBarHeight);
    fill(0);
    text("Electronics\n" + (int)program.electronics + " (" + formatPerTurn(program.electronicsPerTurn) + ")", eachBarSection * 8.5, topBarHeight/2);

    // Draw the Time Bar

    fill(153, 153, 153);
    rect(timeBarDistanceFromLeft, 0, eachBarSection * 3, topBarHeight/2);
    fill(0);
    rect(timeBarDistanceFromLeft, topBarHeight/2, eachBarSection * 3, topBarHeight/2);
    fill(255);
    textSize(fitTextHeight(assetManager.getAssetByName("OpenSans").getFontAsset(), topBarHeight/2 * 0.8, 24));
    text(time.formatDate(), timeBarDistanceFromLeft + eachBarSection * 1.5, topBarHeight/6);
    // width of each button is eachBarSection * 0.75
    if (lastTimeSpeed != time.currentTimeSpeed) {
      if (lastTimeSpeed == 0f) {
        pauseButton.stroke = false;
      } else if (lastTimeSpeed == 0.5f) {
        halfSpeedButton.stroke = false;
      } else if (lastTimeSpeed == 1f) {
        fullSpeedButton.stroke = false;
      } else if (lastTimeSpeed == 2f) {
        doubleSpeedButton.stroke = false;
      } 
      if (time.currentTimeSpeed == 0f) {
        pauseButton.stroke = true;
        pauseButton.strokeColor = color(0, 255, 0);
      } else if (time.currentTimeSpeed == 0.5f) {
        halfSpeedButton.stroke = true;
        halfSpeedButton.strokeColor = color(0, 255, 0);
      } else if (time.currentTimeSpeed == 1f) {
        fullSpeedButton.stroke = true;
        fullSpeedButton.strokeColor = color(0, 255, 0);
      } else if (time.currentTimeSpeed == 2f) {
        doubleSpeedButton.stroke = true;
        doubleSpeedButton.strokeColor = color(0, 255, 0);
      }
    }

    pauseButton.draw();
    halfSpeedButton.draw();
    fullSpeedButton.draw();
    doubleSpeedButton.draw();

    fill(0);

    textAlign(RIGHT, BOTTOM);
    text(frameRate, width, height);

    lastTimeSpeed = time.currentTimeSpeed;

    popStyle();

    if (selectedDrone != null) {
      droneUI(selectedDrone);
    }

    if (selectedColony != null) {
      colonyUI(selectedColony);
    }

    if (notificationManager.notifications.size() != 0) {
      drawNotifications();
    }

    if (displayTechTree) {
      drawTechTree();
    } else if(displayMarket) {
      drawMarket();
    }
    
    marketButton.draw();
    techTreeButton.draw();
  }

  public void drawMarket() {
    pushStyle();
    fill(28, 69, 135);
    rect(0, topBarHeight + 1, width, height-topBarHeight);
    float titleSize = fitTextWidth("System Market", assetManager.getAssetByName("OpenSans").getFontAsset(), width * 0.6, 24);
    textSize(titleSize);
    textAlign(CENTER, TOP);
    fill(0, 0, 0);
    text("System Market", width/2, topBarHeight);

    float buySellPanelSegment = width * 0.7 * 0.25;
    float buySellPanelX = width * 0.5 - width * 0.35;
    float buySellPanelY = titleSize * 1.2 + topBarHeight + 11;
    //Top row
    float currentX = buySellPanelX + buySellPanelSegment * 0.5;
    float currentY = buySellPanelY;

    fill(74, 134, 232);
    rect(buySellPanelX, buySellPanelY, width * 0.7, height);

    image(assetManager.getAssetByName("ScienceMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    stroke(255);
    text("Science", currentX, currentY + height * 0.125);
    text("Market Value: " + market.scienceMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 1.5;
    currentY = buySellPanelY;
    image(assetManager.getAssetByName("MineralMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Minerals", currentX, currentY + height * 0.125);
    text("Market Value: " + market.mineralsMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 2.5;
    currentY = buySellPanelY;
    image(assetManager.getAssetByName("FoodMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Food", currentX, currentY + height * 0.125);
    text("Market Value: " + market.foodMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 3.5;
    currentY = buySellPanelY;
    image(assetManager.getAssetByName("WaterMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Water", currentX, currentY + height * 0.125);
    text("Market Value: " + market.waterMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 1;
    currentY = buySellPanelY + height * 0.25;
    image(assetManager.getAssetByName("MetalMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Metal", currentX, currentY + height * 0.125);
    text("Market Value: " + market.metalMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 2;
    currentY = buySellPanelY + height * 0.25;
    image(assetManager.getAssetByName("AlloyMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Alloy", currentX, currentY + height * 0.125);
    text("Market Value: " + market.alloyMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    currentX = buySellPanelX + buySellPanelSegment * 3;
    currentY = buySellPanelY + height * 0.25;
    image(assetManager.getAssetByName("ElectronicsMarketIcon").getImageAsset(), currentX - buySellPanelSegment * 0.25 + 10, currentY + 10, buySellPanelSegment * 0.5 - 20, height * 0.5 * 0.25 - 20);
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    text("Electronics", currentX, currentY + height * 0.125);
    text("Market Value: " + market.electronicsMarketValue, currentX, currentY + height * 0.125 + 18);
    fill(28, 69, 135);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 40, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    rect(currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + 5, currentY + height * 0.125 + 65, buySellPanelSegment * 0.333 - 10, 22);
    fill(255, 255, 255);
    text("+1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 40);
    text("+10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 40);
    text("+100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 40);
    text("-1", currentX - buySellPanelSegment * 0.5 + 5 + (buySellPanelSegment * 0.333 - 10)/2, currentY + height * 0.125 + 65);
    text("-10", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.333 + (buySellPanelSegment * 0.333 - 10)/2+ 5, currentY + height * 0.125 + 65);
    text("-100", currentX - buySellPanelSegment * 0.5 + buySellPanelSegment * 0.666 + (buySellPanelSegment * 0.333 - 10)/2 + 5, currentY + height * 0.125 + 65);

    fill(0);
    textSize(24);
    text("Tax this month: " + market.requiredCreditsThisTurn, width/2, currentY + height * 0.125 + 105);
    text("Warnings: " + market.warnings, width/2, currentY + height * 0.125 + 145);

    noStroke();

    popStyle();
  }

  public void updateNotifications() {
    float yLocation = height;
    Notification toRemove = null;
    for (int i = 0; i < notificationManager.notifications.size(); i++) {
      Notification n = notificationManager.notifications.get(i);
      yLocation -= 110;
      if (Input.GetMouseButtonDown(0) && Collisions.RectPointCollision(width - 410, yLocation, 400, 100, mouseX, mouseY)) {
        n.center();
        Input.hasInputBeenIntercepted = true;
      } else if (Input.GetMouseButtonDown(1) && Collisions.RectPointCollision(width - 410, yLocation, 400, 100, mouseX, mouseY)) {
        toRemove = n;
        Input.hasInputBeenIntercepted = true;
      }
    }
    if (toRemove != null) {
      notificationManager.notifications.remove(toRemove);
    }
  }

  public void drawNotifications() {
    float yLocation = height;
    for (int i = 0; i < notificationManager.notifications.size(); i++) {
      Notification n = notificationManager.notifications.get(i);
      yLocation -= 110;
      fill(255, 0, 0);
      rect(width - 410, yLocation, 400, 100);
      fill(128, 128, 128);
      rect(width-110, yLocation, 100, 100);
      image(n.image, width-110, yLocation, 100, 100);
      fill(0, 0, 0);
      textSize(22);
      textAlign(LEFT, TOP);
      text(n.title, width - 400, yLocation + 10);
      textSize(16);
      textLeading(16);
      text(wrapText(n.description, 280, 16, assetManager.getAssetByName("OpenSans").getFontAsset()), width - 410, yLocation + 50);
    }
  }

  public String wrapText(String text, float maxWidth, float textSize, PFont font) {
    pushStyle();
    textFont(font);
    textSize(textSize);
    String temp = "";
    String currentWord = "";
    for (char c : text.toCharArray()) {
      if (c == ' ') {
        if (textWidth(temp + currentWord + ' ') >= maxWidth) {
          temp += '\n';
          temp += ' ';
          temp += currentWord;
          currentWord = "";
        } else {
          temp += ' ';
          temp += currentWord;
          currentWord = "";
        }
      } else {
        currentWord += c;
      }
    }
    if (textWidth(temp + currentWord + ' ') >= maxWidth) {
      temp += '\n';
      temp += ' ';
      temp += currentWord;
    } else {
      temp += ' ';
      temp += currentWord;
    }
    popStyle();
    return temp;
  }

  PGraphics ttpg;
  float techTreeScroll = 0f;
  float techTreeScrollSpeed = 75f;
  public void redrawTechTree() {
    float titleTextSize = fitTextWidth("Electronics Manufacturing", assetManager.getAssetByName("OpenSans").getFontAsset(), 270, 24);
    ttpg = createGraphics(int(techManager.width), int(techManager.height));
    ttpg.smooth();
    ttpg.beginDraw();
    ttpg.fill(109, 158, 235);
    ttpg.rect(0, 0, techManager.width, techManager.height);
    ttpg.textFont(assetManager.getAssetByName("OpenSans").getFontAsset());
    for (Tech t : techs.values()) {
      ttpg.strokeWeight(1);
      if (t.completed) {
        ttpg.fill(0, 255, 0);
      } else if (t.isAvailable() && t.scienceCost > program.science) {
        ttpg.fill(255, 153, 0);
      } else if (t.isAvailable() && t.scienceCost <= program.science) {
        ttpg.fill(255, 255, 0);
      } else {
        ttpg.fill(255, 0, 0);
      }
      ttpg.rect(t.x, t.y, 375, 100);
      ttpg.fill(0, 0, 0);
      ttpg.textAlign(LEFT, CENTER);
      ttpg.textSize(titleTextSize);
      ttpg.text(t.techName, t.x + 105, t.y + 5);
      ttpg.textAlign(LEFT, BOTTOM);
      ttpg.textSize(16);
      ttpg.text("Science cost: " + t.scienceCost, t.x + 105, t.y + 45);
      ttpg.textLeading(18);
      String tempDescription = wrapText("Effect: " + t.description, 250, 16, assetManager.getAssetByName("OpenSans").getFontAsset());
      ttpg.text(tempDescription, t.x + 105, t.y + 100);
      for (String s : t.prereqs) {
        Tech pre = techs.get(s);
        if (pre == null) {
          println(t.techName + " could not find tech " + s);
        } else {
          ttpg.strokeWeight(4);
          ttpg.stroke(0);
          ttpg.line(t.x, t.y + 50, pre.x + 375, pre.y + 50);
        }
      }
      ttpg.noStroke();
      ttpg.fill(0, 0, 255);
      ttpg.rect(t.x, t.y, 100, 100);
      ttpg.image(t.image, t.x, t.y, 100, 100);
    }
    ttpg.endDraw();
  }

  void updateTechTree() {
    if (ttpg == null || mustRedrawTechTree == true) {
      redrawTechTree();
      mustRedrawTechTree = false;
    }
    int change = Input.GetMouseWheelChange();
    techTreeScroll -= techTreeScrollSpeed * change;
    Input.hasScrollWheelBeenIntercepted = true;

    if(Input.GetKey(37)) {
      techTreeScroll -= techTreeScrollSpeed;
    } else if(Input.GetKey(39)) {
      techTreeScroll += techTreeScrollSpeed;
    }
    techTreeScroll = constrain(techTreeScroll, -(float(ttpg.width)/float(ttpg.height))*(height - topBarHeight) + width, 0);

    if (Input.GetMouseButtonDown(0)) {
      float tmouseX, tmouseY;
      //tmouseX = map(mouseX, 0, width, 0, ttpg.width) - techTreeScroll;
      //tmouseY = map(mouseY, topBarHeight, height, 0, ttpg.height);
      tmouseX = map(-techTreeScroll + mouseX, 0, (float(ttpg.width)/float(ttpg.height))*(height - topBarHeight), 0, techManager.width);
      tmouseY = map(mouseY, topBarHeight, height, 0, ttpg.height);
      for (Tech t : techs.values()) {
        if (Collisions.RectPointCollision(t.x, t.y, 375, 100, tmouseX, tmouseY)) {
          techManager.CompleteTech(t.techName);
        }
      }
    }
  }

  void drawTechTree() {
    if(ttpg == null) {
      redrawTechTree();
    }
    image(ttpg, techTreeScroll, topBarHeight, (float(ttpg.width)/float(ttpg.height))*(height - topBarHeight), height - topBarHeight);
  }


  void droneUI(Drone drone) {
    pushStyle();
    fill(0, 0, 0, 128);
    if (lastDroneTile != map.WorldPointToTile(drone.x+drone.width/2, drone.y+drone.height/2) || lastDroneBuilding != lastDroneTile.GetBuilding()) {
      recalculateDroneValues();
    }

    rect(0, droneActionPanelY, droneActionPanelWidth, droneActionPanelHeight);
    textAlign(LEFT, CENTER);
    textSize(droneActionTextHeight);
    int numberOfThings = 0;
    for (int i = 0; i < drone.droneActions.length; i++) {
      if (drone.droneActions[i].canBeRun.canBeRun(drone) == 1) {
        fill(128);
      } else {
        fill(255);
      }
      if (drone.droneActions[i].canBeRun.canBeRun(drone) != 0) {
        text(drone.droneActions[i].name, droneActionPadding * 2 + droneActionHeight, droneActionPanelY + (droneActionPadding + droneActionHeight) * (numberOfThings + 0.5));
        numberOfThings++;
      }
    }

    for (int i = 0; i < droneActionImageButtons.length; i++) {
      droneActionImageButtons[i].draw();
    }

    popStyle();
  }

  float getLongestDroneActionText(Drone drone) {
    float longest = 0;
    for (DroneAction da : drone.droneActions) {
      if (da.canBeRun.canBeRun(drone) == 0) {
        continue;
      }
      if (textWidth(da.name) > longest) {
        longest = textWidth(da.name);
      }
    }
    return longest;
  }

  void colonyUI(Colony c) {
    pushStyle();

    fill(28, 69, 135);
    rect(colonyUITabX, colonyUITabY, colonyUITabWidth, colonyUITabHeight);    

    fill(255);
    textAlign(CENTER, TOP);
    textSize(colonyUINameFontSize);
    text(c.name, colonyUITabX + colonyUITabWidth/2, colonyUITabY);
    textSize(24);
    text("Science: " + c.sciencePerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2);
    textSize(24);
    text("Minerals: " + c.mineralsPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 1);
    textSize(24);
    text("Food: " + c.foodPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 2);
    textSize(24);
    text("Water: " + c.waterPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 3);
    textSize(24);
    text("Metal: " + c.metalPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 4);
    textSize(24);
    text("Alloy: " + c.alloyPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 5);
    textSize(24);
    text("Electronics: " + c.electronicsPerTurn, colonyUITabX + colonyUITabWidth/2, colonyUITabY + 36 + 2 + (24 + 4) * 6);
    colonyUIIgnoreNegativesCheckbox.draw();
    textSize(colonyUIIgnoreNegativesFontSize);
    textAlign(LEFT, CENTER);
    text("Ignore negatives", colonyUITabX + colonyUITabWidth/12 + colonyUITabWidth/5 + 5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight/2);
    textSize(36);
    textAlign(CENTER);
    text("Focus", colonyUITabX + colonyUITabWidth/2, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight*1.75);
    PImage lol = assetManager.getAssetByName("FocusesColonyUI").getImageAsset();
    image(lol, colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, colonyUITabWidth - 10, (colonyUITabWidth - 10f)*(float(lol.height)/float(lol.width)));

    noFill();
    stroke(0, 255, 255);
    strokeWeight(4);

    if (c.focus == FocusType.ALLOY) {
      rect(colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.MINERALS) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 1, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.WATER) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 2, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.SCIENCE) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 3, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.METAL) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 0.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.FOOD) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 1.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    } else if (c.focus == FocusType.ELECTRONICS) {
      rect(colonyUITabX + 10 + (colonyUITabWidth - 10)/4 * 2.5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4, (colonyUITabWidth - 10)/4);
    }

    fill(255, 229, 153);
    strokeWeight(2);
    stroke(0);
    rect(colonyUITabX + 5, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/2, colonyUITabWidth - 10, 50, 15, 15, 15, 15);

    if (c.currentDroneBuilding == null) {
      fill(0);
      textSize(16);
      textAlign(LEFT, CENTER);
      text("No build selected!", colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/2 + 25);
    } else {
      fill(0);
      textSize(16);
      textAlign(LEFT, CENTER);
      text(c.currentDroneBuilding.name, colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/2 + 10);
      text(time.formatDateDifference((long) (c.currentDroneBuilding.timeLeft * (time.dateIncreasePerMonth / time.tickLength))) + " left", colonyUITabX + 10, colonyUIIgnoreNegativesY + colonyUIIgnoreNegativesHeight * 2 + (colonyUITabWidth - 10)/2 + 35);
    }

    popStyle();
  }

  String formatPerTurn(float num) {
    String returnThing = "";
    if (num > 0) {
      returnThing += "+";
    }
    returnThing += str(num);
    return returnThing;
  }

  float fitTextWidth(String text, PFont font, float desiredWidth, float textStartingSize) {
    pushStyle();
    textFont(font);
    textSize(textStartingSize);
    float dSize = (textStartingSize/textWidth(text))*desiredWidth;
    popStyle();
    return dSize;
  }

  float fitTextHeight(PFont font, float desiredHeight, float textStartingSize) {
    pushStyle();
    textFont(font);
    float textHeight = textAscent() + textDescent();
    float dSize = (textStartingSize/textHeight)*desiredHeight;
    popStyle();
    return dSize;
  }

  float widthPercentMinimum(float percent, float minimum) {
    return max(width * percent, minimum);
  }

  float heightPercentMinimum(float percent, float minimum) {
    return max(height * percent, minimum);
  }
  
  public void ShowVictoryScreen() {
    vs = new VictoryScreen();
    inVictoryScreen = true;
  }
}

public class CheckBox {
  public boolean enabled = true;
  public boolean checked;

  public float x, y, width, height;
  float xToday, yToday, widthToday, heightToday;

  PImage checkedImage, uncheckedImage;
  int centeredHorizontal, centeredVertical;

  public CheckBox(float x, float y, float width, float height, String checkedImageAsset, String uncheckedImageAsset, boolean checkedToStart, int centeredHorizontal, int centeredVertical) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.centeredHorizontal = centeredHorizontal;
    this.centeredVertical = centeredVertical;
    checkedImage = assetManager.getAssetByName(checkedImageAsset).getImageAsset();
    uncheckedImage = assetManager.getAssetByName(uncheckedImageAsset).getImageAsset();
    checked = checkedToStart;
  }

  public void update() {
    xToday = x;
    yToday = y;

    widthToday = width;
    heightToday = height;

    if (centeredHorizontal == CENTERED) {
      xToday -= widthToday/2;
    }
    if (centeredVertical == CENTERED) {
      yToday -= heightToday/2;
    }
    if (centeredHorizontal == CENTEREDRIGHT) {
      xToday -= widthToday;
    }
    if (centeredVertical == CENTEREDBOTTOM) {
      yToday -= heightToday;
    }

    if (Input.GetMouseButtonDown(0) && Collisions.RectPointCollision(xToday, yToday, widthToday, heightToday, mouseX, mouseY)) {
      checked = !checked;
      Input.hasInputBeenIntercepted = true;
    }
  }

  public void draw() {
    pushStyle();

    if (!enabled) {
      tint(128, 128, 128);
    }

    image(checked ? checkedImage : uncheckedImage, xToday, yToday, widthToday, heightToday);
    popStyle();
  }

  public static final int CENTERED = 0;
  public static final int CENTEREDTOP = -1;
  public static final int CENTEREDBOTTOM = 1;
  public static final int CENTEREDLEFT = -1;
  public static final int CENTEREDRIGHT = 1;
}

public class InvisibleButton {
  public float x, y, width, height;
  int centeredHorizontal, centeredVertical;
  public OnPressedDelegate onPressed;
  float widthToday, heightToday, xToday, yToday;
  public boolean enabled = true;

  public void update() {
    xToday = x;
    yToday = y;

    widthToday = width;
    heightToday = height;

    if (centeredHorizontal == CENTERED) {
      xToday -= widthToday/2;
    }
    if (centeredVertical == CENTERED) {
      yToday -= heightToday/2;
    }
    if (centeredHorizontal == CENTEREDRIGHT) {
      xToday -= widthToday;
    }
    if (centeredVertical == CENTEREDBOTTOM) {
      yToday -= heightToday;
    }

    if (Input.GetMouseButtonDown(0) && Collisions.RectPointCollision(xToday, yToday, widthToday, heightToday, mouseX, mouseY)) {
      if (enabled) {
        onPressed.onPressed();
      }
      Input.hasInputBeenIntercepted = true;
    }
  }

  public InvisibleButton(float x, float y, float width, float height, OnPressedDelegate onPressed, int centeredHorizontal, int centeredVertical) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.onPressed = onPressed;
    this.centeredHorizontal = centeredHorizontal;
    this.centeredVertical = centeredVertical;
  }

  public static final int CENTERED = 0;
  public static final int CENTEREDTOP = -1;
  public static final int CENTEREDBOTTOM = 1;
  public static final int CENTEREDLEFT = -1;
  public static final int CENTEREDRIGHT = 1;
}

public class ImageButton {
  public float x, y, width, height;
  String imageAsset;
  PImage image;
  public color fillColor;
  public color strokeColor;
  public color textColor;
  public boolean stroke;
  public boolean enabled = true;
  public OnPressedDelegate onPressed;
  float widthToday, heightToday, xToday, yToday;
  public float leftPaddingClickable = 0, rightPaddingClickable = 0, topPaddingClickable = 0, bottomPaddingClickable = 0;
  int centeredHorizontal, centeredVertical;

  public void update() {
    xToday = x;
    yToday = y;

    widthToday = width;
    heightToday = height;

    if (centeredHorizontal == CENTERED) {
      xToday -= widthToday/2;
    }
    if (centeredVertical == CENTERED) {
      yToday -= heightToday/2;
    }
    if (centeredHorizontal == CENTEREDRIGHT) {
      xToday -= widthToday;
    }
    if (centeredVertical == CENTEREDBOTTOM) {
      yToday -= heightToday;
    }

    if (Input.GetMouseButtonDown(0) && Collisions.RectPointCollision(xToday - leftPaddingClickable, yToday - topPaddingClickable, widthToday + leftPaddingClickable + rightPaddingClickable, heightToday + topPaddingClickable + bottomPaddingClickable, mouseX, mouseY)) {
      if (enabled) {
        onPressed.onPressed();
      }
      Input.hasInputBeenIntercepted = true;
    }
  }

  public void draw() {
    pushStyle();
    if (stroke) {
      stroke(strokeColor);
    } else {
      noStroke();
    }

    rectMode(CORNER);
    textAlign(LEFT, TOP);


    fill(fillColor);
    rect(xToday, yToday, widthToday, heightToday);

    if (!enabled) {
      tint(128, 128, 128);
    }

    image(image, xToday+5, yToday+5, widthToday-10, heightToday-10);
    popStyle();
  }

  public ImageButton(float x, float y, float width, float height, String imageAsset, color fillColor, color strokeColor, boolean stroke, OnPressedDelegate onPressed, int centeredHorizontal, int centeredVertical) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.imageAsset = imageAsset;
    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
    this.stroke = stroke;
    this.onPressed = onPressed;
    this.centeredHorizontal = centeredHorizontal;
    this.centeredVertical = centeredVertical;
    image = assetManager.getAssetByName(imageAsset).getImageAsset();
  }

  public static final int CENTERED = 0;
  public static final int CENTEREDTOP = -1;
  public static final int CENTEREDBOTTOM = 1;
  public static final int CENTEREDLEFT = -1;
  public static final int CENTEREDRIGHT = 1;
}

public class TextButton {
  public float x, y;
  public String text;
  public float textSize;
  public PFont font;
  public color fillColor;
  public color strokeColor;
  public color textColor;
  public boolean stroke;
  public int centeredHorizontal, centeredVertical;
  public OnPressedDelegate onPressed;
  float widthToday, heightToday, xToday, yToday;

  public void update() {
    textFont(font, textSize);
    textSize(textSize);

    xToday = x;
    yToday = y;

    widthToday = textWidth(text)+10;
    heightToday = textAscent()+textDescent()+10;

    if (centeredHorizontal == CENTERED) {
      xToday -= widthToday/2;
    }
    if (centeredVertical == CENTERED) {
      yToday -= heightToday/2;
    }
    if (centeredHorizontal == CENTEREDRIGHT) {
      xToday -= widthToday;
    }
    if (centeredVertical == CENTEREDBOTTOM) {
      yToday -= heightToday;
    }

    if (Input.GetMouseButtonDown(0) && Collisions.RectPointCollision(xToday, yToday, widthToday, heightToday, mouseX, mouseY)) {
      onPressed.onPressed();
      Input.hasInputBeenIntercepted = true;
    }
  }

  public void draw() {
    pushStyle();
    if (stroke) {
      stroke(strokeColor);
    } else {
      noStroke();
    }

    textFont(font, textSize);
    textSize(textSize);
    textAlign(LEFT, TOP);

    fill(fillColor);
    rect(xToday, yToday, widthToday, heightToday);

    fill(textColor);
    text(text, xToday+5, yToday+5);

    rectMode(CORNER);

    stroke(0);
    popStyle();
  }

  public TextButton(float x, float y, String text, PFont font, float textSize, color fillColor, color strokeColor, color textColor, boolean stroke, OnPressedDelegate onPressed, int centeredHorizontal, int centeredVertical) {
    this.x=x;
    this.y=y;
    this.text=text;
    this.font=font;
    this.textSize=textSize;
    this.fillColor=fillColor;
    this.strokeColor=strokeColor;
    this.textColor=textColor;
    this.stroke=stroke;
    this.onPressed=onPressed;
    this.centeredHorizontal = centeredHorizontal;
    this.centeredVertical = centeredVertical;
  }

  public static final int CENTERED = 0;
  public static final int CENTEREDTOP = -1;
  public static final int CENTEREDBOTTOM = 1;
  public static final int CENTEREDLEFT = -1;
  public static final int CENTEREDRIGHT = 1;
}

public abstract class OnPressedDelegate {
  public abstract void onPressed();
  public void SetValues(Object[] objects) { // I highly doubt that this is anywhere close to Java conventions at all. I think there's a reason why Delegates don't keep local variables. But guess what? It works.
    objects[0].toString();
  }
}

// Hey Mr Hollister. You made it to the end of the code! Did you read it all? Probably. It's exciting stuff. Hope you had fun with the game! We certainly did, except for in the last 2 weeks.
