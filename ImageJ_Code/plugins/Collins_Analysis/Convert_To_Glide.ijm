fp = 62/197;
pxF = 5.6;

run("Duplicate...", "title=Glide duplicate");

w=getWidth();
h=getHeight();

//Set Glide Frame
glideFrame=parseInt(nSlices*fp);
setSlice(parseInt(nSlices*fp));
run("Copy"); setPasteMode("Copy");
for(i=0;i<nSlices;i++){
setSlice(i+1);
run("Paste");
t=-(i-glideFrame)*pxF;
run("Translate...", "x=0 y=&t interpolation=None slice");
if(t<0){ makeRectangle(0,h+t,w,abs(t)); run("Set...","value=88"); }
if(t>0){ makeRectangle(0,0,w,abs(t)); run("Set...","value=88"); }
run("Select None");
}

