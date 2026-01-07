//matrix variables
int matrixWidth = 4;
int matrixHeight = 4;

int[][] matrix = new int[matrixWidth][matrixHeight];
int[][] orderMatrix = new int[matrixWidth][matrixHeight];

int[][] currentBufs = new int[2][4];
int[][] nOrders = new int[2][4];

int[][] currentSquares = new int[4][3];
int[][] shiftSquares = new int[4][3];
boolean shiftMat = false;

int[] source = new int[4];
int[] liveSource = new int[2];
boolean shiftSource = false;

int activeSquares = 0;
boolean matDown = false;

void initMat() {
    orderMatrix = new int[][]{ 
        { 0, 0, 0, 0 }, 
        { 0, 1, 0, 1 }, 
        { 2, 1, 0, 1 }, 
        { 2, 1, 0, 3 } 
    };
    
    currentBufs = new int[][]{ 
        { 0, 0, 0, 0 }, 
        { 0, 0, 0, 0 }
    };
    
    nOrders = new int[][]{
      { 0, 0, 0, 0 },
      { 0, 0, 0, 0 }
    };
    
    source = new int[] { 0, 2, 0, 0 };
}

void updateBufs() {
  activeSquares = -1;
  
  if(!shiftMat){
    for(int n = 0; n < 4; n++) {
      if(currentSquares[n][0] != -1) {
        activeSquares += 1;
      }
    }
    
    for(int i = 0; i < 2; i++) {
      for(int n = 0; n < 4; n++) {
        currentBufs[i][n] = currentSquares[ orderMatrix[activeSquares][n] ][i];
      }
    }
  } else {
    for(int n = 0; n < 4; n++) {
      if(shiftSquares[n][0] != -1) {
        activeSquares += 1;
      }
    }
    
    for(int i = 0; i < 2; i++) {
      for(int n = 0; n < 4; n++) {
        currentBufs[i][n] = shiftSquares[ orderMatrix[activeSquares][n] ][i];
      }
    }
  }
}

void setBufs() {
  updateBufs();
  
  sendSwitchNDeckSource();
}

void resetSquares() {
  for(int i = 1; i < 4; i++) {
    currentSquares[i][0] = -1;
    currentSquares[i][1] = -1;
    currentSquares[i][2] = 0;
  }
}

void resetShiftSquares() {
  for(int i = 1; i < 4; i++) {
    shiftSquares[i][0] = -1;
    shiftSquares[i][1] = -1;
    shiftSquares[i][2] = 0;
  }
  updateBufs();
}


int matCount() {
  int c = 0;
  
  for (int i = 0; i < matrixWidth; i++) {
    for (int j = 0; j < matrixHeight; j++) {
      if (matrix[i][j] != 0) {
        c += 1;
      }
    }
  }
  
  return c;
}

int shiftCount() {
  int c = 0;
  
  for (int i = 0; i < matrixWidth; i++) {
    for (int j = 0; j < matrixHeight; j++) {
      if (matrix[i][j] == 2) {
        c += 1;
      }
    }
  }
  
  return c;
}

int boxSize = 100; // Size of each box in the grid
int panel = 400;

boolean temped = false;

int[] dex = new int[2];
int[] tempDex = new int[2];
int[] liveDex = new int[2];

boolean[] muted = new boolean[]{ false, false, false, false };
boolean[] tempMuted = new boolean[4];

//--[temps]----<>
int tempX = 0;
int tempY = 0;
//--[temps]----<>
int tempXX = 0;
int tempYY = 0;

int[] sampIndex = new int[8];
// 0 = mute, 1-4 = index. first 4 are perm, second 4 are temp

color[] deckColors = new color[4];
// deck colors

//clock display variables
float fxPhasorValue;
float fxPhasorValueX;
float fxPhasorValueY;
float globalPhasorValue;

//supercollider variables
float bpmMult = 1.0;

int reverseFx = 0;
boolean reverseX = false;
boolean reverseY = false;

boolean rewind = false;
PVector[] history;
