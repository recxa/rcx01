Robot robot;
JFrame window;
int previousX, previousY;
boolean isDragging = false;

int playTime = 21 * 60 * 1000; // 5 minutes in milliseconds
int startTime;
boolean isTiming = false;
ArrayList<KeyStrokeLog> keyLogs;
String participantID;

void setup() {
  //canvas
  //size(800, 800);
  
  size(800, 800, JAVA2D);
  PSurfaceAWT surf = (PSurfaceAWT) getSurface();
  PSurfaceAWT.SmoothCanvas canvas = (PSurfaceAWT.SmoothCanvas) surf.getNative();
  window = (JFrame) canvas.getFrame();

  try {
    robot = new Robot();
  } catch (AWTException e) {
    e.printStackTrace();
    exit();
  }

  window.dispose();
  window.setUndecorated(true);
  window.setVisible(true);
  window.setOpacity(1f); // Slightly visible window

  window.setSize(width, height);
    
  canvas.addMouseListener(new MouseAdapter() {
    public void mousePressed(MouseEvent e) {
      if (e.getButton() == MouseEvent.BUTTON1) {
        isDragging = true;
        previousX = e.getXOnScreen();
        previousY = e.getYOnScreen();
      }
    }

    public void mouseReleased(MouseEvent e) {
      if (e.getButton() == MouseEvent.BUTTON1) {
        isDragging = false;
      }
    }
  });
  
  canvas.addMouseMotionListener(new MouseAdapter() {
    public void mouseDragged(MouseEvent e) {
      if (isDragging) {
        int dx = e.getXOnScreen() - previousX;
        int dy = e.getYOnScreen() - previousY;
        window.setLocation(window.getX() + dx, window.getY() + dy);

        previousX = e.getXOnScreen();
        previousY = e.getYOnScreen();
      }
    }
  });
  
  // Get participant ID
  //participantID = JOptionPane.showInputDialog(null, "Enter Participant ID:", "Participant ID", JOptionPane.PLAIN_MESSAGE);
  //if (participantID == null || participantID.isEmpty()) {
  //  exit(); // Exit if no ID is entered
  //}
  
  //comm
  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);
  
  initShip();
  initGfx();
  initMat();
  
  muted = new boolean[]{ false, false, false, false };
  //keyLogs = new ArrayList<KeyStrokeLog>();
  //startTime = millis();
  //isTiming = true;
}

void draw() {
  background(0);
  
  handleShip();
  drawGfx();
}

void writeLogToFile(String filename) {
  String[] output = new String[keyLogs.size()];
  for (int i = 0; i < keyLogs.size(); i++) {
    output[i] = keyLogs.get(i).toString();
  }
  saveStrings(filename, output);
}


class KeyStrokeLog {
  char key;
  int keyCode;
  int timestamp;

  KeyStrokeLog(char key, int keyCode, int timestamp) {
    this.key = key;
    this.keyCode = keyCode;
    this.timestamp = timestamp;
  }

  public String toString() {
    return key + "," + keyCode + "," + timestamp;
  }
}
