//class Jump {
//  float x;
//  float y;
//  boolean active;
  
//  // Constructor with no parameters to initialize blank values
//  Jump() {
//    active = false; // Initially not active
//  }

//  // Methods to set individual values
//  void setPos(int deck, float value) { pos[deck] = value; }
//  void setIndex(int deck, int value) { index[deck] = value; }
//  void setActive(boolean value) { active = value; }

//  // Display method for the jump
//  void display() {
//    for (int i = 0; i < 4; i++) {
//      drawOffsetClock(pos[i], deckColors[i], 1);
//    }
//  }
//}

int currentJump = -1;
boolean jumping = false;

PImage originalImg;
PImage originalImgW;
PImage scaledImg;
PImage scaledImgW;

PImage jumpDelA;
PImage jumpDelB;
PImage jumpDelASg;
PImage jumpDelBS;

PImage[] letters = new PImage[7];
String[] letterPaths = new String[7];

int[][] activeJumps = new int[16][2];
int[] currentJumps = new int[2];
int[] deletedJumps = new int[16];

void initJumps() {
  letterPaths = new String[]{ 
        "jump_1.png",
        "delJump_1.png",
        "delJump_2.png",
        "delJump_3.png",
        "rec_1.png",
        "delRec_1.png",
        "delRec_2.png"
  };
  
  for(int i = 0; i < 7; i++) {
    PImage img = loadImage(letterPaths[i]);
    
    PGraphics pg = createGraphics(400, 400); // Target size
  
    pg.noSmooth(); // Disable anti-aliasing to keep pixels sharp
    pg.beginDraw();
    pg.image(img, 0, 0, pg.width, pg.height); // Draw the original image scaled up
    pg.filter(INVERT);
    pg.endDraw();
    
    letters[i] = pg.get();
  }
}

void handleJumps(char k, int kc, boolean press) {
  // jump matrix
  int altIndex = altGridKeys.indexOf(k);
  if (altIndex == -1) { altIndex = altShiftGridKeys.indexOf(k); }
  if (altIndex != -1 && press) {
    int x = altIndex % matrixWidth;
    int y = altIndex / matrixWidth;
    
    jumping = true;
    
    if (activeJumps[(x + (y * matrixWidth))][0] == 0 && activeJumps[(x + (y * matrixWidth))][1] == 0) {
      //set jump
      if(keys[61]) { 
        sendSetJump((x + (y * matrixWidth)), 1, 0); 
        activeJumps[(x + (y * matrixWidth))][0] = 1;
      } else if(keys[45]) { 
        sendSetJump((x + (y * matrixWidth)), 0, 1); 
        activeJumps[(x + (y * matrixWidth))][1] = 1;
      } else { 
        sendSetJump((x + (y * matrixWidth)), 1, 1); 
        activeJumps[(x + (y * matrixWidth))][0] = 1;
        activeJumps[(x + (y * matrixWidth))][1] = 1;
      }
    } else if (keys[8] && (activeJumps[(x + (y * matrixWidth))][0] == 1 || activeJumps[(x + (y * matrixWidth))][1] == 1)) {
      //del jump
      println("del jump");
      sendSetJump((x + (y * matrixWidth)), -1, -1); 
      activeJumps[(x + (y * matrixWidth))][0] = 0;
      activeJumps[(x + (y * matrixWidth))][1] = 0;
      clearDeletedJumps();
      deletedJumps[(x + (y * matrixWidth))] = round(random(1,2));
      //println("jump " + str((x + (y * matrixWidth))) + " = " + str(deletedJumps[(x + (y * matrixWidth))]));
    } else {
      currentJump = (x + (y * matrixWidth));
      sendToggleJump(currentJump, 1);
      if(activeJumps[currentJump][0] == 1) {
        currentJumps[0] = currentJump;
      }
      if(activeJumps[currentJump][1] == 1) {
        currentJumps[1] = currentJump;
      }
    }
  }
  
  // regular matrix
  int relIndex = altGridKeys.indexOf(k);
  if (relIndex != -1 && !press) {
    int x = relIndex % matrixWidth;
    int y = relIndex / matrixWidth;
    
    if(!keys[10] && !keys[SHIFT]) {
      sendToggleJump(currentJump, 0);
      if(currentJumps[0] == (x + (y * matrixWidth))) {
        currentJumps[0] = -1;
      }
      if(currentJumps[1] == (x + (y * matrixWidth))) {
        currentJumps[1] = -1;
      }
      currentJump = -1;
      print("disable - ");
    }
  }
  
  if (kc == 16 && currentJump != -1 && !press)
  {
    sendToggleJump(currentJump, 0);
    currentJump = -1;
    currentJumps[0] = -1;
    currentJumps[1] = -1;
    print("disable - ");
  }

  if (kc == 8 && !press) {
    clearDeletedJumps();
  }
}

void clearDeletedJumps() {
  println("deleted");
  for(int i = 0; i < 16; i++) {
    deletedJumps[i] = 0;
  }
}

void drawJumpNumber() {
  for (int i = 0; i < 16; i++) {
     int row = i / 4;
     int col = i % 4;
  
     // Calculate the top-left corner of the cropped area
     int x = 400 + col * 100; // 100 pixels per column, starting from 400
     int y = 400 + row * 100; // 100 pixels per row, starting from 400
     
     if(deletedJumps[i] == 1) {
       println("jump " + str(i) + " = " + str(deletedJumps[i]));
       tint(255, 40);
       image(letters[2], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
     } else if(deletedJumps[i] == 2) {
       println("jump " + str(i) + " = " + str(deletedJumps[i]));
       tint(255, 40);
       image(letters[3], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
     }
       
    if(!keys[10] && (activeJumps[i][0] == 1 || activeJumps[i][1] == 1)) {
       if (keys[8] && (activeJumps[i][0] == 1 || activeJumps[i][1] == 1)) {
         tint(255, 40);
         image(letters[1], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
       } else if (currentJumps[0] == i && currentJumps[1] == i) {
         tint(255, 255);
         image(letters[0], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
       } else if (currentJumps[0] == i) {
         if(reverseX && reverseY) {
           tint(0, 255, 255, 255);
         } else {
           tint(255, 0, 0, 255);
         }
         image(letters[0], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
       } else if (currentJumps[1] == i) {
         if(reverseX && reverseY) {
           tint(255, 255, 0, 255);
         } else {
           tint(0, 0, 255, 255);
         }
         image(letters[0], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
       } else if (!keys[8] && (activeJumps[i][0] == 1 || activeJumps[i][1] == 1)) {
         tint(255, 40);
         image(letters[0], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
       } else {
         return;
       }
    }
    
    if(keys[10] && (activeJumps[i][0] == 0 && activeJumps[i][1] == 0)) {
       tint(255, 40);  
       image(letters[0], x, y, 100, 100, col * 100, row * 100, (col + 1) * 100, (row + 1) * 100);
    }
        
    tint(255, 255);
  }
}
