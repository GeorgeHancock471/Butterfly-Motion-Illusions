if(isOpen("Gabor output")) close("Gabor output");
if(isOpen("X")) close("X");
if(isOpen("Y")) close("Y");


nAng=6;


//contrib=newArray(1/1,1/2,1/3,1/4,1/5,1/6);
contrib=newArray(1,1,1,1,1,1);

//per = newArray(1,0.6,0.2,-0.2,-0.6,-1);
//per = newArray(1,2,3,4,5,6);
per = newArray(1/1,1/2,1/3,1/4,1/5,1/6);

selectImage("Temp");
run("Gabor ROI Bandpass Smooth", "number_of_angles="+nAng+" sigma=2 gamma=1 frequency=3 number_of_octaves=6 label=Gabor");

run("Abs", "stack");
run("Duplicate...", "title=X duplicate");
run("Duplicate...", "title=Y duplicate");


//X
selectImage("X");
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


//Y
selectImage("Y");
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




