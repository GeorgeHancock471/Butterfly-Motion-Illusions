//................................................................................
//Mirror GA butterfly
//................................................................................
//................................................................................
setBatchMode(true);

run("Select None");
run("32-bit");
setThreshold(1,255);
run("Create Selection");
run("Crop");
w=getWidth()*2;
h=getHeight();
run("Select None");
run("Copy");

run("Canvas Size...", "width=w height=h position=Center-Left zero");


makeRectangle(w/2,0,w/2,h);
run("Paste");
run("Flip Horizontally");
run("Select None");

setThreshold(1,255);
run("Create Selection");
run("Gaussian Blur...", "sigma=6");
run("Select None");

cH=1920*0.65;
cW=1080*0.65;
run("Canvas Size...", "width=cW height=cW position=Center zero");
//run("Size...", "width=500 height=500 depth=1 average interpolation=Bilinear");
