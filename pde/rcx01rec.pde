boolean recHot = false;
float recCuePos = 0.0;

boolean recording = false;
boolean stopRecording = false;
boolean startRecording = false;

int layer = 0;
//int cueSlot;

int[] activeRecs = new int[16];
int[] currentRecs = new int[3];
int[] pressedRecs = new int[3];

int currentRec = -1;
int recSlot = -1;

boolean recPress = false;

float recStart = 0.0;
float recLength = 0.0;
//temp PImage for keeping a trail on the recording overlays

void initRec() {
  currentRecs = new int[]{ -1, -1, -1 };
  pressedRecs = new int[]{ -1, -1, -1 };
  activeRecs = new int[] { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
}

void handleRec(char k, int kc, boolean press) {
  
  // rec matrix
  int altIndex = altGridKeys.indexOf(k);
  if (altIndex == -1) { altIndex = altShiftGridKeys.indexOf(k); }
  if (altIndex != -1) {
    
    if (activeRecs[altIndex] == 0) {
      
      //pressed blank rec
      if (!keys[8] && keys[10] && press) { //enter
        if (altIndex != recSlot) {
          if(recSlot != -1) {
            activeRecs[recSlot] = 1;
            sendStopRecording();
          }
          activeRecs[altIndex] = 2;
          recSlot = altIndex;
          sendStartRecording();
        }
      }
      
    } else {
      
      //pressed active rec
      if (keys[8] && press) { // delete
      
        activeRecs[altIndex] = 0;
        if (altIndex == recSlot) { recSlot = -1; sendStopRecording(); }
        // send delete rec
        
      } else if (!keys[8] && keys[10] && press) { //enter
        
        if (recSlot == altIndex) {
          //stop rec
          activeRecs[recSlot] = 1;
          recSlot = -1;
          sendStopRecording();
        } else {
          if(recSlot != -1) {
            activeRecs[recSlot] = 1;
            sendStopRecording();
          }
          recSlot = altIndex;
          sendStartRecording();
        }
        
      } else {
        
        ////toggle
        if (recSlot == altIndex && press) {
          
          //stop rec
          activeRecs[recSlot] = 1;
          recSlot = -1;
          sendStopRecording();
          
        }
        else
        {
          
          if (press) {
            if(recPress && currentRecs[0] != altIndex && currentRecs[1] != altIndex && currentRecs[2] != altIndex) {
              int free = -1;
              
              for(int i = 0; i < 3; i++) {
                if(currentRecs[i] == -1 && free == -1) {
                  free = i;
                }
              }
              
              if (free != -1) { currentRecs[free] = altIndex; pressedRecs[free] = altIndex; }
            } else {
              if(currentRecs[0] == altIndex) { currentRecs[0] = -1; } else {
                currentRecs[0] = altIndex;
                currentRecs[1] = -1;
                currentRecs[2] = -1;
                pressedRecs[0] = altIndex;
                pressedRecs[1] = -1;
                pressedRecs[2] = -1;
                recPress = true;
              }
            }
          } else {
            for(int i = 0; i < 3; i++) {
              if(pressedRecs[i] == altIndex) {
                pressedRecs[i] = -1;
              }
            }
            
            if(pressedRecs[0] == -1 && pressedRecs[1] == -1 && pressedRecs[2] == -1)
            {
              recPress = false;
            }
          }

          sendTogsRecording();
          println("togrec");
          //for display testing
          
        }
      }
      
    }
    
  }
}

int recCount() {
  int r = 0;
  
  for (int i = 0; i < 3; i++) {
    if( currentRecs[i] != -1 ) {
      r = r + 1;
    }
  }
  
  return r;
}

void drawRecNumber() {
  for (int i = 0; i < 16; i++) {
    int row = i / 4;
    int col = i % 4;
 
    // Calculate the top-left corner of the cropped area
    int x = 400 + col * 100; // 100 pixels per column, starting from 400
    int y = 400 + row * 100; // 100 pixels per row, starting from 400
    
    if (recSlot == i) {
        tint(255, 0, 0);
        if(activeRecs[i] == 1) {
          image(letters[4], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
        } else {
          image(letters[4], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
        }
    } else if ((currentRecs[0] == i || currentRecs[1] == i || currentRecs[2] == i) && activeRecs[i] == 1) {
      tint(255);
      image(letters[4], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
    } else if (activeRecs[i] == 1) {
      tint(255, 40);
      image(letters[4], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
    } else {
      if (!keys[8]) {
        if (keys[10]) {
          tint(255, 20);
          image(letters[4], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
        } else {
          tint(255, 20);
          image(letters[6], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
        }
      }
    }
  }
}
