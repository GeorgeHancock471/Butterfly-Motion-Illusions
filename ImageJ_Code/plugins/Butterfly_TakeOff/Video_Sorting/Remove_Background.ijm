//Remove BG
//.............................
setBatchMode(true);

run("Duplicate...", "duplicate");
t=getTitle();


nS=nSlices();
w=getWidth();
h=getHeight();


setBatchMode(false);


setSlice(1); run("Duplicate...", "title=S");
selectImage(t);
setSlice(nSlices); run("Duplicate...", "title=E");



for(i=0;i<nSlices;i++){
if(i==0){
selectImage("E");
run("Copy"); setPasteMode("Difference");
}

if(i==floor(nS/2)){
selectImage("S");
 run("Copy"); setPasteMode("Difference");
}

selectImage(t);
setSlice(i+1);
run("Paste");
}


for(i=0;i<nSlices;i++){
setSlice(i+1);
if(i<floor(nS/2)){
makeRectangle(0,0,w,h/4);
}else{
makeRectangle(0,h*3/4,w,h/4);
}
run("Set...","value=0");

}
setBatchMode("show");
