close("*");
setBatchMode(false);
open();
t=getTitle();

run("Overlay To ROI");
run("Convert to DBL");
roiManager("select",0);
run("Crop Rescale ROI", " ");

setBatchMode(true);
run("X Y O A Maps");


print("T =", t);

selectImage("E");
roiManager("select",roiManager("count")-1);
v=getValue("Mean");
print("E =", v);

selectImage("Y-X");
roiManager("select",roiManager("count")-1);
v=getValue("Mean");
print("Y_X =", v);

selectImage("A-O");
v=getValue("Mean");
roiManager("select",roiManager("count")-1);
print("A_O =", v);

selectImage("Stripe-Spot");
v=getValue("Mean");
roiManager("select",roiManager("count")-1);
print("Stripe-Spot =", v);

selectImage("Anisotropy");
v=getValue("Mean");
roiManager("select",roiManager("count")-1);
print("Anisotropy =", v);

setBatchMode("exit and display");
