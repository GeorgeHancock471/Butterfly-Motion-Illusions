getSelectionCoordinates(xs, ys);
w= getWidth();
h=getHeight();


for(i=0; i<xs.length; i++)
	xs[i] = w-xs[i];

makeSelection("polygon", xs, ys);
//makeSelection("line", xs, ys);

