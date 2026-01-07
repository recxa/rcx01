//input variables
boolean[] keys = new boolean[128];
String gridKeys = "1234qwerasdfzxcv"; // Keys representing the 4x4 grid
String recGridKeys = "!@#$QWERASDFZXCV"; // Keys representing the 4x4 grid
String altGridKeys = "5678tyuighjkbnm,"; // Keys representing the 4x4 grid
String altShiftGridKeys = "%^&*TYUIGHJKBNM<"; // Keys representing the 4x4 grid

void keyPressed() {
  // handle key booleans
  if (keyCode < keys.length) {
    keys[keyCode] = true;
    println(keyCode);
    
    //int timeStamp = millis() - startTime;
    //keyLogs.add(new KeyStrokeLog(key, keyCode, timeStamp));
  }
  
  // handle BRAKE
  if (keys[32] && !holdTemp && !keys[SHIFT]) // space
  {
    velocity.mult(0);
  }
  
  if (keys[9]) {
    handleRec(key, keyCode, true);
    handleSource(key, true);
  } else {
    handleJumps(key, keyCode, true);
    handleMatrix(key, true);
  }
  
  handleReverse(keyCode, true);
  handleMute(keyCode, true);
  
}

void keyReleased() {
  if (keyCode < keys.length) {
    keys[keyCode] = false;
  }
  
  if (keys[9]) {
    handleRec(key, keyCode, false);
    handleSource(key, false);
  } else {
    handleJumps(key, keyCode, false);
    handleMatrix(key, false);
  }

  handleReverse(keyCode, false);
  handleMute(keyCode, false);
  
  if (keys[32] && !holdTemp && !(keys[LEFT] || keys[RIGHT]))
  {
    velocity.mult(0);
  }
  
  if (keyCode == 16) {
    println("let go!!!!");
    shiftMat = false;
    resetShiftSquares();
    setBufs();
  }
  
  if (keyCode == 9) {
    shiftSource = false;
    sendSource();
  }
}

void handleReverse(int kc, boolean press) {
  if (kc == 93)
  {
    if(press) {
      if(!reverseX) {
        reverseX = true;
        sendReverseX();
      }
    } else {
      reverseX = false;
      sendReverseX();
    }
  }
  if (kc == 91)
  {
    if(press) {
      if(!reverseY) {
        reverseY = true;
        sendReverseY();
      }
    } else {
      reverseY = false;
      sendReverseY();
    }
  }
}

void handleMute(int kc, boolean press) {
  if(true) {
    if(press) {
      if(keyCode == 61) { 
        if(muted[1] == false) { 
          muted[1] = true; 
          sendMuteDeck(1, muted[1]);
        }
      }
      if(keyCode == 45) { 
        if(muted[0] == false) { 
          muted[0] = true; 
          sendMuteDeck(0, muted[0]);
        }
      }
    }
    if(!press) {
      if(kc == 61) { 
        if(muted[1] == true) { 
          muted[1] = false; 
          sendMuteDeck(1, muted[1]);
        }
      }
      if(kc == 45) { 
        if(muted[0] == true) { 
          muted[0] = false; 
          sendMuteDeck(0, muted[0]);
        }
      }
    }
  }
}

void handleMatrix(char k, boolean press) {
  if(press) {
    int index = gridKeys.indexOf(k);
    if (index != -1) {
      int x = index % matrixWidth;
      int y = index / matrixWidth;
      int c = matCount();

      if(c == 0) {
        resetSquares();
      }
      
      if(c < 4) {
        int free = -1;
        
        for(int i = 0; i < 4; i++) {
          if(currentSquares[i][2] == 0 && free == -1) {
            free = i;
          }
        }
        
        if(free != -1) {
          currentSquares[free][0] = x;
          currentSquares[free][1] = y;
          currentSquares[free][2] = 1;
          
          tempX = x;
          tempY = y;
          
          matrix[x][y] = 1; // Turn on the corresponding square
          setBufs();
        }
      }
    }
    
    int recIndex = recGridKeys.indexOf(k);
    if (recIndex != -1) {
      int x = recIndex % matrixWidth;
      int y = recIndex / matrixWidth;    
      int c = shiftCount();

      if(c == 0 || shiftMat == false) {
        shiftMat = true;
      }
      
      if(c < 4) {
        int free = -1;
        for(int i = 0; i < 4; i++) {
          if(shiftSquares[i][2] == 0 && free == -1) {
            free = i;
          }
        }
        
        if(c == 0) { free = 0; }
        
        if(free != -1) {
          shiftSquares[free][0] = x;
          shiftSquares[free][1] = y;
          shiftSquares[free][2] = 1;
          
          matrix[x][y] = 2; // Turn on the corresponding square
          setBufs();
        }
      }
    }
  }
  else
  {
    int index = gridKeys.indexOf(k);
    if (index != -1) {
      int x = index % matrixWidth;
      int y = index / matrixWidth;

      for(int i = 0; i < 4; i++) {
        if(currentSquares[i][0] == x && currentSquares[i][1] == y) {
          currentSquares[i][2] = 0;
        }
      }
      
      setBufs();
      matrix[x][y] = 0; // Turn off the corresponding square
    }
    
    int recIndex = recGridKeys.indexOf(k);
    if (recIndex != -1) {
      int x = recIndex % matrixWidth;
      int y = recIndex / matrixWidth;
      
      matrix[x][y] = 0; // Turn off the corresponding square
      
      for(int i = 0; i < 4; i++) {
        if(shiftSquares[i][0] == x && shiftSquares[i][1] == y) {
          shiftSquares[i][2] = 0;
        }
      }
      
      int freeShifts = 0;
      
      for(int i = 0; i < 4; i++) {
        if(shiftSquares[i][2] == 0) {
          freeShifts += 1;
        }
      }
      
      if (freeShifts == 4) {
        shiftMat = false;
        resetShiftSquares();
      }
      
      setBufs();
    }
  }
}

void handleSource(char k, boolean press) {
  if(press) {
    int index = gridKeys.indexOf(k);
    if (index != -1) {
      int x = index % matrixWidth;
      int y = index / matrixWidth;
      
      source[0] = x;
      source[1] = y;
      
      sendSource();
    }
    
    int recIndex = recGridKeys.indexOf(k);
    if (recIndex != -1) {
      int x = recIndex % matrixWidth;
      int y = recIndex / matrixWidth;    
      
      shiftSource = true;
      source[2] = x;
      source[3] = y;
      
      sendSource();
    }
  }
  else
  {
    int recIndex = recGridKeys.indexOf(k);
    if (recIndex != -1) {
      int x = recIndex % matrixWidth;
      int y = recIndex / matrixWidth;
      
      if (source[2] == x && source[3] == y) { shiftSource = false; sendSource(); }
    }
  }
}
