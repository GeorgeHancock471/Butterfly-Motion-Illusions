

for(z=0;z<roiManager("count");z++){

roiManager("select",z);
if(!startsWith(Roi.getName,"Scale")){

Roi.getBounds(x,y,w,h);
A=getValue("Angle");

cx=x+w/2;
cy=y+h/2;

D=pow(pow(w,2)+pow(h,2),0.5);

makeRectangle(cx-D/2,cy-D/2,D,D);

run("Rotate... ", "angle=&A grid=1 interpolation=Bilinear");
roiManager("select",z);
run("Rotate...", "  angle=&A ");
roiManager("Update");
}
}

run("Select None");
