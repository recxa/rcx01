/*_____________________________________________/\\\\\\\_________/\\\_____________________/\\\\\_______________        
 _____________________________________________/\\\/////\\\___/\\\\\\\___________________/\\\///________________       
  ____________________________________________/\\\____\//\\\_\/////\\\___/\\\\\\\\______/\\\____________________      
   __/\\/\\\\\\\______/\\\\\\\\__/\\\____/\\\_\/\\\_____\/\\\_____\/\\\__/\\\////\\\__/\\\\\\\\\____/\\\____/\\\_     
    _\/\\\/////\\\___/\\\//////__\///\\\/\\\/__\/\\\_____\/\\\_____\/\\\_\//\\\\\\\\\_\////\\\//____\///\\\/\\\/__    
     _\/\\\___\///___/\\\___________\///\\\/____\/\\\_____\/\\\_____\/\\\__\///////\\\____\/\\\________\///\\\/____   
      _\/\\\_________\//\\\___________/\\\/\\\___\//\\\____/\\\______\/\\\__/\\_____\\\____\/\\\_________/\\\/\\\___  
       _\/\\\__________\///\\\\\\\\__/\\\/\///\\\__\///\\\\\\\/_______\/\\\_\//\\\\\\\\_____\/\\\_______/\\\/\///\\\_ 
        _\///_____________\////////__\///____\///_____\///////_________\///___\////////______\///_______\///____\///__*/
     
        
        
void initGfx() {
  initJumps(); //<>//
  //populateSineWaveData();
  loadCSVData("studyCrateA_rms.csv");
}

void drawGfx() {
   drawSemiGridlines();
  
  if(!keys[9]) {
    if(keys[10]) {
      drawRecNumber();
    } else {
      drawJumpNumber(); 
    }
    drawMatrix();
    drawTrail(keys[UP]);
    if (!keys[UP]) {
      drawPlayer();
    }
    drawClock(fxPhasorValueX, color(255, 0, 0));
    drawClock(fxPhasorValueY, color(0, 0, 255));
    drawClock(globalPhasorValue, color(255));
    drawPlayheads(fxPhasorValueX, fxPhasorValueY); 
    drawDiagonalXYPlayhead(fxPhasorValueX, fxPhasorValueY, color(255));
  } else {
    drawRecNumber();
    drawClock(fxPhasorValueX, color(255, 0, 0));
    drawClock(fxPhasorValueY, color(0, 0, 255));
    drawClock(globalPhasorValue, color(255));
    drawTrail(keys[UP]);
    if (!keys[UP]) {
      drawPlayer();
    }
    drawSource();
  }
  
  drawWaveforms();
  
  for (int i = 0; i < matrixWidth; i++) {
    for (int j = 0; j < matrixHeight; j++) {
      if (matrix[i][j] == 1) {
        invertColors(i * boxSize, j * boxSize, boxSize, boxSize);
      }
    }
  }
}
       
/* clock display functions */

void drawClock(float phasor, color fillColor) {
  // Map the phasor value to the perimeter of the canvas
  float perimeter = 2 * (panel + panel);
  float position = ((phasor + 0.125) % 1) * perimeter;
  
  if(position < 0) { position += perimeter; }
  
  //println(position);

  // Variables to store the grid position
  int gridX, gridY;

  // Determine the position along the border
  if (position <= panel) {
    // Top edge
    gridX = (int)(position / gridSize);
    gridY = 0;
  } else if (position <= panel + panel) {
    // Right edge
    gridX = (int)(panel / gridSize) - 1;
    gridY = (int)((position - panel) / gridSize);
  } else if (position <= 2 * panel + panel) {
    // Bottom edge
    gridX = (int)((2 * panel + panel - position) / gridSize);
    gridY = (int)(panel / gridSize) - 1;
  } else {
    // Left edge
    gridX = 0;
    gridY = (int)((perimeter - position) / gridSize);
  }

  // Draw the square at the calculated grid position
  fill(fillColor);
  rect(gridX * gridSize, gridY * gridSize, gridSize, gridSize);
}

void drawOffsetClock(float phasor, color fillColor, int offset) {
  // Map the phasor value to the perimeter of the canvas
  float pixelOffset = offset * gridSize;
  float w = panel - (2* pixelOffset);
  float h = panel - (2 * pixelOffset);
  float perimeter = 2 * (w + h);
  float position = ((phasor + 0.125) % 1) * perimeter;
  
  if(position < 0) { position += perimeter; }
  
  //println(position);

  // Variables to store the grid position
  int gridX, gridY;

  // Determine the position along the border
  if (position <= w) {
    // Top edge
    gridX = (int)(position / gridSize);
    gridY = 0;
  } else if (position <= w + h) {
    // Right edge
    gridX = (int)(w / gridSize) - 1;
    gridY = (int)((position - w) / gridSize);
  } else if (position <= 2 * w + h) {
    // Bottom edge
    gridX = (int)((2 * w + h - position) / gridSize);
    gridY = (int)(h / gridSize) - 1;
  } else {
    // Left edge
    gridX = 0;
    gridY = (int)((perimeter - position) / gridSize);
  }
  
  gridX += offset;
  gridY += offset;
  
  // Draw the square at the calculated grid position
  fill(fillColor);
  rect(gridX * gridSize, gridY * gridSize, gridSize, gridSize);
}

/* matrix functions */

void drawMatrix() {
  for (int i = 0; i < matrixWidth; i++) {
    for (int j = 0; j < matrixHeight; j++) {
      for (int n = 0; n < 4; n++) {
        if(currentSquares[n][0] == i && currentSquares[n][1] == j) {
          fill(40);
          if(!shiftMat) {
            rect(i * boxSize, j * boxSize, boxSize, boxSize);
          } else {
            drawCheckerboard(i * boxSize, j * boxSize, boxSize, boxSize, 10, 10, false);
          }
        }
      }
      if (matrix[i][j] == 1) {
        fill(0, 0, 255); // Lit squares
        rect(i * boxSize, j * boxSize, boxSize, boxSize);
      }
    }
  }
  
  for (int i = 0; i < matrixWidth; i++) {
    for (int j = 0; j < matrixHeight; j++) {
      if (matrix[i][j] == 2) {
        fill(255, 255, 0); // Lit squares
        drawCheckerboard(i * boxSize, j * boxSize, boxSize, boxSize, 10, 10, false);
      }
    }
  }
}

void drawSource() {
  if(shiftSource) {
    fill(255);
    drawCheckerboard(source[0] * boxSize, source[1] * boxSize, boxSize, boxSize, 10, 10, false);
    drawCheckerboard(source[2] * boxSize, source[3] * boxSize, boxSize, boxSize, 10, 10, false);
  }
  invertColors(source[0] * boxSize, source[1] * boxSize, boxSize, boxSize);
}

void drawCheckerboard(int x, int y, int w, int h, int xSubdiv, int ySubdiv, boolean topLeftOn) {
  float boxWidth = w / xSubdiv;
  float boxHeight = h / ySubdiv;
  
  for (int i = 0; i < xSubdiv; i++) {
    for (int j = 0; j < ySubdiv; j++) {
      // Determine if the current box should be filled or transparent
      boolean isOn = (i + j) % 2 == 0 ? topLeftOn : !topLeftOn;

      if (isOn) {
        rect(x + i * boxWidth, y + j * boxHeight, boxWidth, boxHeight);
      }
    }
  }
}

void drawDiagonalPlayhead(float phasor, color fillColor) {
  // Define the start and end points of the diagonal within the bottom right quadrant
  int startX = 400;
  int startY = 400;
  int endX = 800;
  int endY = 800;

  // Calculate the total distance along the diagonal
  float diagonalDistance = dist(startX, startY, endX, endY);

  // Map the phasor value to a position along the diagonal
  float position = phasor * diagonalDistance;

  // Calculate the position's proportional x and y coordinates along the diagonal
  // Since it's a 45-degree diagonal, x and y increments are equal
  float xIncrement = position / sqrt(2); // sqrt(2) comes from the diagonal of a 1x1 square
  float yIncrement = xIncrement;

  // Quantize the increments to the nearest 10x10 grid
  int quantizedX = ((int)((startX + xIncrement) / 10)) * 10;
  int quantizedY = ((int)((startY + yIncrement) / 10)) * 10;

  // Ensure the playhead stays within the bottom right quadrant
  quantizedX = constrain(quantizedX, 400, 790);
  quantizedY = constrain(quantizedY, 400, 790);

  // Draw the square at the calculated position
  fill(fillColor);
  rect(quantizedX, quantizedY, 10, 10);
}

void drawDiagonalXYPlayhead(float phasorX, float phasorY, color fillColor) {
  // Define the start and end points of the diagonal within the bottom right quadrant
  int startX = 400;
  int startY = 400;
  int endX = 800;
  int endY = 800;

  // Calculate the total distance along the diagonal
  float diagonalDistance = dist(startX, startY, endX, endY);

  // Map the phasor value to a position along the diagonal
  float positionX = phasorX * diagonalDistance;
  float positionY = phasorY * diagonalDistance;

  // Calculate the position's proportional x and y coordinates along the diagonal
  // Since it's a 45-degree diagonal, x and y increments are equal
  float xIncrement = positionX / sqrt(2); // sqrt(2) comes from the diagonal of a 1x1 square
  float yIncrement = positionY / sqrt(2);

  // Quantize the increments to the nearest 10x10 grid
  int quantizedX = ((int)((startX + xIncrement) / 10)) * 10;
  int quantizedY = ((int)((startY + yIncrement) / 10)) * 10;

  // Ensure the playhead stays within the bottom right quadrant
  quantizedX = wrap(quantizedX, 400, 799);
  quantizedY = wrap(quantizedY, 400, 799);

  // Draw the square at the calculated position
  fill(fillColor);
  rect(quantizedX, quantizedY, 10, 10);
}








/* general fx functions */

void invertColors() {
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    int col = pixels[i];
    int r = 255 - ((col >> 16) & 0xFF);
    int g = 255 - ((col >> 8) & 0xFF);
    int b = 255 - (col & 0xFF);
    pixels[i] = color(r, g, b);
  }
  updatePixels();
}

void invertColors(int x, int y, int w, int h) {
  loadPixels();
  for (int i = x; i < x + w; i++) {
    for (int j = y; j < y + h; j++) {
      int index = i + j * width;
      if (index < pixels.length) {
        int col = pixels[index];
        int r = 255 - ((col >> 16) & 0xFF);
        int g = 255 - ((col >> 8) & 0xFF);
        int b = 255 - (col & 0xFF);
        pixels[index] = color(r, g, b);
      }
    }
  }
  updatePixels();
}

void drawGridlines() {
  stroke(40); // Set the color of the line to gray
  strokeWeight(2); // Set the weight of the line to 1 pixel
  
  // Draw main vertical line at x=400
  line(400, 0, 400, 800);
  
  // Draw main horizontal line at y=400
  line(0, 400, 800, 400);

  // Draw additional vertical gridlines in the bottom-left quadrant for waveforms
  for (int i = 1; i <= 3; i++) { // Draw 3 lines to separate 4 waveforms
    int x = i * 100; // Calculate x position for each line
    line(x, 400, x, 800); // Draw line from y=400 to y=800
  }

  // Draw additional horizontal gridlines in the top-right quadrant for waveforms
  for (int i = 1; i <= 3; i++) { // Draw 3 lines to separate 4 waveforms
    int y = i * 100; // Calculate y position for each line
    line(400, y, 800, y); // Draw line from x=400 to x=800
  }
  
  noStroke();
}

void drawSemiGridlines() {
  stroke(40); // Set the color of the line to gray
  strokeWeight(2); // Set the weight of the line to 1 pixel
  
  // Draw main vertical line at x=400
  line(400, 0, 400, 400);
  
  // Draw main horizontal line at y=400
  line(0, 400, 400, 400);
  
  //if(muted[1] == false) {
  //  for (int i = 0; i < 4; i++) { 
  //    for (int n = 0; n < 4; n++) {
  //        if(currentBufs[0][i] == n) {
  //          line(n * 100, 400, n * 100, 800); // Draw line from y=400 to y=800
  //          line(100 + (n * 100), 400, 100 + (n * 100), 800); // Draw line from y=400 to y=800
  //        }
  //    }
  //  }
  //}
  
  //if(muted[0] == false) {
  //  for (int i = 0; i < 4; i++) { 
  //    for (int n = 0; n < 4; n++) {
  //      if(currentBufs[1][i] == n) {
  //        line(400, n * 100, 800, n * 100); // Draw line from y=400 to y=800
  //        line(400, 100 + (n * 100), 800, 100 + (n * 100)); // Draw line from y=400 to y=800
  //      }
  //    }
  //  }
  //}
  
  noStroke();
}
