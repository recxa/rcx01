//float[][] waveformData = new float[8][80]; // 8 waveforms, each with 80 values (40 for left channel, 40 for right)
//float[][] waveformArray = new float[80][40];

//void drawWaveforms() {
//  for(int c = 0; c < 4; c++) {
//    int centerLine = 50 + (c * 100); // Central line X position for each waveform
    
//    if(muted[1] == false) {
//      boolean act = false;
      
//      fill(40);
      
//      for (int n = 0; n < 4; n++) {                                                                                                                                                                                                               
//        if(currentBufs[0][n] == c) {                                                                                                                                                                                                               
//          act = true;
//          if(shiftMat) { fill(255, 255, 0); } else { fill(255); }
//        }
//      }
      
//      for (int i = 0; i < 40; i++) { // Loop through the left and right channel values
//        // Left Channel (Above the center line)
//        float valL = waveformData[c][i];
//        float valR = waveformData[c][i + 40];
        
//        if (act) {
//          for (int n = 0; n < 4; n++) {
//            if(currentBufs[0][n] != c) {
//              valL -= waveformArray[16 + (currentBufs[0][n] * 8)][i] / 2;
//              valR -= waveformArray[17 + (currentBufs[0][n] * 8)][i] / 2;
//            }
//          }
//        }
        
//        if(round(valL) > 0) {
//          int xLeft = centerLine - (ceil(valL) * 10); // Calculate X position based on amplitude value
//          int yLeft = 400 + (i * 10); // Y position based on index
//          rect(xLeft, yLeft, 10, 10); // Draw the square for the left channel
//        }
        
//        // Right Channel (Below the center line)
//        if (round(valR) > 0) { // Only draw if the value is greater than 0
//          int xRight = centerLine + (ceil(valR) * 10) - 10; // Calculate X position based on amplitude value
//          int yRight = 400 + (i * 10); // Y position is the same as for the left channel
//          rect(xRight, yRight, 10, 10); // Draw the square for the right channel
//        }
//      }
//    }
    
//    if(muted[0] == false) {
//      boolean act = false;
      
//      fill(40);
      
//      for (int n = 0; n < 4; n++) {
//        if(currentBufs[1][n] == c) {
//          act = true;
//          if(shiftMat) { fill(255, 255, 0); } else { fill(255); }
//        }
//      }
      
//      for (int i = 0; i < 40; i++) { // Loop through the left and right channel values
//        // Left Channel (Above the center line)
//        float valL = waveformData[c + 4][i];
//        float valR = waveformData[c + 4][i + 40];
        
//        if (act) {
//          for (int n = 0; n < 4; n++) {
//            if(currentBufs[1][n] != c) {
//              valL -= waveformArray[48 + (currentBufs[0][n] * 8)][i] / 2;
//              valR -= waveformArray[49 + (currentBufs[0][n] * 8)][i] / 2;
//            }
//          }
//        }
        
//        if(round(valL) > 0) {
//          int xLeft = 400 + (i * 10); // X position based on index, starting from the left edge of the top right quadrant
//          int yLeft = centerLine - (ceil(valL) * 10); // Calculate Y position based on amplitude value
//          rect(xLeft, yLeft, 10, 10); // Draw the square for the left channel
//        }
        
//        // Right Channel (Below the center line)
//        if (round(valR) > 0) { // Only draw if the value is greater than 0
//          int xRight = 400 + (i * 10); // X position is the same as for the left channel
//          int yRight = centerLine + (ceil(valR) * 10) - 10; // Calculate Y position based on amplitude value
//          rect(xRight, yRight, 10, 10); // Draw the square for the right channel
//        } 
//      }
//    }
//  }
//}

//void loadCSVData(String filename) {
//  Table dataTable = loadTable(filename, "header");
//  int numRows = dataTable.getRowCount();
//  int numCols = dataTable.getColumnCount();

//  // Loop through each row and column of the Table
//  for (int i = 0; i < numRows; i++) {
//    TableRow row = dataTable.getRow(i);
//    for (int j = 0; j < numCols; j++) {
//      // Parse each value into a float and store it in the array
//      waveformArray[i][j] = row.getFloat(j);
//      //println(waveformArray[i][j]);
//    }
//  }
  
//  for (int i = 0; i < 8; i++) {
//    for (int n = 0; n < 40; n++) {
//      waveformData[i][n] = waveformArray[2 * i][n];
//      waveformData[i][n + 40] = waveformArray[1 + (2 * i)][n];
//    }
//  }
//}

float[][] waveformArray = new float[320][40]; // Original data buffer

void drawWaveforms() {
  for (int c = 0; c < 4; c++) {
    int centerLine = 50 + (c * 100); // Central line X position for each waveform
    
    if (!muted[0]) {
      boolean act = false;
      fill(40);

      for (int n = 0; n < 4; n++) {
        if (currentBufs[0][n] == c) {
          act = true;
          fill(shiftMat ? color(255, 255, 0) : color(255));
        }
      }

      for (int i = 0; i < 40; i++) { // Loop through the left and right channel values
        // Left Channel (Above the center line)
        float valL = waveformArray[(80 * source[0]) + (2 * c)][i];
        float valR = waveformArray[(80 * source[0]) + (2 * c + 1)][i];

        if (act) {
          for (int n = 0; n < 4; n++) {
            if (currentBufs[0][n] != c) {
              valL -= waveformArray[(80 * source[0]) + 16 + (currentBufs[0][n] * 8)][i] / 2;
              valR -= waveformArray[(80 * source[0]) + 17 + (currentBufs[0][n] * 8)][i] / 2;
            }
          }
        }

        if (round(valL) > 0) {
          int xLeft = centerLine - (ceil(valL) * 10);
          int yLeft = 400 + (i * 10);
          rect(xLeft, yLeft, 10, 10);
        }

        // Right Channel (Below the center line)
        if (round(valR) > 0) {
          int xRight = centerLine + (ceil(valR) * 10) - 10;
          int yRight = 400 + (i * 10);
          rect(xRight, yRight, 10, 10);
        }
      }
    }

    if (!muted[1]) {
      boolean act = false;
      fill(40);

      for (int n = 0; n < 4; n++) {
        if (currentBufs[1][n] == c) {
          act = true;
          fill(shiftMat ? color(255, 255, 0) : color(255));
        }
      }

      for (int i = 0; i < 40; i++) { // Loop through the left and right channel values
        // Left Channel (Above the center line)
        float valL = waveformArray[(80 * source[1]) + 2 * (c + 4)][i];
        float valR = waveformArray[(80 * source[1]) + 2 * (c + 4) + 1][i];

        if (act) {
          for (int n = 0; n < 4; n++) {
            if (currentBufs[1][n] != c) {
              valL -= waveformArray[(80 * source[1]) + 48 + (currentBufs[0][n] * 8)][i] / 2;
              valR -= waveformArray[(80 * source[1]) + 49 + (currentBufs[0][n] * 8)][i] / 2;
            }
          }
        }

        if (round(valL) > 0) {
          int xLeft = 400 + (i * 10);
          int yLeft = centerLine - (ceil(valL) * 10);
          rect(xLeft, yLeft, 10, 10);
        }

        // Right Channel (Below the center line)
        if (round(valR) > 0) {
          int xRight = 400 + (i * 10);
          int yRight = centerLine + (ceil(valR) * 10) - 10;
          rect(xRight, yRight, 10, 10);
        }
      }
    }
  }
}

void loadCSVData(String filename) {
  Table dataTable = loadTable(filename, "header");
  int numRows = dataTable.getRowCount();
  int numCols = dataTable.getColumnCount();

  // Loop through each row and column of the Table
  for (int i = 0; i < numRows; i++) {
    TableRow row = dataTable.getRow(i);
    for (int j = 0; j < numCols; j++) {
      // Parse each value into a float and store it in the array
      waveformArray[i][j] = row.getFloat(j);
    }
  }
}

void drawPlayheads(float phasorX, float phasorY) {
  // Calculate playhead positions based on phasor values
  int playheadPosX = 400 + int(phasorX * 400); // For the top waveform, moving along X
  int playheadPosY = 400 + int(phasorY * 400); // For the side waveform, moving along Y
  
  // Quantize the increments to the nearest 10x10 grid
  int quantizedX = ((int)((playheadPosX) / 10)) * 10;
  int quantizedY = ((int)((playheadPosY) / 10)) * 10;

  // Ensure playhead stays within the quadrant boundaries
  playheadPosX = wrap(quantizedX, 400, 800); // Subtract width of the playhead to stay within the top-right quadrant
  playheadPosY = wrap(quantizedY, 400, 800); // Subtract height of the playhead to stay within the bottom-left quadrant
  noStroke(); // No border for the playhead rectangles

  if(!muted[1]){
    // Draw playhead for top waveform (red, 1x10)
    fill(255, 0, 0); // Red color
    for(int i = 0; i < 4; i++) {
      for(int n = 0; n < 4; n++) {
        if(currentBufs[1][n] == i) {
          rect(playheadPosX, i * 100, 10, 100); // Positioned at the center line of the top waveform
        }
      }
    }
  }
  
  if(!muted[0]){
    // Draw playhead for side waveform (blue, 10x1)
    fill(0, 0, 255); // Blue color
    for(int i = 0; i < 4; i++) {
      for(int n = 0; n < 4; n++) {
        if(currentBufs[0][n] == i) {
          rect(i * 100, playheadPosY, 100, 10); // Positioned at the center line of the top waveform
        }
      }
    }
  }
}

//void populateSineWaveData() {
//  for (int wave = 0; wave < 8; wave++) { // Iterate over all 8 waveforms
//    float frequency = random(0.5, 1.5); // Assign a random frequency between 0.5 and 1.5 for variation
//    for (int i = 0; i < 40; i++) { // Populate left and right channels with sine wave data
//      // Left channel, using the sine function with the random frequency, and rounding up
//      waveformData[wave][i] = (int)ceil(1 + 1 * sin(TWO_PI * i / 40.0 * frequency));
      
//      // Right channel, using the cosine function for a phase shift, and rounding up
//      // The index is adjusted to populate the right half of the array (i + 40)
//      waveformData[wave][i + 40] = (int)ceil(1 + 1 * cos(TWO_PI * i / 40.0 * frequency));
//    }
//  }
//}
