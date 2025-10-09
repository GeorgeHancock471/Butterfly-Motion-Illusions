imageDIR = getDirectory("Directory: Select a 'folder of mspecs' or 'folder of mspec folders'");

fileList=getFileList(imageDIR);

rotateMode=0;

FolderID=File.getName(imageDIR);

d = imageDIR+FolderID+"_NewMeasure.csv";
if(File.exists(d)) File.delete(d);


nOctaves=4;
nAngles=4;


for(F=0;F<fileList.length;F++){
setBatchMode(true);

close("*");

while(roiManager("count")>0){
roiManager("select", newArray(roiManager("count")));
roiManager("delete");
}
close("*");

if(endsWith(fileList[F],".png")){

open(imageDIR+fileList[F]);

ImageID = getTitle();

rename("Measure");

run("Duplicate...", " ");
rename("Mask");
run("8-bit");
setThreshold(255,255);
run("Create Selection");
run("Make Inverse");
wl = getValue("Minor")/4;
a = getValue("Angle")-90;
roiManager("Add");
roiManager("select",0);
run("Set...","value=0");
run("Make Inverse");
run("Set...","value=255");
run("Crop");

selectImage("Measure");
roiManager("select",0);


minS = Math.pow(2,(nOctaves));
rescale=minS/(wl);

w = getWidth();
h = getHeight();

w= w*(rescale);
h=h*(rescale);
run("Select None");

run("Select None");
if(rotateMode)run("Rotate... ", "angle=&a grid=1 interpolation=None fill enlarge");
run("Size...", "width=&w height=&h constrain average interpolation=Bilinear");


selectImage("Mask");
run("Select None");
if(rotateMode)run("Rotate... ", "angle=&a grid=1 interpolation=None fill enlarge");
run("Size...", "width=&w height=&h constrain average interpolation=Bilinear");

while(roiManager("count")>0){
roiManager("select", newArray(roiManager("count")));
roiManager("delete");
}

setThreshold(0,0);
run("Create Selection");
wl = getValue("Minor")/4;
roiManager("Add");
roiManager("select",0);
run("Crop");
run("Select All");
run("Copy"); 
run("Invert");setPasteMode("Copy"); close();


selectImage("Measure");
roiManager("select",0);
run("Crop");
roiManager("select",0);

Roi.move(0,0);
roiManager("update");




run("Lab Stack");
rename("Measure");
setBatchMode("show");

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


tS = channels[i] + "_StdDev";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));



run("Duplicate...", " ");
run("Duplicate...", " ");
if(i==0){
run("Min...","value=50");
tS = channels[i] + "_High";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));
close();
run("Max...","value=50");
tS = channels[i] + "_Low";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));
close();
}else{
run("Min...","value=0");
tS = channels[i] + "_High";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));
close();
run("Max...","value=0");
tS = channels[i] + "_Low";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));
close();
}





nAng=6;
nOct=4;

contrib=newArray(1/1,1/2,1/3,1/4,1/5,1/6);
per = newArray(1/4,1/8,1/16,1/32);

run("DoG ROI bandpass smooth Plugin", "sigma1=1 sigma2=1.6 number_of_octaves=4 label=Sum_All");

//Periodicity!
//.......................................
rename("P");

run("Abs","stack");
for(s=0;s<4;s++){
setSlice(s+1);
c=contrib[s];
run("Multiply...","value=c");
}

run("Duplicate...", "title=Sum duplicate");
for(s=0;s<4-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
} run("Copy");  setPasteMode("Divide");
close();

for(s=0;s<4;s++){
setSlice(s+1);
run("Paste");
p=per[s];
run("Multiply...","value=p");
}

for(s=0;s<4-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}

roiManager("Select", roiManager("count")-1);
tS = channels[i] + "_Period_Mean";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("Mean"));
tS = channels[i] + "_Period_StdDev";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));

close("P");



//Patterning
//.......................................

selectImage("Measure");
roiManager("Select", roiManager("count")-1);
run("Gabor ROI Bandpass Smooth", "number_of_angles="+nAng+" sigma=2 gamma=1 frequency=3 number_of_octaves="+nOct+" label=Gabor");


run("Abs", "stack");
run("Duplicate...", "title=X duplicate");
run("Duplicate...", "title=Y duplicate");
run("Duplicate...", "title=O duplicate");
run("Duplicate...", "title=A duplicate");




//X
selectImage("X");
for(s=0;s<nOct;s++){
for(a=0;a<nAng;a++){
setSlice(s*nAng+a+1);
ang=a*(180/nAng)/180*PI;
c=contrib[s];
run("Macro...", "code=v=sin("+ang+")*v*"+c+" slice");

}}



run("Abs", "stack");
for(s=0;s<nOct*nAng-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}


//Y
selectImage("Y");
for(s=0;s<nOct;s++){
for(a=0;a<nAng;a++){
setSlice(s*nAng+a+1);
ang=a*(180/nAng)/180*PI;
c=contrib[s];
run("Macro...", "code=v=cos("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(s=0;s<nOct*nAng-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}



//A
selectImage("A");
for(s=0;s<nOct;s++){
for(a=0;a<nAng;a++){
setSlice(s*nAng+a+1);
ang=(a*(180/nAng)-45)/180*PI;
c=contrib[s];
run("Macro...", "code=v=cos("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(s=0;s<nOct*nAng-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}

//O
selectImage("O");
for(s=0;s<nOct;s++){
for(a=0;a<nAng;a++){
setSlice(s*nAng+a+1);
ang=(a*(180/nAng)-45)/180*PI;
c=contrib[s];
run("Macro...", "code=v=sin("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(s=0;s<nOct*nAng-1;s++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}


selectImage("Y");
run("Duplicate...", "title=VH duplicate");
selectImage("X"); run("Copy"); setPasteMode("Subtract");
selectImage("VH"); run("Paste");

roiManager("Select", roiManager("count")-1);
tS = channels[i] + "_VH_Mean";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("Mean"));
tS = channels[i] + "_VH_StdDev";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));


run("Enhance Contrast...", "saturated=0.35");
run("Duplicate...", "title=T1 duplicate");
run("Square");

selectImage("O");
run("Duplicate...", "title=OA duplicate");
selectImage("A"); run("Copy"); setPasteMode("Subtract");
selectImage("OA"); run("Paste");

run("Enhance Contrast...", "saturated=0.35");
run("Duplicate...", "title=T2 duplicate");
run("Square");


selectImage("Y");
run("Duplicate...", "title=E duplicate");
selectImage("X"); run("Copy"); setPasteMode("Add");
selectImage("E"); run("Paste");
selectImage("O"); run("Copy"); setPasteMode("Add");
selectImage("E"); run("Paste");
selectImage("A"); run("Copy"); setPasteMode("Add");
selectImage("E"); run("Paste");
run("Grays");
run("Divide...","value=4");
run("Enhance Contrast...", "saturated=0.35");




roiManager("Select", roiManager("count")-1);
tS = channels[i] + "_Energy_Mean";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("Mean"));
tS = channels[i] + "_Energy_StdDev";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));



selectImage("T1"); run("Copy"); setPasteMode("Add"); close();
selectImage("T2"); run("Paste");
run("Square Root"); 
rename("DR");
selectImage("E");
run("Duplicate...", "title=T duplicate"); run("Divide...","value=2.5"); run("Copy"); setPasteMode("Subtract"); close();
selectImage("DR"); run("Paste");



roiManager("Select", roiManager("count")-1);
tS = channels[i] + "_SpotStripe_Mean";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("Mean"));
tS = channels[i] + "_SpotStripe_StdDev";
TitlesArray=Array.concat(TitlesArray,tS);
MeasuresArray=Array.concat(MeasuresArray,getValue("StdDev"));


close();
close();
close();
close();
close();
close();
close();
close();
close();




}
Array.show(TitlesArray,MeasuresArray);



// Phase 5, Save
//.................................................
//.................................................
//gate = getBoolean("Would you like to save your data", "yes", "no");

//if(gate){


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


