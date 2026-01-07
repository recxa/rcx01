// INSTALL RCX01 DEPENDENCIES



// !!!! FULL INSTALLATION !!!!
// run the operation below to copy FluCoMa library & rcxDeck class to your Extensions folder.
// if you already have FluCoMa-SC installed, this operation will override it with version 1.0.7
(
Platform.case(
    \osx,       { ("cp -R '" ++ (thisProcess.nowExecutingPath.dirname ++ "/extensions/mac/") ++ "' '" ++ Platform.userExtensionDir ++ "'").systemCmd; },
	\linux,     { "Linux auto-install not supported yet :( but just move /install/extensions/win/rcxDeck.sc to " ++ Platform.userExtensionDir ++ " and install FluCoMa-SC for linux! if you encounter any bugs please email me! thank you <3".postln },
	\windows,   { ("xcopy \"" ++ thisProcess.nowExecutingPath.dirname ++ "\extensions\win\'" ++ "\\*\" \"" ++ Platform.userExtensionDir ++ "\\\" /E /Y /I").systemCmd; }
);
)

// !!!! RCXDECK-ONLY INSTALLATION !!!!
// if you would like to keep your current FluCoMa-SC version,
// this operation will only copy my rcx01 dependency (rcxDeck.sc) into your Extensions folder.
(
Platform.case(
    \osx,       { ("cp '" ++ (thisProcess.nowExecutingPath.dirname ++ "/extensions/mac/rcxDeck.sc") ++ "' '" ++ Platform.userExtensionDir ++ "'").systemCmd; },
	\linux,     { "Linux auto-install not supported yet :( but just move /install/extensions/win/rcxDeck.sc to " ++ Platform.userExtensionDir ++ " and install FluCoMa-SC for linux! if you encounter any bugs please email me! thank you <3".postln },
	\windows,   { ("xcopy \"" ++ thisProcess.nowExecutingPath.dirname ++ "\extensions\win\rcxDeck.sc'" ++ "\\*\" \"" ++ Platform.userExtensionDir ++ "\\\" /E /Y /I").systemCmd; }
);
)
