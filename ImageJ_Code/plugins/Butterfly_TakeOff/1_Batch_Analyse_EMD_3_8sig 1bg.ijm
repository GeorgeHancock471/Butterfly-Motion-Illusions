

bD=getDirectory("plugins")+"Butterfly_TakeOff/Backgrounds/"
B = getFileList(bD);

sD=getDirectory("plugins")+"Butterfly_TakeOff/TakeOff_EMD_Measure_8sig.csv";
//if(File.exists(sD)) File.delete(sD);

tA = newArray("ID","Pattern","Background","MeanV","Frame","Left","Right","Up","Down");
tAs = String.join(tA,",");
File.append(tAs,sD);

close("*");


//Load Files
D=getDirectory("Select Take Off Directory");
F=getFileList(D);

for(f=0;f<F.length;f++){
setBatchMode(true);
close("*");

D1=D+F[f]+"Rotated_Blank_Natural.tif";

D2 = D+F[f]+"Rotated_BackgroundMask.tif";



treatment=F[f];
treatment=replace(treatment,"\\","");
treatment=replace(treatment,"/","");

if(File.exists(D1) && File.exists(D2)){

//LOAD NATURAL
open(D1);
setBackgroundColor(0,0, 0);
run("Canvas Size...", "width=578 height=1300 position=Bottom-Center");



//CREATE AVERAGE
run("Select None");
run("Duplicate...", "title=Rotated_Blank_Average.tif  duplicate");
//get avg
m=0;
for(i=0;i<nSlices;i++){
setSlice(i+1);
setThreshold(1,255);
run("Create Selection");
m=m+getValue("Mean");
}

meanV=m/nSlices;

for(i=0;i<nSlices;i++){
setSlice(i+1);
setThreshold(1,255);
run("Create Selection");
run("Set...","value=meanV");
}


//CREATE WHITE
run("Select None");
run("Duplicate...", "title=Rotated_Blank_White.tif  duplicate");
for(i=0;i<nSlices;i++){
setSlice(i+1);
setThreshold(1,255);
run("Create Selection");
run("Set...","value=255");
}



//LOAD MASK
open(D2);
setBackgroundColor(1,1, 1);
run("Canvas Size...", "width=578 height=1300 position=Bottom-Center");



//BACKGROUNDS LOOP
for(b=0;b<B.length;b++){
open(bD+B[b]);
bType = File.getName(B[b]);
bType=replace(bType,".tif","");
print(bType);
rename(bType);

run("Clear Results");

sG = 8; // spatial Gaussian blur sigma (low pass only)
tG = 5; // temporal blur

//MASK BACKGROUND
imageCalculator("Multiply create stack", "Rotated_BackgroundMask.tif",bType);
rename("Masked_Background");



//BLACK

run("Duplicate...", "title=Temporal duplicate");
run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

setBatchMode("exit and display");
run("Elemental Motion Detector2");
upA=newArray(nSlices);
downA=newArray(nSlices);
leftA=newArray(nSlices);
rightA=newArray(nSlices);
selectWindow("Up Detectors");

selectWindow("Up Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
upA[i] = getValue("Mean");
}
selectWindow("Down Detectors");  setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
downA[i] = getValue("Mean");
}
selectWindow("Left Detectors");  setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
leftA[i] = getValue("Mean");
}
selectWindow("Right Detectors");  setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
rightA[i] = getValue("Mean");
}


for(i=0;i<nSlices;i++){
tA = newArray(treatment,"Black",bType,0,i,leftA[i],rightA[i],upA[i],downA[i]);
tAs = String.join(tA,",");

//print(tAs);
//print(sD);
File.append(tAs,sD);
}

close();
close();
close();
close();
close();


//Natural
imageCalculator("Add create stack", "Rotated_Blank_Natural.tif","Masked_Background");
rename("Natural");

run("Duplicate...", "title=Temporal duplicate");
run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

setBatchMode("exit and display");
run("Elemental Motion Detector2");
upA=newArray(nSlices);
downA=newArray(nSlices);
leftA=newArray(nSlices);
rightA=newArray(nSlices);
selectWindow("Up Detectors");

selectWindow("Up Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
upA[i] = getValue("Mean");
}
selectWindow("Down Detectors");  setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
downA[i] = getValue("Mean");
}
selectWindow("Left Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
leftA[i] = getValue("Mean");
}
selectWindow("Right Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
rightA[i] = getValue("Mean");
}


for(i=0;i<nSlices;i++){
tA = newArray(treatment,"Natural",bType,meanV,i,leftA[i],rightA[i],upA[i],downA[i]);
tAs = String.join(tA,",");

//print(tAs);
//print(sD);
File.append(tAs,sD);
}
close();
close();
close();
close();
close();


//Average
imageCalculator("Add create stack", "Rotated_Blank_Average.tif","Masked_Background");
rename("Avg");
run("Duplicate...", "title=Temporal duplicate");
run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

setBatchMode("exit and display");
run("Elemental Motion Detector2");
upA=newArray(nSlices);
downA=newArray(nSlices);
leftA=newArray(nSlices);
rightA=newArray(nSlices);
selectWindow("Up Detectors");

selectWindow("Up Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
upA[i] = getValue("Mean");
}
selectWindow("Down Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
downA[i] = getValue("Mean");
}
selectWindow("Left Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
leftA[i] = getValue("Mean");
}
selectWindow("Right Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
rightA[i] = getValue("Mean");
}


for(i=0;i<nSlices;i++){
tA = newArray(treatment,"Average",bType,meanV,i,leftA[i],rightA[i],upA[i],downA[i]);
tAs = String.join(tA,",");

//print(tAs);
//print(sD);
File.append(tAs,sD);
}
close();
close();
close();
close();
close();


//White
imageCalculator("Add create stack", "Rotated_Blank_White.tif","Masked_Background");
rename("White");
run("Duplicate...", "title=Temporal duplicate");
run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

setBatchMode("exit and display");
run("Elemental Motion Detector2");

upA=newArray(nSlices);
downA=newArray(nSlices);
leftA=newArray(nSlices);
rightA=newArray(nSlices);
selectWindow("Up Detectors");

selectWindow("Up Detectors");setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
upA[i] = getValue("Mean");
}
selectWindow("Down Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
downA[i] = getValue("Mean");
}
selectWindow("Left Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
leftA[i] = getValue("Mean");
}
selectWindow("Right Detectors"); setBatchMode("Hide");
for(i=0;i<nSlices;i++){
setSlice(i+1);
rightA[i] = getValue("Mean"); 
}


for(i=0;i<nSlices;i++){
tA = newArray(treatment,"White",bType,255,i,leftA[i],rightA[i],upA[i],downA[i]);
tAs = String.join(tA,",");

//print(tAs);
//print(sD);
File.append(tAs,sD);
}
close();
close();
close();
close();
close();




close("Masked_Background");
close(bType);
}


} //if
} // loop

waitForUser("Done");

