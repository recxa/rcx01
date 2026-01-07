~bpm = 100;
~loopLength = 64;

~jumps = Array.fill(16, { [ nil, nil ] });

~fade = 0.001;

~rTempClock = 0.0;
~rTempPos = 0.0;

~recHot = false;
~recording = false;

~recBufs = Array.fill(16, { Buffer.alloc(s, 4); });
~activeRecBufs = Array.fill(16, { 0 });
~recOn = false;
~lastRec = -1;

~processingAddr = NetAddr.new("127.0.0.1", 12000); // Replace with Processing's IP and port

/*Server.default.options.inDevice_("MacBook Pro Microphone");
Server.default.options.outDevice_("External Headphones");
//
ServerOptions.inDevices;*/
//
~speakerMode = 1;
// if(ServerOptions.outDevices[0] == "MacBook Pro Speakers", { ~speakerMode = 0; });

// Define the globalPhasor SynthDef
(
SynthDef(\globalPhasor, {
	arg outBus, displayBus, freq;
	var phasorSig;

	freq = Control.names(\tempo).kr(~bpm);
	phasorSig = Phasor.ar(0, (freq / 60 / ~loopLength) / SampleRate.ir, 0, 4, 0);

	Out.kr(outBus, phasorSig);
	Out.kr(displayBus, phasorSig);
}).add;
);

// Define the sampy SynthDef
(
SynthDef(\sampy, {
	arg buf, amp = 1, rate = 1.0, lp = 1, phasorBus, phasorDisplayBus, outBus = 0, live = 1;
	var sig, fadeSig, phasorPos, reverse, jumping = 0, jump, jSig, rSig, lastPosR = 0, lastPosJ = 0;

	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);

	phasorPos = In.ar(phasorBus, 1);

	reverse = Control.names(\reverse).kr(0.0);
	jumping = Control.names(\jumping).kr(0.0);
	jump = Control.names(\jump).kr(0.0);
	lastPosR = Control.names(\lastposr).kr(0.0);
	lastPosJ = Control.names(\lastposj).kr(0.0);
	rSig = reverse * 2 * (lastPosR - phasorPos);
	jSig = (jump - lastPosJ) * jumping;

	sig = BufRd.ar(2, buf, (phasorPos + rSig + jSig) * (BufFrames.ir(buf)), loop: 1);

	Out.ar(outBus, sig * amp * env);
	Out.kr(phasorDisplayBus, (phasorPos + rSig + jSig));
}).add;
);

// Define the nSampy SynthDef
(
SynthDef(\nSampy, {
	arg bufA, bufB, bufC, bufD, amp, rate = 1.0, lp = 1, phasorBus, phasorDisplayBus, outBus = 0, live = 1;
	var sig, fadeSig, phasorPos, reverse, jumping = 0, jump, jSig, rSig, lastPosR = 0, lastPosJ = 0;
	var sigA, sigB, sigC, sigD;

	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);


	phasorPos = K2A.ar(In.kr(phasorBus, 1));

	reverse = Control.names(\reverse).kr(0.0);
	jumping = Control.names(\jumping).kr(0.0);
	jump = Control.names(\jump).kr(0.0);
	lastPosR = Control.names(\lastposr).kr(0.0);
	lastPosJ = Control.names(\lastposj).kr(0.0);
	rSig = reverse * 2 * (lastPosR - phasorPos);
	jSig = (jump - lastPosJ) * jumping;

	sigA = BufRd.ar(2, bufA, (phasorPos + rSig + jSig) * (BufFrames.ir(bufA)), loop: 1);
	sigB = BufRd.ar(2, bufB, (phasorPos + rSig + jSig) * (BufFrames.ir(bufB)), loop: 1);
	sigC = BufRd.ar(2, bufC, (phasorPos + rSig + jSig) * (BufFrames.ir(bufC)), loop: 1);
	sigD = BufRd.ar(2, bufD, (phasorPos + rSig + jSig) * (BufFrames.ir(bufD)), loop: 1);

	sig = sigA + sigB + sigC + sigD;

	Out.ar(outBus, sig * amp * env);
	Out.kr(phasorDisplayBus, ((phasorPos + rSig + jSig) * env));
}).add;
);

(
SynthDef(\recorder, {
	arg buf, bufNum, phasorBus, live = 1;
	var inSource, bufSig, phasorPos;

	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);

	phasorPos = K2A.ar(In.kr(phasorBus, 1));

	/*	bufSig = BufRd.ar(1, buf, phasorPos, loop: 1);*/

	// inSource = (SoundIn.ar(0) * env) + (bufSig * (1 - env));
	inSource = (SoundIn.ar(0) * env);

	BufWr.ar(inSource, bufNum, phasorPos * BufFrames.kr(buf), loop:1);

	Out.ar(0, [ inSource, inSource ] * ~speakerMode);
}).add;
);

(
SynthDef(\player, {
	arg buf, phasorBus, outBus = 0, live = 1;
	var bufSig, phasorPos;

	/*	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);*/

	phasorPos = K2A.ar(In.kr(phasorBus, 1));

	bufSig = BufRd.ar(1, buf, phasorPos * BufFrames.kr(buf), loop: 1, interpolation:4);

	Out.ar(outBus, [ bufSig, bufSig ]);
}).add;
);

(
SynthDef(\playerTwo, {
	arg bufL, bufR, phasorBus, outBus = 0, live = 1;
	var bufLSig, bufRSig, phasorPos;

	/*	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);*/

	phasorPos = K2A.ar(In.kr(phasorBus, 1));

	bufLSig = BufRd.ar(1, bufL, phasorPos * BufFrames.kr(bufL), loop: 1, interpolation:4);
	bufRSig = BufRd.ar(1, bufR, phasorPos * BufFrames.kr(bufR), loop: 1, interpolation:4);

	Out.ar(outBus, [ bufLSig, bufRSig ]);
}).add;
);

(
SynthDef(\playerThree, {
	arg bufL, bufR, bufC, phasorBus, outBus = 0, live = 1;
	var bufLSig, bufRSig, bufCSig, phasorPos;

	/*	var env = EnvGen.kr(Env.asr(~fade, 1, ~fade), live, doneAction:8);*/

	phasorPos = K2A.ar(In.kr(phasorBus, 1));

	bufLSig = BufRd.ar(1, bufL, phasorPos * BufFrames.kr(bufL), loop: 1, interpolation:4);
	bufRSig = BufRd.ar(1, bufR, phasorPos * BufFrames.kr(bufR), loop: 1, interpolation:4);
	bufCSig = BufRd.ar(1, bufC, phasorPos * BufFrames.kr(bufC), loop: 1, interpolation:4);

	Out.ar(outBus, [ bufLSig + bufCSig, bufRSig + bufCSig ]);
}).add;
);

(Routine({
	0.25.wait;

	~decks = List[];

	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));
	~decks.add(Deck.new(4));

	//replace this with local directory - i haven't figured out how lol
	//also follow the FluCoMa and rcxDeck installation instructions
	//also you need to run processing AND supercollider at the same time
	~cratePath = "/Users/red/Downloads/rcx25/rcx01/rcx01nov24/a_chops_cmr/";

	~arr = (1..16).scramble;

	~decks[0].loadNDeck(~cratePath ++ ~arr[0] ++ "/x/");
	~decks[1].loadNDeck(~cratePath ++ ~arr[1] ++  "/x/");
	~decks[2].loadNDeck(~cratePath ++ ~arr[2] ++  "/x/");
	~decks[3].loadNDeck(~cratePath ++ ~arr[3] ++  "/x/");
	~decks[4].loadNDeck(~cratePath ++ ~arr[4] ++  "/y/");
	~decks[5].loadNDeck(~cratePath ++ ~arr[5] ++  "/y/");
	~decks[6].loadNDeck(~cratePath ++ ~arr[6] ++  "/y/");
	~decks[7].loadNDeck(~cratePath ++ ~arr[7] ++  "/y/");

	~samplers = Array.fill(2, { nil });

	1.5.wait;

	~globalPhasorBus = Bus.control(s, 1);
	~fxPhasorBus = [ Bus.≥control(s, 1), Bus.control(s, 1), Bus.control(s, 1) ];

	~globalPhasorSynth = Synth(\globalPhasor, [\outBus, ~globalPhasorBus, \displayBus, ~fxPhasorBus[2], \freq, ~bpm]);

	0.5.wait;

	~x = [ 0, 0, 0, ~decks[0].buf[0], ~decks[0].volume[0], ~decks[0].rate[0], 0, 0, 0.0, 0.0, 0.0, true,
		[ ~decks[0].nBuf[0], ~decks[0].nBuf[1], ~decks[0].nBuf[2], ~decks[0].nBuf[3] ],
	[ 1.0, 1.0, 1.0, 1.0 ] ];
	~y = [ 0, 6, 0, ~decks[1].buf[0], ~decks[1].volume[0], ~decks[1].rate[0], 0, 0, 0.0, 0.0, 0.0, true,
		[ ~decks[6].nBuf[0], ~decks[6].nBuf[1], ~decks[6].nBuf[2], ~decks[6].nBuf[3] ],
	[ 1.0, 1.0, 1.0, 1.0 ] ];
	// tog, index, buf, buf, amp, rate, reverse, lastPosR, jumping, jump, lastPosJ
	// tog, index, buf, buf, amp, rate, reverse, lastPosR, jumping, jump, lastPosJ, n, bufs, amps

	~xG = Group.new;
	~yG = Group.new;
	~rG = Group.new;
	~pG = Group.new;

	~xB = Bus.audio(s, 2);
	~yB = Bus.audio(s, 2);

	~xA = Synth.head(~xG,\nSampy, [
		\bufA, ~x[12][0],
		\bufB, ~x[12][1],
		\bufC, ~x[12][2],
		\bufD, ~x[12][3],
		\amp, ~x[4],
		\rate, ~x[5],
		\phasorBus, ~globalPhasorBus,
		\phasorDisplayBus, ~fxPhasorBus[0],
		\reverse, ~x[6],
		\lastposr, ~x[7],
		\jumping, ~x[8],
		\jump, ~x[9],
	\lastposj, ~x[10]]);

	~yA = Synth.head(~yG,\nSampy, [
		\bufA, ~y[12][0],
		\bufB, ~y[12][1],
		\bufC, ~y[12][2],
		\bufD, ~y[12][3],
		\amp, ~y[4],
		\rate, ~y[5],
		\phasorBus, ~globalPhasorBus,
		\phasorDisplayBus, ~fxPhasorBus[1],
		\reverse, ~y[6],
		\lastposr, ~y[7],
		\jumping, ~y[8],
		\jump, ~y[9],
	\lastposj, ~y[10]]);

	~rA;
	~pA;

	0.1.wait;

	Routine.run({
		10.do({
			0.5.wait;
			~sendWaves.value(0);
			0.5.wait;
			~sendWaves.value(1);
		});
		14.wait;
		~sendWaves.value(0);
		0.5.wait;
		~sendWaves.value(1);
	});

	// s.queryAllNodes;

	~updateControl = { |deck|
		// tog, index, buf, buf, amp, rate, reverse, lastPosR, jumping, jump, lastPosJ, n, bufs, amps
		~x[3].get(0);
		if(deck == 0, {
			~xA.set(\live, 0);
			if(~x[11] == false, {
				~xA = Synth.head(~xG,\sampy, [
					\buf, ~x[3],
					\amp, ~x[4],
					\rate, ~x[5],
					\phasorBus, ~globalPhasorBus,
					\phasorDisplayBus, ~fxPhasorBus[0],
					\reverse, ~x[6],
					\lastposr, ~x[7],
					\jumping, ~x[8],
					\jump, ~x[9],
				\lastposj, ~x[10]]);
				}, {
					~xA = Synth.head(~xG,\nSampy, [
						\bufA, ~x[12][0],
						\bufB, ~x[12][1],
						\bufC, ~x[12][2],
						\bufD, ~x[12][3],
						\amp, ~x[4],
						\rate, ~x[5],
						\phasorBus, ~globalPhasorBus,
						\phasorDisplayBus, ~fxPhasorBus[0],
						\reverse, ~x[6],
						\lastposr, ~x[7],
						\jumping, ~x[8],
						\jump, ~x[9],
					\lastposj, ~x[10]]);
			});
			}, {
				~yA.set(\live, 0);
				if(~y[11] == false, {
					~yA = Synth.head(~yG,\sampy, [
						\buf, ~y[3],
						\amp, ~y[4],
						\rate, ~y[5],
						\phasorBus, ~globalPhasorBus,
						\phasorDisplayBus, ~fxPhasorBus[1],
						\reverse, ~y[6],
						\lastposr, ~y[7],
						\jumping, ~y[8],
						\jump, ~y[9],
					\lastposj, ~y[10]]);
					}, {
						~yA = Synth.head(~yG,\nSampy, [
							\bufA, ~y[12][0],
							\bufB, ~y[12][1],
							\bufC, ~y[12][2],
							\bufD, ~y[12][3],
							\amp, ~y[4],
							\rate, ~y[5],
							\phasorBus, ~globalPhasorBus,
							\phasorDisplayBus, ~fxPhasorBus[1],
							\reverse, ~y[6],
							\lastposr, ~y[7],
							\jumping, ~y[8],
							\jump, ~y[9],
						\lastposj, ~y[10]]);
				});
		});
	};

	~switchNDeckSource = { |xa, xb, xc, xd, ya, yb, yc, yd|
		// tog, index, buf, buf, amp, rate, reverse, lastPosR, jumping, jump, lastPosJ
		~x[12][0] = ~decks[~x[1]].nBuf[(4 * xa) + 0];
		~x[12][1] = ~decks[~x[1]].nBuf[(4 * xb) + 1];
		~x[12][2] = ~decks[~x[1]].nBuf[(4 * xc) + 2];
		~x[12][3] = ~decks[~x[1]].nBuf[(4 * xd) + 3];

		~y[12][0] = ~decks[~y[1]].nBuf[(4 * ya) + 0];
		~y[12][1] = ~decks[~y[1]].nBuf[(4 * yb) + 1];
		~y[12][2] = ~decks[~y[1]].nBuf[(4 * yc) + 2];
		~y[12][3] = ~decks[~y[1]].nBuf[(4 * yd) + 3];

		~updateControl.value(0);
		~updateControl.value(1);
	};

	// This function changes the BPM
	~setBPM = { |newBPM|
		~bpm = newBPM;
		~globalPhasorSynth.set(\tempo, newBPM);
	};

	~setVol = { |deck, ampChange|
		~decks[~dex[deck]].allVolume(ampChange);
	};

	OSCdef(\setVolume, { |msg, time, addr, recvPort|
		var deck, amplitude;
		deck = msg[1].asInteger;
		amplitude = msg[2].asFloat;

		~setVol.value(deck, amplitude);
	}, '/setVolume');

	OSCdef(\toggleReverseX, { |msg, time, addr, recvPort|
		~reverseX = msg[1].asBoolean;
		~x[6] = ~reverseX;
		if(~reverseX) {
			~x[7] = ~fxPhasorBus[2].getSynchronous;
		};

		~updateControl.value(0);
	}, '/reverseX');

	OSCdef(\toggleReverseY, { |msg, time, addr, recvPort|
		~reverseY = msg[1].asBoolean;
		~y[6] = ~reverseY;
		if(~reverseY) {
			~y[7] = ~fxPhasorBus[2].getSynchronous;
		};

		~updateControl.value(1);
	}, '/reverseY');

	OSCdef(\toggleJump, { |msg, time, addr, recvPort|
		var jump = msg[1].asInteger;
		var enable = msg[2].asInteger;

		if(enable == 1,  {
			if(~jumps[jump][0] != nil, {
				~x[8] = 1;
				~x[9] = ~jumps[jump][0];
				~jumps[jump][0].postln;
				~x[10] = ~fxPhasorBus[2].getSynchronous;
				~updateControl.value(0);
				"trig! X".postln;
				{ "done! X" }.postln.defer(~fade);
			});

			if(~jumps[jump][1] != nil, {
				var qDist = 0.0;
				qDist = ((~fxPhasorBus[0].getSynchronous - ~jumps[jump][1]) * 32).round / 32;
				~y[8] = 1;
				~y[9] = ~jumps[jump][1];
				~jumps[jump][1].postln;
				~y[10] = ~fxPhasorBus[2].getSynchronous;
				~updateControl.value(1);
				"trig! Y".postln;
				{ "done! Y".postln }.defer(~fade);
			});
			}, {
				if(~x[8] == 1, {
					~x[8] = 0;
					~x[10] = ~fxPhasorBus[2].getSynchronous;
					//'jump back x'.postln;
					~updateControl.value(0);
					"trig! X".postln;
					{ "done! X" }.postln.defer(~fade);
				});
				if(~y[8] == 1, {
					~y[8] = 0;
					~y[10] = ~fxPhasorBus[2].getSynchronous;
					//'jump back y'.postln;
					~updateControl.value(1);
					"trig! Y".postln;
					{ "done! Y" }.postln.defer(~fade);
				});
		});
	}, '/toggleJump');

	OSCdef(\setJump, { |msg, time, addr, recvPort|
		var jump = msg[1].asInteger;
		var xSet = msg[2].asInteger;
		var ySet = msg[3].asInteger;

		"jump set".postln;
		xSet.postln;
		ySet.postln;

		if(xSet != 0, { ~jumps[jump][0] = if(xSet == 1, { ~fxPhasorBus[2].getSynchronous }, { nil }); });
		if(ySet != 0, { ~jumps[jump][1] = if(ySet == 1, { ~fxPhasorBus[2].getSynchronous }, { nil }); });
	}, '/setJump');

	OSCdef(\switchDeckSource, { |msg, time, addr, recvPort|
		var x, y;

		x = msg[1].asInteger; // Assuming the first argument in the OSC message is x
		y = msg[2].asInteger; // Assuming the second argument in the OSC message is y

		~switchDeckSource.value(x, y);
	}, '/switchDeckSource');

	OSCdef(\switchNDeckSource, { |msg, time, addr, recvPort|
		var xa, xb, xc, xd, ya, yb, yc, yd;

		xa = msg[1].asInteger;
		xb = msg[2].asInteger;
		xc = msg[3].asInteger;
		xd = msg[4].asInteger;
		ya = msg[5].asInteger;
		yb = msg[6].asInteger;
		yc = msg[7].asInteger;
		yd = msg[8].asInteger;

		~switchNDeckSource.value(xa, xb, xc, xd, ya, yb, yc, yd);
	}, '/switchNDeckSource');

	OSCdef(\startRecording, { |msg, time, addr, recvPort|
		var slot = msg[1].asInteger;

		~lastRec = slot;
		"start rec".postln;

		if(~activeRecBufs[slot] == 0, {
			var newFrames;

			newFrames = (1 / (~bpm / 60 / ~loopLength)) * s.sampleRate;
			newFrames.postln;

			~activeRecBufs[slot] = 1;
			~recBufs[slot] = Buffer.alloc(s, newFrames, 1, { |buf|
				"done allocating".postln;
				Routine.run({
					0.2.wait;
					~rA = Synth.head(~rG,\recorder, [
						\buf, buf,
						\bufNum, buf.bufnum,
					\phasorBus, ~globalPhasorBus]);
				});
			});
			}, {
				~rA = Synth.head(~rG,\recorder, [
					\buf, ~recBufs[slot],
					\bufNum, ~recBufs[slot].bufnum,
				\phasorBus, ~globalPhasorBus]);
		});
	}, '/startRecording');

	OSCdef(\stopRecording, { |msg, time, addr, recvPort|
		var buf;
		"stop rec".postln;

		buf = ~recBufs[~lastRec];
		buf.normalize(0.7);

		~rA.set(\live, 0);
	}, '/stopRecording');

	/*OSCdef(\togRecording, { |msg, time, addr, recvPort|
	var slot = msg[1].asInteger;

	/*if(~currentRec != -1, { ~pA.set(\live, 0); ~currentRec != -1; });*/

	if(slot != -1, {
	if(~activeRecBufs[slot] == 1, {

	"pA togged! ".postln;
	slot.postln;

	if(~currentRec != -1, { ~pA.free; });

	~currentRec = slot;
	~pA = Synth.head(~pG,\player, [
	\buf, ~recBufs[slot].bufnum,
	\phasorBus, ~globalPhasorBus]);
	});
	}, {
	if(~currentRec != -1, { ~pA.free; ~currentRec = -1; });
	});
	}, '/togRecording');*/

	OSCdef(\togRecordings, { |msg, time, addr, recvPort|
		var amt = msg[1].asInteger;
		var dex = Array.fill(amt);
		var index = 0;

		if(amt == 0, {
			if(~recOn, { ~pA.free; });
			~recOn = false;
			}, {
				amt.do({ |i|
					if(msg[2+i] != -1, { dex[index] = msg[2+i]; index = index + 1; });
				});
		});

		if(amt == 1, {
			if(~recOn, { ~pA.free; });
			~recOn = true;
			~pA = Synth.head(~pG,\player, [
				\buf, ~recBufs[dex[0]].bufnum,
			\phasorBus, ~globalPhasorBus]);
		});

		if(amt == 2, {
			if(~recOn, { ~pA.free; });
			~recOn = true;
			~pA = Synth.head(~pG,\playerTwo, [
				\bufL, ~recBufs[dex[0]].bufnum,
				\bufR, ~recBufs[dex[1]].bufnum,
			\phasorBus, ~globalPhasorBus]);
		});

		if(amt == 3, {
			if(~recOn, { ~pA.free; });
			~recOn = true;
			~pA = Synth.head(~pG,\playerTwo, [
				\bufL, ~recBufs[dex[0]].bufnum,
				\bufR, ~recBufs[dex[1]].bufnum,
				\bufC, ~recBufs[dex[2]].bufnum,
			\phasorBus, ~globalPhasorBus]);
		});
	}, '/togRecordings');

	OSCdef(\changeBPM, { |msg, time, addr, recvPort|
		var change = msg[1].asInteger;
		~setBPM.value(~bpm + change);
	}, '/changeBPM');

	OSCdef(\setBPM, { |msg, time, addr, recvPort|
		var newBPM = msg[1].asInteger;
		// newBPM.postln;
		~setBPM.value(newBPM);
	}, '/setBPM');

	OSCdef(\muteDeck, { |msg, time, addr, recvPort|
		var deck, stat;
		deck = msg[1].asInteger;
		stat = msg[2].asInteger;

		if(deck == 0, {
			~x[4] = stat;
			~updateControl.value(0);
			}, {
				~y[4] = stat;
				~updateControl.value(1);
		});
	}, '/muteDeck');

	OSCdef(\sendSource, { |msg, time, addr, recvPort|
		var xSource, ySource;
		xSource = msg[1].asInteger;
		ySource = msg[2].asInteger + 4;

		"source recieved".postln;
		xSource.postln;
		ySource.postln;

		~x[1] = xSource;
		~y[1] = ySource;
	}, '/sendSource');

	// Routine to send phasor value
	Routine({
		1.wait;
		inf.do {
			s.sync; // Ensure we get the current state of the server
			~processingAddr.sendMsg("/phasorValues", ~fxPhasorBus[0].getSynchronous, ~fxPhasorBus[1].getSynchronous, ~fxPhasorBus[2].getSynchronous);
			// ~processingAddr.sendMsg("/globalPhasorValue", );

			0.03.wait; // Adjust the wait time as needed
		}
	}).play;

	~sendWave = { |wave, index|
		~processingAddr.sendMsg("/waveData", index, wave);
	};

	~snap = 128;

	OSCdef(\toggleJump, { |msg, time, addr, recvPort|
		var jump = msg[1].asInteger;
		var enable = msg[2].asInteger;

		if(enable == 1,  {
			if(~jumps[jump][0] != nil, {
				var qDist = 0.0;
				qDist = ((~fxPhasorBus[0].getSynchronous - ~jumps[jump][0]) * ~snap).round / ~snap;
				qDist.postln;
				~x[8] = 1;
				~x[9] = ~fxPhasorBus[0].getSynchronous - qDist;
				~jumps[jump][0].postln;
				~x[10] = ~fxPhasorBus[2].getSynchronous;
				~updateControl.value(0);
				"trig! X".postln;
				{ "done! X" }.postln.defer(~fade);
			});

			if(~jumps[jump][1] != nil, {
				var qDist = 0.0;
				qDist = ((~fxPhasorBus[0].getSynchronous - ~jumps[jump][1]) * ~snap).round / ~snap;
				qDist.postln;
				~y[8] = 1;
				~y[9] = ~fxPhasorBus[0].getSynchronous - qDist;
				~jumps[jump][1].postln;
				~y[10] = ~fxPhasorBus[2].getSynchronous;
				~updateControl.value(1);
				"trig! Y".postln;
				{ "done! Y".postln }.defer(~fade);
			});
		}, {
			if(~x[8] == 1, {
				~x[8] = 0;
				~x[10] = ~fxPhasorBus[2].getSynchronous;
				//'jump back x'.postln;
				~updateControl.value(0);
				"trig! X".postln;
				{ "done! X" }.postln.defer(~fade);
			});
			if(~y[8] == 1, {
				~y[8] = 0;
				~y[10] = ~fxPhasorBus[2].getSynchronous;
				//'jump back y'.postln;
				~updateControl.value(1);
				"trig! Y".postln;
				{ "done! Y" }.postln.defer(~fade);
			});
		});
	}, '/toggleJump');
}).play;)