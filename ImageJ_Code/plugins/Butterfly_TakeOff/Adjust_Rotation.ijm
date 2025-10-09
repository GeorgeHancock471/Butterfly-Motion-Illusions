roiManager("select",0);
Roi.getCoordinates(x0,y0);

roiManager("select",1);
Roi.getCoordinates(x1,y1);


makeLine(x0[0],y0[0],x1[0],y1[0]);
waitForUser("");

A=getValue("Angle")-90;
run("Rotate... ", "angle=&A grid=1 interpolation=Bilinear fill enlarge stack");
floodFill(0, 36);
