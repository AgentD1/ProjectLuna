import java.time.*; // This lets us use a LocalDateTime, an implementation of DateTime that lets us store the game day as an actual date instead of a long or something
import java.time.format.*; // This lets us format the LocalDateTime for display in our UI nicely

public class Time { // We created the main class for the time mechanics in the game
  //public float[] timeMultipliers = new float[] { 0, 0.5f, 1f, 2f };
  public float currentTimeSpeed = 0f;
  
  public int tickLength = 60 * 10; 
  
  public boolean tickThisFrame = false; 
  
  float timeSinceLastTick = 0f;
  Month lastMonth = Month.JANUARY;
  
  LocalDateTime date = LocalDateTime.of(LocalDate.of(2100,1,1), LocalTime.of(0,0));
  
  public int dateIncreasePerMonth = 2419200; //This is the number of seconds that are in a month
  
  public float tickTime = 0f; // This is the variable to the tick time
  public int tickNumber = 0; // This is the variable for the amount of ticks
  
  public float lastTimeSpeed = 1f;
  
  public void update() { // This where we created the different time options for the game (paused, x0.5 speed, x1 speed, and x2 speed
    if(Input.GetKeyDown(32)) { // space
      speedButtonPressed(0f); // This is the paused speed
    }
    if(Input.GetKeyDown(49)) { // 1
      speedButtonPressed(0.5f); // This is the x0.5 speed
    }
    if(Input.GetKeyDown(50)) { // 2
      speedButtonPressed(1f); // This is the x1 speed
    }
    if(Input.GetKeyDown(51)) { // 3
      speedButtonPressed(ui.debugDisplay ? 69f : 2f); // This the the x2 speed
    }
    
    tickTime += currentTimeSpeed;
    timeSinceLastTick += currentTimeSpeed;
    
    if(lastMonth != date.getMonth()) { // This is essentially the code that keeps track of the months for us
      timeSinceLastTick = 0;
      tickNumber++;
      tickThisFrame = true;
      lastMonth = date.getMonth();
    } else {
      tickThisFrame = false;
    }
    
    date = date.plusSeconds((long) ((dateIncreasePerMonth / tickLength) * currentTimeSpeed)); // This converts all of the stuff within the brackets into the long variable type
  }
  
  public void speedButtonPressed(float speed) { // This is the function that resets the speed (after paused) to the speed that it was previously. This isn't nessacary for the code, but it is a nice quality-of-life improvement
    if(currentTimeSpeed == 0f && speed == 0f) {
      currentTimeSpeed = lastTimeSpeed;
    } else {
      if(speed != 0) {
        lastTimeSpeed = speed;
      }
      currentTimeSpeed = speed;
    }
  }
  
  public String formatDate() { //This is the code that formats the displayed time
    return date.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.LONG));
  }
  
  long secondsInAMonth = dateIncreasePerMonth;
  long secondsInADay = 86400L;
  
  public String formatDateDifference(long seconds) {
    String result = (seconds > dateIncreasePerMonth ? (floor(seconds / dateIncreasePerMonth) + " Months ") : "") + (seconds % secondsInAMonth > secondsInADay ? (floor((seconds % secondsInAMonth)/secondsInADay) + " Days") : "");
    return result;
  }
}
