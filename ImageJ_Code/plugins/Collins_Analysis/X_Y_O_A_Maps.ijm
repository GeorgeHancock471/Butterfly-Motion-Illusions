if(isOpen("Gabor output")) close("Gabor output");
if(isOpen("X")) close("X");
if(isOpen("Y")) close("Y");
if(isOpen("O")) close("O");
if(isOpen("A")) close("A");
if(isOpen("Y-X")) close("Y-X");
if(isOpen("A-O")) close("A-O");
if(isOpen("D")) close("D");
if(isOpen("Stripe-Spot")) close("Stripe-Spot");
if(isOpen("Anisotropy")) close("Anisotropy");
if(isOpen("E")) close("E");
setBatchMode(true);

nAng=4;


contrib=newArray(1/1,1/2,1/3,1/4,1/5,1/6);
contrib=newArray(1,1,1,1,1,1);

//per = newArray(1,0.6,0.2,-0.2,-0.6,-1);
//per = newArray(1,2,3,4,5,6);
per = newArray(1/1,1/2,1/3,1/4,1/5,1/6);

selectImage("Temp");
roiManager("select",roiManager("count")-1);
run("Gabor ROI Bandpass Smooth", "number_of_angles="+nAng+" sigma=2 gamma=1 frequency=3 number_of_octaves=6 label=Gabor");

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

run("Duplicate...", "title=E");
selectImage("O"); run("Copy"); setPasteMode("Add"); 
selectImage("E"); run("Paste");
selectImage("X"); run("Copy"); setPasteMode("Add"); 
selectImage("E"); run("Paste");
selectImage("Y"); run("Copy"); setPasteMode("Add"); 
selectImage("E"); run("Paste");
run("Divide...","value=4");


selectImage("A");
run("Duplicate...", "title=Anisotropy");

selectImage("O"); run("Copy"); setPasteMode("Max");
selectImage("Anisotropy"); run("Paste");

selectImage("X"); run("Copy"); setPasteMode("Max");
selectImage("Anisotropy"); run("Paste");

selectImage("Y"); run("Copy"); setPasteMode("Max");
selectImage("Anisotropy"); run("Paste");





imageCalculator("Subtract create", "Y","X");
rename("Y-X");
run("Duplicate...", "title=Y-X-Sq");
run("Square");


imageCalculator("Subtract create", "A","O");
rename("A-O");
run("Duplicate...", "title=A-O-Sq");
run("Square");

imageCalculator("Add create", "Y-X-Sq","A-O-Sq");
rename("D");
run("Square Root");
close("A-O-Sq");
close("Y-X-Sq");


imageCalculator("Add", "X","Y");
imageCalculator("Add", "X","O");
imageCalculator("Add", "X","A");
selectImage("X");

v=10;
run("Divide...","value=v");

run("Copy"); setPasteMode("Subtract");
selectImage("D");
run("Duplicate...", "title=Stripe-Spot");
run("Paste");
roiManager("select",roiManager("count")-1);
getStatistics(area,mean,min,max,dev);
m1=parseFloat(-dev);
m2=parseFloat(dev);

tS="min="+m1+" max="+m2;

run("Set Min And Max", tS);
run("Viridis");


selectImage("E"); run("Copy"); setPasteMode("Divide");
selectImage("Anisotropy"); run("Paste");
run("Subtract...","value=1");
setBatchMode("exit and display");




