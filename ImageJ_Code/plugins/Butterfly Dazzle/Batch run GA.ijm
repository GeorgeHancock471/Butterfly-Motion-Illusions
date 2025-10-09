/*

Notes: 

change "Run_Elemental_Motion_Detector_ Butterflies_GA.txt" last line to code fitness as being upwards (rather than downwards)
change "Butterfly_Rendering_and_Processing_ImageGA.txt" lines near top to use the ROIs of a different wing shape, and alter rendering

pops 20-40 are "normal" (downwards = fitness
pops 41-60 are coded for upwards=fitness
pops 61-80 are coded for lMean=fitness
pops 81-83 are coded for downwards+lMean=fitness
pops 84-88 are coded for as downwards * lMean = fitness
pops 89-109 are coded for as downwards * lMean = fitness
*/

popDir = getDirectory("plugins")+"/1 CamoEvo/Populations/";

for(i=20; i<=21; i++){

	repDir = popDir + "panthelea" + i + "/";
	File.makeDirectory(repDir);

	setupFilesDir = getDirectory("plugins") + "/Butterfly Dazzle/Templates/papilio_template/";
	
	print(setupFilesDir);

	File.copy(setupFilesDir + "AlgorithmSettings.txt", repDir + "AlgorithmSettings.txt");
	File.copy(setupFilesDir + "Settings_Game.txt", repDir + "Settings_Game.txt");
	File.copy(setupFilesDir + "Settings_Population.txt", repDir + "Settings_Population.txt");

	ts = "select_folder=[" + repDir + "] select=[" + repDir + "GenPat_0/]";
	run("Butterfly Evolve Loop", ts);

	selectWindow("Summary Results");
	ts = repDir + "Summary Results.csv";
	saveAs("Text", ts);
	run("Close");

	selectWindow("Results");
	ts = repDir + "Results.csv";
	saveAs("Text", ts);
	run("Close");

}
