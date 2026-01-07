Deck {
    var buffers, nBuffers, hasNBufs, emp, stat, vol, rat, serv, mute, act, waves, fade;

	init { arg numBuffers, srv, hasN=false;
		serv = srv;
		emp = true;
		mute = false;
		act = 0;
		fade = 1000;
		stat = Array.fill(numBuffers, { 0 });
		vol = Array.fill(numBuffers, { 1.0 });
		rat = Array.fill(numBuffers, { 1.0 });
		buffers = Array.fill(numBuffers, { Buffer.new(serv); });
		hasNBufs = hasN;
		nBuffers = Array.fill(numBuffers * 4, { Buffer.new(serv); });
		waves = Array.fill(numBuffers, { Array.fill(80, { 0 } ); });
	}

	buf {
		^buffers;
	}

	nBuf {
		^nBuffers;
	}

	hasN {
		^hasNBufs;
	}

	hasN_ { | hasN |
		hasNBufs = hasN;
	}

	empty {
		^emp;
	}

	status {
		^stat;
	}

	volume {
		if(mute == false, { ^vol; }, { ^vol*0.0; });
		// ^vol;
	}

	muted {
		^mute;
	}

	waves {
		^waves;
	}

	mute_ { | mut |
		mute = mut;
	}

	active {
		^act;
	}

	active_ { | index |
		act = index;
	}

	volume_ { | ind, change |
		ind.do({ | index |
			vol[index] = vol[index] + change;
		});

		vol.postln;
	}

	allVolume_ { | change |
		buffers.size.do({ | index |
			vol[index] = change;
		});

		vol.postln;
	}

	rate {
		^rat;
	}

	rate_ { | ind, change |
		ind.do({ | index |
			rat[index] = change;
		});

		rat.postln;
	}

	allRate_ { | change |
		buffers.size.do({ | index |
			rat[index] = change;
		});

		rat.postln;
	}

	*new { arg numBuffers=4;
		^super.new.init(numBuffers);
	}

	loadBuf { arg bufIndex, path;
		if(bufIndex < buffers.size, {
			buffers[bufIndex] = Buffer.read(serv, path);
			// buffers[bufIndex].normalize;
			emp = false;
			"read it".postln;
		}, {
			"Buffer index out of range".warn;
		});
	}

	setBuf { arg index, buf;
		if(stat[index] == 0,
		{
			buffers[index] = buf;
		}, {
			//add save buf logic here
			buffers[index] = buf;
		});
	}

	loadNDeck { arg path;
		var files, nFiles;

		files = List();
		nFiles = List();

		"files: ".postln;

		PathName(path).files.do{ |aFile|
			aFile.extension.postln;
			if(aFile.fullPath.toUpper.endsWith("WAV") && (aFile.fullPath.toUpper.contains("._") == false), {
				files.add(aFile);
				emp = false;
				aFile.fileName.postln;
			}, { "nah: ".post; aFile.fileName.postln; });
			// files.add(aFile);
		};

		"N files: ".postln;

		PathName(path ++ "n/").files.do{ |aFile|
			aFile.extension.postln;
			if(aFile.fullPath.toUpper.endsWith("WAV") && (aFile.fullPath.toUpper.contains("._") == false), {
				nFiles.add(aFile);
				aFile.fileName.postln;
			}, { "nah: ".post; aFile.fileName.postln; });
			// files.add(aFile);
		};

		hasNBufs = true;

		"loading files.. ".postln;

		// Load the selected files into the buffers
		files.do({ |filePath, index|
			if (index < buffers.size, {
				buffers[index] = Buffer.read(serv, filePath.fullPath);
				"Loaded file: ".post; filePath.fileName.postln;
			}, {});
		});

		"loading N files.. ".postln;

		// Load the selected files into the buffers
		nFiles.do({ |filePath, index|
			"1".postln;
			if (index < nBuffers.size, {
				"2".postln;
				nBuffers[index] = Buffer.read(serv, filePath.fullPath);
				"Loaded N file: ".post; filePath.fileName.postln;
			}, {});
		});
	}

	loadDeck { arg path;
		var files, selectedFiles;

		files = List();

		PathName(path).filesDo{ |aFile|
			aFile.extension.postln;
			if(aFile.fullPath.toUpper.endsWith("WAV") && (aFile.fullPath.toUpper.contains("._") == false), {
				files.add(aFile);
				emp = false;
				aFile.fileName.postln;
			}, { "nah: ".post; aFile.fileName.postln; });
			// files.add(aFile);
		};

		if(File.exists(path ++ "/n/"), { "true.. ".postln }, { "naw..".postln });


		files.postln;

		// If there are more than 4 files, choose 4 randomly
		// Otherwise, use all available files
		if(files.size > 4, { selectedFiles = files.scramble.copyRange(0, 3); }, { selectedFiles = files; });

		selectedFiles.postln;

		// Load the selected files into the buffers
		selectedFiles.do({ |filePath, index|
			if (index < buffers.size, {
				buffers[index] = Buffer.read(serv, filePath.fullPath);

				Routine.run({
					var subdivisions = 40;
					var bufL = Buffer.readChannel(serv, filePath.fullPath, channels: [0], action:{ arg buf; var division = (buf.numFrames / subdivisions).trunc(2);
						Routine.run({
							subdivisions.do({ |i|
								buf.getToFloatArray(i * division, division, action:{ arg array;
									waves[index][i] = array.sumabs / division;
								});
								0.08.wait;
							});
						});
					});

					var bufR = Buffer.readChannel(serv, filePath.fullPath, channels: [1], action:{ arg buf; var division = (buf.numFrames / subdivisions).trunc(2);
						Routine.run({
							subdivisions.do({ |i|
								buf.getToFloatArray(i * division, division, action:{ arg array;
									waves[index][i + subdivisions] = array.sumabs / division;
								});
								0.08.wait;
							});
						});
					});
				});

				"Loaded file: ".post; filePath.fileName.postln;
			}, {});
		});
	}

	*loadDecks { arg srv, path, maxDecks=8, shuffle=false;
		var dFolders, decks, tempDeck, amtDecks;

		amtDecks = 0;
		decks = List();
		dFolders = PathName(path).folders;

		if(shuffle, { dFolders = dFolders.scramble; }, {});

		dFolders.do({ |folderPath, index|
			folderPath.postln;
			tempDeck = Deck.new(4, srv);
			tempDeck.loadDeck(folderPath.fullPath);
			if(tempDeck.empty == false && amtDecks < maxDecks, {
				decks.add(tempDeck);
				amtDecks = amtDecks + 1;
			}, { "empty deck".postln; });
		});

		^decks;
	}
}

Loader {
    var serv, path, lettering;

	init { arg srv, pth;
		serv = srv;
		path = pth;
		lettering = [ "a", "b", "c", "d" ];
	}

	*new { arg srv, pth;
		^super.new.init(srv, pth);
	}

	loadNDeck { arg srv, name, xPath, yPath;
		var nuXPath = path ++ name ++ "/x/";
		var nuXNPath = path ++ name ++ "/x/n/";
		var nuYPath = path ++ name ++ "/y/";
		var nuYNPath = path ++ name ++ "/y/n/";
		var bufs = Array.fill(8, {  Buffer(serv) });
		var resynth = Array.fill(8, {  Buffer(serv) });
		var resynthOrders = Array.fill(8, { Array.fill(8, { nil }); });
		var centroids = Array.fill(8, {  Buffer(serv) });
		var bases = Array.fill(8, {  Buffer(serv) });
		var activations = Array.fill(8, {  Buffer(serv) });
		var stats = Array.fill(8, {  Buffer(serv) });
		var nComponents = 4;

		var xFiles = List();
		var yFiles = List();
		var selectedFiles = List();

		var nuFiles = List();

		File.mkdir(nuXPath);
		File.mkdir(nuXNPath);
		File.mkdir(nuXNPath ++ "raw/");
		File.mkdir(nuYPath);
		File.mkdir(nuYNPath);
		File.mkdir(nuYNPath ++ "raw/");

		PathName(xPath).filesDo{ |aFile|
			if(aFile.fullPath.toUpper.endsWith("WAV") && (aFile.fullPath.toUpper.contains("._") == false) , { selectedFiles.add(aFile); }, { "nah: ".post; aFile.fileName.postln; });
		};

		PathName(yPath).filesDo{ |aFile|
			if(aFile.fullPath.toUpper.endsWith("WAV") && (aFile.fullPath.toUpper.contains("._") == false), { selectedFiles.add(aFile); }, { "nah: ".post; aFile.fileName.postln; });
		};
/*
		// If there are more than 4 files, choose 4 randomly
		// Otherwise, use all available files
		if(xFiles.size > 4, { selectedFiles = xFiles.scramble.copyRange(0, 3); }, { selectedFiles = xFiles; });

		if(yFiles.size > 4, { selectedFiles = xFiles.scramble.copyRange(0, 3); }, { selectedFiles = xFiles; });*/

		// Load the selected files into the buffers
		selectedFiles.do({ |filePath, index|
			if (index < bufs.size, {
				bufs[index] = Buffer.read(serv, filePath.fullPath, action:{
					if(index < 4, {
						bufs[index].write(nuXPath ++ "x" ++ (index + 1).asString ++ ".wav", headerFormat: "wav");
						nuFiles.add(nuXPath ++ "x" ++ (index + 1).asString ++ ".wav");
					}, {
						bufs[index].write(nuYPath ++ "y" ++ (index - 3).asString ++ ".wav", headerFormat: "wav");
						nuFiles.add(nuYPath ++ "y" ++ (index - 3).asString ++ ".wav");
					});
				});
				"Loaded file: ".post; filePath.fileName.postln;
			}, {});
		});

		Routine{
			var c = CondVar();
			var pred = true;
			var dex = 0;
			1.wait;

			bufs.do({ arg index, i;
				fork {
					1.1.wait;
					c.waitFor(1000, { (dex == i) });
					"go time!".postln;
					FluidBufNMF.processBlocking(serv, bufs[i], resynth:resynth[i], resynthMode: 1, bases:bases[i], activations:activations[i], components:nComponents, action:{ arg features;
						("nmf done!").postln;

						if(i < 4, {
							resynth[i].write(nuXNPath ++ "raw/" ++ "x" ++ (i + 1).asString ++ "N.wav", headerFormat: "wav");
						}, {
							resynth[i].write(nuYNPath ++ "raw/" ++ "y" ++ (i - 3).asString ++ "N.wav", headerFormat: "wav"); });

						FluidBufSpectralShape.processBlocking(serv, resynth[i], features:centroids[i], select:[\centroid], action:{ arg cents;
							cents.postln;
							FluidBufStats.processBlocking(serv, centroids[i], stats:stats[i], select:[\mean, \mid], action:{
								arg st;
								var distMat = Array2D.new(4, 4);

								st.loadToFloatArray(action:{
									arg fa;

									4.do({ arg l;
										4.do({ arg r;
											distMat[l,r] = 0;
										});
									});

									2.do({ arg a;
										var stat = fa[(a*8)..(((a+1)*8) - 1)];
										4.do({ arg l;
											4.do({ arg r;
												var d = distMat[l,r];
												distMat[l,r] = sqrt(((stat[l] - stat[4+r]) ** 2)) + d;
											});
										});
									});

									4.do({ arg a;
										var ind = distMat.asArray.order[0];
										var col = ind % 4; // column
										var row = (((ind - col) / 4)).asInteger; // row

										resynthOrders[i][col * 2] = col;
										resynthOrders[i][(col * 2) + 1] = row + 4;


										4.do({ arg column;
											distMat[column, col] = 999999;
										});

										4.do({ arg roww;
											distMat[row, roww] = 999999;
										});
									});

									resynthOrders[i].postln;

									fork {
										var nPath;
										var wPath;

										if(i < 4, {
											nPath = nuXNPath ++ "raw/" ++ "x" ++ (i + 1).asString ++ "N.wav";
											wPath = nuXNPath ++ "x" ++ (i + 1).asString;
										}, {
											nPath = nuYNPath ++ "raw/" ++ "y" ++ (i - 3).asString ++ "N.wav";
											wPath = nuYNPath ++ "y" ++ (i - 3).asString;
										});

										4.do({ arg a;
											var buf = Buffer.readChannel(serv, nPath, channels:[resynthOrders[i][a*2], resynthOrders[i][(a*2)+1]], action:{
												buf.write(wPath ++ lettering[a] ++ ".wav", headerFormat:"wav");

												// Routine.run({
												// 	var subdivisions = 40;
												// 	var bufL = Buffer.readChannel(serv, nPath, channels:[resynthOrders[i][a*2], action:{ arg bufl; var division = (bufl.numFrames / subdivisions).trunc(2);
												// 		Routine.run({
												// 			subdivisions.do({ |i|
												// 				bufl.getToFloatArray(i * division, division, action:{ arg array;
												// 					waves[index][i] = array.sumabs / division;
												// 				});
												// 				0.08.wait;
												// 			});
												// 		});
												// 		});
												//
												// 		var bufR = Buffer.readChannel(serv, nPath, channels:[resynthOrders[i][(a*2)+1]], action:{ arg bufr; var division = (bufr.numFrames / subdivisions).trunc(2);
												// 			Routine.run({
												// 				subdivisions.do({ |i|
												// 					buf.getToFloatArray(i * division, division, action:{ arg array;
												// 						waves[index][i + subdivisions] = array.sumabs / division;
												// 					});
												// 					0.08.wait;
												// 				});
												// 			});
												// 		});
												// 	});

												nuFiles.add(wPath ++ lettering[a] ++ ".wav");
											});
										});
									};

									dex = i + 1;
									c.signalOne;
								});
							});
						});
					});
				};
			});

			1.wait;
			c.signalOne;

			fork {
				10.wait;
				nuFiles.postln;
			};
		}.play();
	}
}