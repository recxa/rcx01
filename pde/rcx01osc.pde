import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress maxPatcher;
NetAddress superCollider;

void sendPlayerPosition() {
  //sendBPMChange((int(position.x ) - 200) * ((int(position.y) - 200));
  //sendBPMChange((int(position.x ) - 200) * ((int(position.y) - 200)/200));
  sendBPMChange(int(abs((200 - (((position.x ) - 200)) * ((position.y - 200) / 200))) * bpmMult));
}

void sendBPMChange(int change) {
    OscMessage bpmChangeMsg = new OscMessage("/setBPM");
    bpmChangeMsg.add(change);
    oscP5.send(bpmChangeMsg, superCollider);
}

void sendSwitchNDeckSource() {
  OscMessage msg = new OscMessage("/switchNDeckSource");
  
  for(int i = 0; i < 2; i++) {
    for(int n = 0; n < 4; n++) {
      msg.add(currentBufs[i][n]);
    }
  }
  
  oscP5.send(msg, superCollider);
}

void sendSetVol(int deck, float change) {
    OscMessage msg = new OscMessage("/setVolume");
    msg.add(deck);
    msg.add(change);
    oscP5.send(msg, superCollider);
}

void sendReverseX() {
    OscMessage revXMsg = new OscMessage("/reverseX");
    revXMsg.add(reverseX);
    oscP5.send(revXMsg, superCollider);
}

void sendReverseY() {
    OscMessage revYMsg = new OscMessage("/reverseY");
    revYMsg.add(reverseY);
    oscP5.send(revYMsg, superCollider);
}

void sendMuteDeck(int deck, boolean muted) {
    OscMessage muteMsg = new OscMessage("/muteDeck");
    muteMsg.add(deck);
    if(muted){
      muteMsg.add(0);
    }
    else
    {
      muteMsg.add(1);
    }
    oscP5.send(muteMsg, superCollider);
}

void sendSetJump(int jump, int xSet, int ySet) {
    OscMessage setJumpMsg = new OscMessage("/setJump");
    setJumpMsg.add(jump);
    setJumpMsg.add(xSet);
    setJumpMsg.add(ySet);
    oscP5.send(setJumpMsg, superCollider);
}

void sendToggleJump(int jump, int enabled) {
    OscMessage toggleJumpMsg = new OscMessage("/toggleJump");
    toggleJumpMsg.add(jump);
    toggleJumpMsg.add(enabled);
    oscP5.send(toggleJumpMsg, superCollider);
    print("toggle sent");
}

void sendStartRecording() {
    OscMessage startRecMsg = new OscMessage("/startRecording");
    startRecMsg.add(recSlot);
    oscP5.send(startRecMsg, superCollider);
}

void sendStopRecording() {
    OscMessage stopRecMsg = new OscMessage("/stopRecording");
    oscP5.send(stopRecMsg, superCollider);
}

void sendTogRecording() {
    OscMessage togRecMsg = new OscMessage("/togRecording");
    togRecMsg.add(currentRecs[0]);
    oscP5.send(togRecMsg, superCollider);
}

void sendSource() {
  OscMessage sourceMsg = new OscMessage("/sendSource");
  if (!shiftSource) {
    sourceMsg.add(source[0]); 
    sourceMsg.add(source[1]); 
    liveSource[0] = source[0];
    liveSource[1] = source[1];
  } else {
    sourceMsg.add(source[2]); 
    sourceMsg.add(source[3]); 
    liveSource[0] = source[2];
    liveSource[1] = source[3];
  }
  print("source sent");
  oscP5.send(sourceMsg, superCollider);
  
  sendSwitchNDeckSource();
}

void sendTogsRecording() {
    OscMessage togRecMsg = new OscMessage("/togRecordings");
    togRecMsg.add(recCount());
    togRecMsg.add(currentRecs[0]);
    togRecMsg.add(currentRecs[1]);
    togRecMsg.add(currentRecs[2]);
    oscP5.send(togRecMsg, superCollider);
}

void oscEvent(OscMessage msg) {
  if (msg.addrPattern().equals("/phasorValues")) {
    fxPhasorValueY = msg.get(0).floatValue();
    fxPhasorValueX = msg.get(1).floatValue();
    globalPhasorValue = msg.get(2).floatValue();
  }
  
  //if (msg.addrPattern().equals("/waveData")) {
  //  println(msg.get(0));
  //  println(msg.get(1));
  //  updateWaveformData(int(msg.get(0).stringValue()), msg.get(1).stringValue());
  //  //waveformData[0] = stringToIntArray(msg.get(1).stringValue());
  //}
}
