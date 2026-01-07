/*        _     _       
         | |   (_)      
      ___| |__  _ _ __  
     / __| '_ \| | '_ \ 
     \__ \ | | | | |_) |
     |___/_| |_|_| .__/ 
                 | |    
                 |_|     & trail   */
 
 
 
/* ship functions */           
            
//ship variables
PVector position, prevPosition, tempPosition, velocity;
float angle = 0;
float rotationSpeed = 0.1;
float thrustPower = 0.5;
float friction = 0.98;
boolean holdTemp = false;

void initShip() {
  //ship
  position = new PVector(panel / 2, panel / 2);
  prevPosition = new PVector(panel / 2, panel / 2);
  tempPosition = new PVector(panel / 2, panel / 2);
  velocity = new PVector(0, 0);
  
  //trail grid variables
  cols = panel / gridSize;
  rows = panel / gridSize;
  grid = new int[cols][rows];
  ageGrid = new int[cols][rows];
}

void handleShip() {
  if (keys[LEFT]) angle -= rotationSpeed;
  if (keys[RIGHT]) angle += rotationSpeed;
  
  if (keys[UP]) {
    PVector force = PVector.fromAngle(angle);
    force.mult(thrustPower);
    velocity.add(force);
  }
  
  if(!(keys[SHIFT] && keys[32])) {
    if(holdTemp) {
      position.set(tempPosition);
      if(!keys[UP]) {
        println("stop!");
        velocity.mult(0);
      }
      holdTemp = false;
    }
  } else {
    if(!holdTemp) {
       holdTemp = true;
       tempPosition.set(position);
    }
  }
  
  velocity.mult(friction);
  position.add(velocity);
  
  wrapAroundScreen();
  sendPlayerPosition(); 
}

void drawPlayer() {
  pushMatrix();
  translate(position.x, position.y);
  rotate(angle + HALF_PI);
  if(holdTemp) { fill(255, 255, 0); } else { fill(255); }
  noStroke();
  triangle(-10, 10, 10, 10, 0, -10);
  popMatrix();
}

void wrapAroundScreen() {
  if (position.x > panel) position.x = 0;
  if (position.x < 0) position.x = panel;
  if (position.y > panel) position.y = 0;
  if (position.y < 0) position.y = panel;
}

/* trail grid functions */

//trail grid variables
int gridSize = 10; // Size of the grid cells for the trail effect
int cols, rows;
int[][] grid; // Grid to hold the state of each cell
int[][] ageGrid; // Grid to hold the age of the tracer cells

void drawTrail(boolean engaged) {
  // Determine the grid cell the player is currently in
  int gridX = (int)(position.x / gridSize);
  int gridY = (int)(position.y / gridSize);
  
  //println(engaged);
  
  // Activate the cell the player is in, if within bounds
  if (gridX >= 0 && gridX < cols && gridY >= 0 && gridY < rows && engaged == true) {
    //println(":3");
    if (!holdTemp) { 
      grid[gridX][gridY] = 1; 
      ageGrid[gridX][gridY] = int(constrain(255 * velocity.mag(), 0, 255)); // Start the age at 255 (full white)
    } else { 
      grid[gridX][gridY] = 2;
      ageGrid[gridX][gridY] = int(wrap(int(255 * velocity.mag()), 0, 255)); // Start the age at 255 (full white)
    }
  }
  
  // Display the grid
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j] != 0) {
        switch(grid[i][j]){
          case 1:
            fill(255, 255, 255, ageGrid[i][j]);
            break;
          case 2:
            fill(255, 255, 0, ageGrid[i][j]);
            break;
        }
        
        rect(i * gridSize, j * gridSize, gridSize, gridSize);
        ageGrid[i][j] -= 5; // Decrease the age
        if (ageGrid[i][j] < 0) {
          grid[i][j] = 0; // Deactivate the cell if age is below 0
          ageGrid[i][j] = 0;
        }
      }
    }
  }
}
