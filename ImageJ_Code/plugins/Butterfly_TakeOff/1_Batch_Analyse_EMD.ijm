

bD=getDirectory("plugins")+"Butterfly_TakeOff/Backgrounds/"
B = getFileList(bD);

sD=getDirectory("plugins")+"Butterfly_TakeOff/Results.csv";
if(File.exists(sD)) File.delete(sD);

tA = newArray("ID","Pattern","Background","MeanV","Frame","Left","Right","Up","Down");
tAs = String.join(tA,",");
File.append(tAs,sD);

close("*");


//Load Files
D=getDirectory("Select Take Off Directory");
F=getFileList(D);

for(f=0;f<F.length;f++){
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



//MASK BACKGROUND
imageCalculator("Multiply create stack", "Rotated_BackgroundMask.tif",bType);
rename("Masked_Background");

//BLACK

run("Run Elemental Motion Detector", "low=4 high=8 temporal=5 output=5");
for(i=0;i<nResults;i++){
tA = newArray(treatment,"Black",bType,0,i,getResult("Left", i),getResult("Right", i),getResult("Up", i),getResult("Down", i));
tAs = String.join(tA,",");
File.append(tAs,sD);
}
close();
close();


//Natural
imageCalculator("Add create stack", "Rotated_Blank_Natural.tif","Masked_Background");
rename("Natural");
run("Run Elemental Motion Detector", "low=4 high=8 temporal=5 output=5");
for(i=0;i<nResults;i++){
tA = newArray(treatment,"Natural",bType,meanV,i,getResult("Left", i),getResult("Right", i),getResult("Up", i),getResult("Down", i));
tAs = String.join(tA,",");
File.append(tAs,sD);
}
close();
close();
close();

//Average
imageCalculator("Add create stack", "Rotated_Blank_Average.tif","Masked_Background");
rename("Avg");
run("Run Elemental Motion Detector", "low=4 high=8 temporal=5 output=5");
for(i=0;i<nResults;i++){
tA = newArray(treatment,"Average",bType,meanV,i,getResult("Left", i),getResult("Right", i),getResult("Up", i),getResult("Down", i));
tAs = String.join(tA,",");
File.append(tAs,sD);
}
close();
close();
close();

//White
imageCalculator("Add create stack", "Rotated_Blank_White.tif","Masked_Background");
rename("White");
run("Run Elemental Motion Detector", "low=4 high=8 temporal=5 output=5");
for(i=0;i<nResults;i++){
tA = newArray(treatment,"White",bType,255,i,getResult("Left", i),getResult("Right", i),getResult("Up", i),getResult("Down", i));
tAs = String.join(tA,",");
File.append(tAs,sD);
}
close();
close();
close();

close("Masked_Background");
close(bType);
}


} //if
} // loop

waitForUser("Done");

