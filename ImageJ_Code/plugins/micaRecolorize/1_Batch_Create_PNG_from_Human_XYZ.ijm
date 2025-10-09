//Get MSPEC List
//...............................................................................................................


// LISTING CONE CATCH MODELS

	modelPath = getDirectory("plugins")+"Cone Models";
	modelList=getFileList(modelPath);
	modelNames = newArray();

Array.show(modelList);

	for(i=0; i<modelList.length; i++){
		if(endsWith(modelList[i], ".class")==1 && indexOf(modelList[i],"XYZ")!=-1)
			modelNames = Array.concat(modelNames,replace(modelList[i],".class",""));
		if(endsWith(modelList[i], ".CLASS")==1 && indexOf(modelList[i],"XYZ")!=-1)
			modelNames = Array.concat(modelNames,replace(modelList[i],".CLASS",""));
	}
	
	for(i=0; i<modelNames.length; i++)
		modelNames[i] = replace(modelNames[i], "_", " ");


// PRESCRIPTS

prePath = getDirectory("plugins")+"micaRecolorize/Pre_Scripts";
preList=getFileList(prePath);
preList=Array.concat("None",preList);

for(i=0;i<preList.length;i++){
v=preList[i];
v=replace(v,".txt","");
v=replace(v,".ijm","");
preList[i]=v;
}


Array.show(modelNames);

Dialog.create("Settings:");
Dialog.addMessage("Note, you should have already made a human XYZ model for your camera");
Dialog.addNumber("Scale %", 0.50);
Dialog.addChoice("Select XYZ Camera Model",modelNames);
Dialog.addChoice("PreScript, e.g., 'rotate to major'. 'None' if no scipt",preList, "None");
Dialog.show();


imageDIR = getDirectory("Directory: Select a 'folder of mspecs' '");

fileList=getFileList(imageDIR);
mspecList= newArray();

for(i=0; i<fileList.length; i++){ // list only mspec files
	if(endsWith(fileList[i], "mspec") || endsWith(fileList[i], "mspec "))  mspecList=Array.concat( mspecList,fileList[i]);
}

Array.show(mspecList,fileList);

scale=Dialog.getNumber();
coneMethod = Dialog.getChoice(); 
Prescript = Dialog.getChoice();		// 7
Prescript = replace(Prescript,"_"," ");
Prescript = replace(Prescript,".txt","");


//Create PNG folders
//...............................................................................................................

folderPNG=imageDIR+"PNG/" 

File.makeDirectory(folderPNG);

dataPNG = imageDIR + "Human_Colour_Data.txt";
if(File.exists(dataPNG)) File.delete(dataPNG);

titles = newArray("MSPEC","ROI","CIE_L","CIE_a", "CIE_b", "R","G","B");
titlesS = String.join(titles,"\t"); 
File.append(titlesS, dataPNG);


//Loop Through MSPECs
//...............................................................................................................

for(nm=0;nm<mspecList.length;nm++){

close("*");

imageString = "select=[" +  imageDIR  + mspecList[nm] + "] image=[Linear Normalised Reflectance Stack]"; //Load MSPEC
setPasteMode("Copy"); //Mspecs break if paste mode isn't copy
		
run(" Load Multispectral Image", imageString);
imgName = getTitle();

coneString="model=["+coneMethod+"] desaturate desaturation=0.010 remove replace=0.001";

if(Prescript != "None"){
			run(Prescript);
		}

w=getWidth()*scale;
h=getHeight()*scale;

nS=nSlices;

run("Size...", "width=&w height=&h depth=&nS average interpolation=Bilinear");

for(i=0;i<roiManager("count");i++){
roiManager("select",i);
run("Scale... ", "x=&scale y=&scale");
roiManager("Update");
roiManager("deselect");
}


run("Convert to Cone Catch", coneString);

run("XYZ to CIELAB 32Bit");
rename("CIELAB");

run("CIELAB 32Bit to RGB24 smooth");
rename("Colour");

for(i=0;i<roiManager("Count"); i++){
roiManager("Select", i);
roiName = getInfo("selection.name");
if(!startsWith(roiName, "Scale")){ 

selectImage("CIELAB");
roiManager("Select", i);
selectImage("CIELAB");
CIE = newArray(3);
for(s=0;s<3;s++){
setSlice(s+1);
CIE[s] = getValue("Mean");
}


selectImage("Colour");
roiManager("Select", i);
run("Duplicate...", "title=Temp");
Roi.move(0,0);
run("Make Inverse");
run("Set...", "value=0");


run("RGB Stack");
roiManager("Select", i);
Roi.move(0,0);
RGB= newArray(3);
for(s=0;s<3;s++){
setSlice(s+1);
RGB[s] = getValue("Mean");
}

setSlice(3);
run("Add Slice");
run("Set Label...", "label=Alpha");
roiManager("Select", i);
Roi.move(0,0);
setSlice(4);
run("Set...","value=255");


saveAs("PNG", folderPNG+imgName+"_"+roiName+".png");

close();

measures = newArray(imgName,roiName);
measures=Array.concat(measures,CIE, RGB);
measuresS = String.join(measures,"\t"); 
File.append(measuresS, dataPNG);



}

}


} // End Loop

waitForUser("DONE");
