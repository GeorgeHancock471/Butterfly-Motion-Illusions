imageDIR = getDirectory("Directory: Select a 'folder of mspecs' or 'folder of mspec folders'");

fileList=getFileList(imageDIR);


FolderID=File.getName(imageDIR);


nOctaves=4;
nAngles=4;


for(F=0;F<fileList.length;F++){

while(roiManager("count")>0){
roiManager("select", newArray(roiManager("count")));
roiManager("delete");
}
close("*");

if(endsWith(fileList[F],".png")){

open(imageDIR+fileList[F]);

ImageID = getTitle();



run("Duplicate...", " ");
run("8-bit");
setThreshold(255,255);
run("Create Selection");
run("Make Inverse");
wl = getValue("Minor")/4;
roiManager("Add");
close();

roiManager("select",0);
run("Crop");

makeRectangle(0,0,getWidth()/2,getHeight());
run("Flip Horizontally", "slice");

run("Select None");

while(roiManager("count")>0){
roiManager("select", newArray(roiManager("count")));
roiManager("delete");
}


run("Duplicate...", " ");
run("8-bit");
setThreshold(255,255);
run("Create Selection");
run("Make Inverse");
wl = getValue("Minor")/4;
roiManager("Add");
close();




minS = Math.pow(2,(nOctaves));
rescale=minS/(wl);

w = getWidth();
h = getHeight();

w= w*(rescale);
h=h*(rescale);
run("Select None");

run("Select None");
run("Size...", "width=&w height=&h constrain average interpolation=Bilinear");


for(i=0; i<roiManager("count"); i++){
roiManager("select", i);
run("Scale... ", "x=&rescale y=&rescale");	
Roi.move(0,0);
if(selectionType != -1) roiManager("Update");
}//i


run("Lab Stack");
rename("Measure");

TitlesArray=newArray("FolderID","ImageID");
MeasuresArray = newArray(FolderID,ImageID);

channels=newArray("CIE_L","CIE_a","CIE_b");
scales=newArray("1/32","1/16","1/8","1/4");

for(i=0;i<3;i++){


//Selection
selectImage("Measure");
roiManager("Select", roiManager("count")-1);
setSlice(i+1);

//Mean

tS = channels[i] + "_Mean";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("Mean"));



//Gabor
run("Gabor ROI Bandpass Smooth", "number_of_angles=4 sigma=2 gamma=1 frequency=3 number_of_octaves=6 label=Measure");
rename("Gabor");


contrastMeasures = newArray(4);
angleMeasures = newArray(4);

verticalMeasures= newArray(4);
horizontalMeasures= newArray(4);

directionalityMeasures= newArray(4);


for(s=0;s<4;s++){
for(a=0;a<4;a++){

idx = s*4+a;

roiManager("Select", roiManager("count")-1);
setSlice(idx+1);
v=getValue("StdDev");
angleMeasures[a] = v;


tS = channels[i] + "_" + scales[s] + "_" + a*45;

TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,v);

}//a

Array.getStatistics(angleMeasures, min, max, mean, stdDev);

//Mean
tS = channels[i] + "_" + scales[s] +"_energy";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,mean);
contrastMeasures[s] = mean;

//Directionality
tS = channels[i] + "_" + scales[s] +"_directionality";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,stdDev);

directionalityMeasures[s] = max/mean;

verticalMeasures[s] = angleMeasures[0];
horizontalMeasures[s] = angleMeasures[2];

}//s


//Mean Dir
Array.getStatistics(directionalityMeasures, min, max, mean, stdDev);

tS = channels[i] +"_MeanDirect";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,mean);



//Mean Vert
Array.getStatistics(verticalMeasures, min, max, mean, stdDev);

tS = channels[i] +"_MeanVert";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,mean);

//Mean Horiz
Array.getStatistics(horizontalMeasures, min, max, mean, stdDev);

tS = channels[i] +"_MeanHoriz";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,mean);



Array.getStatistics(contrastMeasures, min, max, mean, stdDev);

//Mean Energy
tS = channels[i] +"_MeanEnergy";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,mean);





//MaxPower
tS = channels[i] +"_MaxPower";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,max);

maxima = Array.findMaxima(contrastMeasures,0);


//MaxFreq
tS = channels[i] +"_MaxFreq";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,(maxima[0]+1));

close("Gabor");

}
Array.show(TitlesArray,MeasuresArray);



// Phase 5, Save
//.................................................
//.................................................
//gate = getBoolean("Would you like to save your data", "yes", "no");

//if(gate){

d = imageDIR+FolderID+"_ResultsSplit.csv";
if(File.exists(d)){
new=0;
}else{
new =1;
}

TitleStr = String.join(TitlesArray,",");
MeasureStr = String.join(MeasuresArray,",");

if(new) File.append(TitleStr,d);
File.append(MeasureStr,d);

//waitForUser("Data Saved");

//}// gate


// Phase 6, Images
//.................................................
//.................................................
/*
gate = getBoolean("Would you like to create angle maps", "yes", "no");

if(gate){
selectImage("Measure");
roiManager("Select",roiManager("count")-1);
setSlice(1);
run("Angle Maps");



exit

}// gate
*/

}}

waitForUser("Done");


