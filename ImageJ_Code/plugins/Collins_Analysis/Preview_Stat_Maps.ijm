
run("Crop Rescale ROI", " ");
//rename("crop");

roiManager("select",roiManager("count")-1);
run("Make Inverse");
run("Set...","value=87");
run("Select None");
run("Gaussian Blur...", "sigma=6");
roiManager("select",roiManager("count")-1);




// Produce Sum Channels


if(isOpen("Gabor output")) close("Gabor output");
if(isOpen("X")) close("X");
if(isOpen("Y")) close("Y");
if(isOpen("O")) close("O");
if(isOpen("A")) close("A");
if(isOpen("VH")) close("VH");
if(isOpen("OA")) close("OA");
if(isOpen("DR")) close("DR");
if(isOpen("E")) close("E");
if(isOpen("P")) close("P");
if(isOpen("Ang")) close("Ang");

if(isOpen("Periodicity")) close("Periodicity");
if(isOpen("Contrast")) close("Contrast");
if(isOpen("Orientation")) close("Orientation");
if(isOpen("Stripe-Spot")) close("Stripe-Spot");
if(isOpen("Gradiation")) close("Gradiation");

//setBatchMode(true);
mR=0;


nAng=6;

contrib=newArray(1/1,1/2,1/3,1/4,1/5,1/6);
contrib=newArray(1,1,1,1,1,1);

//per = newArray(1,0.6,0.2,-0.2,-0.6,-1);
per = newArray(1,2,3,4,5,6);
per = newArray(1/1,1/2,1/3,1/4,1/5,1/6);

roiManager("select",roiManager("count")-1);
run("DoG ROI bandpass smooth Plugin", "sigma1=1 sigma2=1.6 number_of_octaves=6 label=Sum_All");
rename("P");
run("Abs","stack");
for(i=0;i<6;i++){
setSlice(i+1);
c=contrib[i];
run("Multiply...","value=c");
}

//run("Add...","value=1 stack"); 

run("Duplicate...", "title=Sum duplicate");
for(i=0;i<6-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
} run("Copy");  setPasteMode("Divide");
close();

for(i=0;i<6;i++){
setSlice(i+1);
run("Paste");
p=per[i];
run("Multiply...","value=p");
}

for(i=0;i<6-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}

setBatchMode("show");
run("Gem");
run("Enhance Contrast...", "saturated=0.35");


selectImage("Temp");
roiManager("select",roiManager("count")-1);
run("Gabor ROI Bandpass Smooth", "number_of_angles="+nAng+" sigma=2 gamma=1 frequency=3 number_of_octaves=6 label=Gabor");

//run("Min...","value=0 stack");
run("Abs", "stack");
run("Duplicate...", "title=X duplicate");
run("Duplicate...", "title=Y duplicate");
run("Duplicate...", "title=O duplicate");
run("Duplicate...", "title=A duplicate");


//X
selectImage("X");
for(i=0;i<6;i++){
for(j=0;j<nAng;j++){
setSlice(i*nAng+j+1);
ang=j*(180/nAng)/180*PI;
c=contrib[i];
run("Macro...", "code=v=sin("+ang+")*v*"+c+" slice");

}}
run("Abs", "stack");
for(i=0;i<6*nAng-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}


//Y
selectImage("Y");
for(i=0;i<6;i++){
for(j=0;j<nAng;j++){
setSlice(i*nAng+j+1);
ang=j*(180/nAng)/180*PI;
c=contrib[i];
run("Macro...", "code=v=cos("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(i=0;i<6*nAng-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}



//A
selectImage("A");
for(i=0;i<6;i++){
for(j=0;j<nAng;j++){
setSlice(i*nAng+j+1);
ang=(j*(180/nAng)-45)/180*PI;
c=contrib[i];
run("Macro...", "code=v=cos("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(i=0;i<6*nAng-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}

//O
selectImage("O");
for(i=0;i<6;i++){
for(j=0;j<nAng;j++){
setSlice(i*nAng+j+1);
ang=(j*(180/nAng)-45)/180*PI;
c=contrib[i];
run("Macro...", "code=v=sin("+ang+")*v*"+c+" slice");
}}
run("Abs", "stack");
for(i=0;i<6*nAng-1;i++){
run("Copy"); setPasteMode("Add");
run("Delete Slice");run("Paste");
}


selectImage("Y");
run("Duplicate...", "title=VH duplicate");
selectImage("X"); run("Copy"); setPasteMode("Subtract");
selectImage("VH"); run("Paste");

run("Viridis");
run("Enhance Contrast...", "saturated=0.35");
//setBatchMode("show");
run("Duplicate...", "title=T1 duplicate");
run("Square");

selectImage("O");
run("Duplicate...", "title=OA duplicate");
selectImage("A"); run("Copy"); setPasteMode("Subtract");
selectImage("OA"); run("Paste");

run("Viridis");
run("Enhance Contrast...", "saturated=0.35");
//setBatchMode("show");
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
setBatchMode("show");

selectImage("T1"); run("Copy"); setPasteMode("Add"); close();
selectImage("T2"); run("Paste");
run("Square Root"); 
rename("DR");
selectImage("E");
run("Duplicate...", "title=T duplicate"); run("Divide...","value=2.5");  run("Copy"); setPasteMode("Subtract"); close();
selectImage("DR"); run("Paste"); setBatchMode("show");

selectImage("VH");setBatchMode("show");
selectImage("OA"); setBatchMode("show");








