mspecGate=1;
c=1;




function addArea(letter, selColour){

setBatchMode(true);

nSelections = roiManager("count");

roiManager("Add");

selNames = newArray(nSelections);
//run("Labels...", "color=white font=12 show use draw");

letterCount = 0;
letterLoc = newArray(0);

for(i=0; i<nSelections; i++){
	roiManager("select", i);
	selNames[i] = getInfo("selection.name");

	if(startsWith(selNames[i] , letter) == 1){ // record target selection areas
		letterCount ++;
		letterLoc = Array.concat(letterLoc, i);
	}
}
}



// STEP 0. UI
//........................................................

settingsFilePath = getDirectory("plugins") + "micaRecolorize/micaRecolor_settings.txt";

if(File.exists(settingsFilePath) == 1){
	settingsString=File.openAsString(settingsFilePath);	
	defaultSettings=split(settingsString, "\n");
	
} else defaultSettings = newArray( 
"Yes", 
"No", 
"ForWingR,ForWingL,HindWingR,HindWingR");


yesNo=newArray("Yes","No");

Dialog.create("Settings:");
Dialog.addChoice("Adjust multispectral settings",yesNo, defaultSettings[0]); 
Dialog.addChoice("Use pre-labeled ROIs",yesNo, defaultSettings[1]); 
Dialog.addString("ROI_names, if enabled ','", defaultSettings[2], 80);
Dialog.show();

adjustSettings=Dialog.getChoice();
usePreROI=Dialog.getChoice();
preROIList=Dialog.getString;


dataFile = File.open(settingsFilePath);

	print(dataFile, adjustSettings);
	print(dataFile, usePreROI);
	print(dataFile, preROIList);

File.close(dataFile);

preROIList=split(preROIList,",");



while(mspecGate){

// STEP 1. Create MSPEC
//........................................................
close("*");

setTool("roundrect");

if(adjustSettings=="Yes"){
waitForUser("Remember to adjust the label at the bottom for the first image");
run(" Generate Multispectral Image");
adjustSettings="No";
}else{
run("batch multispectral");
}


// STEP 2. ROIs
//........................................................

roiGate=getBoolean("Is there a ROI to add? \n--------------------\n	Clicking ok will prompt you to draw a polygon for it");

while(roiGate==1){
setTool("polygon");


run("Select None");
while(selectionType==-1){
waitForUser("Draw a polygon around the ROI,\n      Then click OK");
if(nImages<1) exit;
}
roiManager("Add");


if(usePreROI=="Yes"){

roiChoices=preROIList;
Dialog.createNonBlocking("Select the label");
Dialog.addChoice("ROI_Label", roiChoices);
Dialog.show();
roiN = Dialog.getChoice();

}else{

roiChoices=preROIList;
Dialog.createNonBlocking("Type the label");
Dialog.addString("ROI_Label", "label", 30);
Dialog.show();
roiN = Dialog.getString();


}

roiManager("Select",roiManager("Count")-1);
roiManager("Rename",roiN);

run("Select None");

roiGate=getBoolean("Is there a ROI to add? \n--------------------\n	Clicking ok will prompt you to draw a polygon for it");


}


// STEP 4. Scale Bar
//........................................................

run("Select None");

setTool("line");

g=1;
while(g){
waitForUser("Draw a line on the scale bar. \nThen hit OK");
if(selectionType!=-1) g=0;
}

getSelectionCoordinates(xCoords, yCoords);
scaleLength = pow(pow(xCoords[0]-xCoords[1],2) + pow(yCoords[0]-yCoords[1],2), 0.5);

Dialog.create("Scale Bar");
	Dialog.addMessage("How long is the scale bar?");
	Dialog.addNumber("Length, diameter or bounding box dimensions (e.g. in mm)", 0);
Dialog.show();

rulerLength = Dialog.getNumber();

letter = "Scale Bar:" + scaleLength + ":" + rulerLength;
roiManager("add");
roiManager("select",roiManager("count")-1);
roiManager("rename",letter);

run("Select None");


	



// STEP 5. Save
//........................................................

	//savePath = getInfo("log");
	//savePath = split(savePath, "\n");
	savePath = getMetadata("Info");
	//saveFlag = 0;

	if(endsWith(savePath, ".mspec") == false)
		savePath = File.openDialog("Select image config file");

	fileType = ".zip"; // seems to only want zips even with one selection
	savePath = replace(savePath, ".mspec", fileType); // replace .txt with either .roi or .zip as required

	selectionArray = newArray(roiManager("count"));

	for(i=0; i<roiManager("count"); i++)
		selectionArray[i] = i;

	roiManager("Select", selectionArray);

	roiManager("Save", savePath);

	showStatus("Done saving ROIs with multispectral image");
	
	print(" \nROIs saved to: " + savePath);

mspecGate=getBoolean("Are there more images to do?");

close();

}
