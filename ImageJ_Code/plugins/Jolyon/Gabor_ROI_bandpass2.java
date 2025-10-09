import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;

import ij.measure.ResultsTable;

/*

-Convolve the original image parallel with its outline AND orthogonal to it.
-Disruption could be considered to be the ratio of parallel to orthogonal energy

Process:

-Extract image data
-Create mask of pixels inside ROI (black outside, white inside)
-Extract pixles that make up the edge of the target
-Convolve the edge of the MASK image (black & white object outline) to find the angle of the outline at this scale
-Convolve the original image around the edges at all angles
-Convert the gabor data to absolute values
-Find the dominant angle (max energy in mask gabor data)
-calculate the difference between the parallel and orthogonal image gabor data
i.e. difference = orthogonal/(orthogonal+parallel)
any values >0.5 would be disruptive, < 0.5 would create salient edges

This results in the "Edge Disruption Ratio", which says how much the patterns of the object and its background
disrupt or enhance its outline. In additon the "Edge Disruption Energy" is produced, which defines the contrast
of the edge of the target orthogonal to its outline. The two are likely to be correlated...



*/
public class Gabor_ROI_bandpass2 implements PlugIn {
public void run(String arg) {


	ImagePlus imp = IJ.getImage();

	// ---------------------- Calculate Gabor Filter Stuff-------------------------------

	int nAngles = 4;
	double sigma = 3.0;
	double gamma = 1.0;
	double Fx = 2.0;
	int nOctaves = 8;
	String imTitle = imp.getTitle();

	GenericDialog gd = new GenericDialog("GabRat Disruption Measurement");
		gd.addMessage("Gabor Filter Settings");
		gd.addNumericField("Number_of_angles", nAngles, 0);
		gd.addNumericField("Sigma", sigma, 2);
		gd.addNumericField("Gamma aspect ratio", gamma, 2);
		gd.addNumericField("Frequency", Fx, 2);
		gd.addNumericField("Number_of_octaves", nOctaves, 0);
		gd.addMessage("Output Images");
		gd.addCheckbox("Gabor Kernel", false);
		gd.addStringField("Label", imTitle, 20);

	gd.showDialog();
	if (gd.wasCanceled())
		return;

	
	nAngles = (int) Math.round(gd.getNextNumber());
	sigma = gd.getNextNumber();
	gamma = gd.getNextNumber();
	Fx = gd.getNextNumber();
	double psi = Math.PI / 4.0 * 2; // Phase
	nOctaves = (int) Math.round(gd.getNextNumber());

	boolean outputKernel = gd.getNextBoolean();

	imTitle = gd.getNextString();
	//int row = (int) Math.round(gd.getNextNumber());

	if(nAngles/2 != Math.round(nAngles/2))
		nAngles = nAngles -1;

	double sigma_x = sigma;
	double sigma_y = sigma / gamma;
	double largerSigma = 0.0; 

	// Decide size of the filters based on the sigma
	if(sigma_x > sigma_y)
		largerSigma = sigma_x;
	else largerSigma = sigma_y;

	if(largerSigma < 1)
		largerSigma = 1;

	double sigma_x2 = sigma_x * sigma_x;
	double sigma_y2 = sigma_y * sigma_y;

	int filterSizeX = (int) Math.round(6 * largerSigma + 1);
	int filterSizeY = (int) Math.round(6 * largerSigma + 1);
	int filterDim = filterSizeX*filterSizeY;

	float[] kernelArray = new float[(nAngles+1) * filterDim];


	int middleX = Math.round(filterSizeX / 2) + 1;
	int middleY = Math.round(filterSizeY / 2) + 1;



	double rotationAngle = Math.PI/nAngles;
	double theta = 0.0;
	double xPrime = 0.0;
	double yPrime = 0.0;
	double a = 0.0;
	double c = 0.0;

	
	ImageStack kernelStack = new ImageStack(filterSizeX, filterSizeY);
	
	for(int i=0; i<nAngles; i++){
		theta = rotationAngle * i;
		float[] kernelOutputArray = new float[filterSizeX * filterSizeY];

		for(int y=0; y<filterSizeY; y++){
			for(int x=0; x<filterSizeX; x++){
				xPrime = (x-middleX+1) * Math.cos(theta) + (y-middleY+1) * Math.sin(theta);
				yPrime = (y-middleY+1) * Math.cos(theta) - (x-middleX+1) * Math.sin(theta);
				a = 1.0 / ( 2.0 * Math.PI * sigma_x * sigma_y ) * Math.exp(-0.5 * (xPrime*xPrime / sigma_x2 + yPrime*yPrime / sigma_y2) );
				c = Math.cos( 2.0 * Math.PI * (Fx * xPrime) / filterSizeX + psi);
             				kernelArray[(i*filterDim)+(y*filterSizeX)+x] = (float) (a*c);
				kernelOutputArray[(y*filterSizeX)+x] = (float) (a*c);
			}//x
		}//y

		if(outputKernel == true)
			kernelStack.addSlice("angle " + i, kernelOutputArray);
		
	}// i (angles)

	if(outputKernel == true)
		new ImagePlus("Gabor Kernel", kernelStack).show();


	// --------------------- Get ROI Mask and Outline---------------------------------


	Roi roi = imp.getRoi();
	if (roi!=null && !roi.isArea()) roi = null;
	ImageProcessor ip = imp.getProcessor();
	ImageProcessor mask = roi.getMask();

	//Rectangle r = roi.getBounds():new Rectangle(0,0,ip.getWidth(),ip.getHeight());
	Rectangle r = roi.getBounds();

	int w = ip.getWidth();
	int h = ip.getHeight();


ImageStack outStack = new ImageStack(r.width, r.height);
double kernelSum = 0.0; // the kernel needs re-normalising with each pass
int kernelCount = 0;

float[] pixels = new float[r.width*r.height];
//int[] masks = new int[r.width*r.height];

for (int y=0; y<r.height; y++)
for (int x=0; x<r.width; x++)
if(mask.getPixel(x,y) != 0){
	pixels[x+ y*r.width] = ip.getPixelValue(x+r.x, y+r.y);
	//masks[x+ y*r.width] = 1;
}

/*
ImageStack pxStack = new ImageStack(r.width, r.height);
pxStack.addSlice("pixels", pixels);
//pxStack.addSlice("mask", masks);
new ImagePlus("ROI input", pxStack).show();
*/

/*
for(int j=0; j<nAngles; j++){


//IJ.log("nAngles=" + nAngles);

//int j=3;

double[] pixels2 = new double[r.width*r.height];
int[] counts = new int[r.width*r.height];
float[] outPxs = new float[r.width*r.height];

int loc = 0;
int pxloc = 0;

for(int y=0; y<r.height; y++)
for(int x=0; x<r.width; x++)
if(mask.getPixel(x,y) != 0){

	pxloc = (y*r.width)+x;

	// calculate kernel sum (it needs re-normalising at each point around the ROI)
	kernelSum = 0.0;
	kernelCount = 0;

	for(int y2=-middleY; y2<=middleY; y2++)  
	for(int x2=-middleX; x2<=middleX; x2++){
		if(mask.getPixel(x+x2,y+y2) != 0){
		//if(y+y2>=0 && y+y2< h && x+x2 >=0 &&x+x2 < w && mask.getPixel(x+x2,y+y2) != 0){
			loc = (j*filterDim) + ((y2+middleY)*filterSizeX) + (x2+middleX);
			kernelSum += kernelArray[loc];
			kernelCount++;
		}
	}

	kernelSum = kernelSum/kernelCount;

	for(int y2=-middleY; y2<=middleY; y2++)  
	for(int x2=-middleX; x2<=middleX; x2++){
		if(mask.getPixel(x+x2,y+y2) != 0){
		//if(y+y2>=0 && y+y2< h && x+x2 >=0 &&x+x2 < w && mask.getPixel(x+x2,y+y2) != 0){
			loc = (j*filterDim) + ((y2+middleY)*filterSizeX) + (x2+middleX);
			pixels2[pxloc] = pixels2[pxloc] + (pixels[x+x2 + (r.width*(y+y2))] * (kernelArray[loc]-kernelSum));
			counts[pxloc] ++;
		}
	}

	IJ.showProgress((float) y/r.height );
	
} // xy fi



for(int i=0; i<r.height*r.width; i++)
	outPxs[i] = (float) (pixels2[i]/counts[i]);

outStack.addSlice("output angle" + j, outPxs);

}//j angles

IJ.showProgress((float) 1);

//new ImagePlus("Gabor output", outStack).show();
*/



//-------------------------------- downscale pixels-------------------------------------
// sampling at an octave scale

int scaleRad = 1;

for(int k=0; k<nOctaves; k++){

scaleRad = (int) Math.pow(2, k);

/*
int scaleW = 0;
if( (double) (r.width/scaleRad) == (double) Math.round(r.width/scaleRad))
	scaleW = (int) Math.round(r.width/scaleRad);
else scaleW = (int) (Math.floor(r.width/scaleRad) +1);

int scaleH = 0;
if( (double) (r.height/scaleRad) == (double) Math.round(r.height/scaleRad))
	scaleH = (int) Math.round(r.height/scaleRad);
else scaleH = (int) (Math.floor(r.height/scaleRad) +1);
*/

int scaleW = (int) (Math.floor(r.width/scaleRad) +1);
int scaleH = (int) (Math.floor(r.height/scaleRad) +1);

double scaleSum = 0.0;
int scaleCount = 0;


float[] scalePixels = new float[scaleW*scaleH];
int[] scaleMask = new int[scaleW*scaleH];

for(int y=0; y<scaleH; y++)
for(int x=0; x<scaleW; x++){

	scaleSum = 0.0;
	scaleCount = 0;

	for(int y2 = 0; y2<scaleRad; y2++)
	for(int x2 = 0; x2<scaleRad; x2++)
	if(mask.getPixel(x2+x*scaleRad,y2+y*scaleRad) != 0){
		scaleSum += pixels[(x2+x*scaleRad) + (r.width*(y2+y*scaleRad))];
		scaleCount ++;
	} //x2 y2 fi

	if(scaleCount > 0){
		scalePixels[x+y*scaleW] = (float) (scaleSum/scaleCount);
		scaleMask[x+y*scaleW] = 1;
	}
} //xy

//ImageStack scaleStack = new ImageStack(scaleW, scaleH);
//scaleStack.addSlice("scaled pixels " + k, scalePixels);
//new ImagePlus("Scale " + scaleRad, scaleStack).show();


//-----------------Scale convolution-------------

//ImageStack scaleOutStack = new ImageStack(scaleW, scaleH);

for(int j=0; j<nAngles; j++){

//int j=3;

double[] pixels2 = new double[scaleW*scaleH];
int[] counts = new int[scaleW*scaleH];
float[] outPxs = new float[scaleW*scaleH];

int loc = 0;
int pxloc = 0;
int scaleLoc = 0;

for(int y=0; y<scaleH; y++)
for(int x=0; x<scaleW; x++)
if(scaleMask[x + scaleW*y] == 1){

	pxloc = (y*scaleW)+x;

	// calculate kernel sum (it needs re-normalising at each point around the ROI)
	kernelSum = 0.0;
	kernelCount = 0;

	for(int y2=-middleY; y2<=middleY; y2++)  
	for(int x2=-middleX; x2<=middleX; x2++){
		//if(mask.getPixel(x+x2,y+y2) != 0){
		if(y+y2>=0 && y+y2< scaleH && x+x2 >=0 &&x+x2 < scaleW && scaleMask[x + x2 + scaleW*(y+y2)] == 1){
			loc = (j*filterDim) + ((y2+middleY)*filterSizeX) + (x2+middleX);
			kernelSum += kernelArray[loc];
			kernelCount++;
		}
	}

	kernelSum = kernelSum/kernelCount;

	for(int y2=-middleY; y2<=middleY; y2++)  
	for(int x2=-middleX; x2<=middleX; x2++){
		//if(mask.getPixel(x+x2,y+y2) != 0){
		if(y+y2>=0 && y+y2< scaleH && x+x2 >=0 &&x+x2 < scaleW && scaleMask[x + x2 + scaleW*(y+y2)] == 1){
			loc = (j*filterDim) + ((y2+middleY)*filterSizeX) + (x2+middleX);
			scaleLoc = (int) Math.floor(x/scaleRad)+(x2/scaleRad) + (r.width*((int) Math.floor(y/scaleRad)+(y2/scaleRad)));
			//pixels2[pxloc] = pixels2[pxloc] + (pixels[x+x2 + (r.width*(y+y2))] * (kernelArray[loc]-kernelSum));
			pixels2[pxloc] = pixels2[pxloc] + (scalePixels[x+x2 + (scaleW*(y+y2))] * (kernelArray[loc]-kernelSum));
			counts[pxloc] ++;
		}
	}

	IJ.showProgress((float) y/r.height );
	
} // xy fi



for(int i=0; i<scaleH*scaleW; i++)
	outPxs[i] = (float) (pixels2[i]/counts[i]);

//scaleOutStack.addSlice("output angle" + j, outPxs);



//-----------------Apply to original scale (allows for easier measurement and weighting----------


float[] scaleOutPxs = new float[r.width*r.height];

for(int i=0; i<r.width*r.height; i++)
	scaleOutPxs[i] = Float.NaN;


for(int y=0; y<scaleH; y++)
for(int x=0; x<scaleW; x++)
if(scaleMask[x + scaleW*y] == 1)
	for(int y2 = 0; y2<scaleRad; y2++)
	for(int x2 = 0; x2<scaleRad; x2++)
	if(mask.getPixel(x2+x*scaleRad, y2 + y*scaleRad) != 0)
		//scaleOutPxs[ x2+x*scaleRad + r.width*(y2 +y*scaleRad)] = (float) (pixels2[x+scaleW*y]);
		scaleOutPxs[ x2+x*scaleRad + r.width*(y2 +y*scaleRad)] = (float) (pixels2[x+scaleW*y]/counts[x+scaleW*y]);

outStack.addSlice("scale" +k + " angle" + j, scaleOutPxs);

}//j angles

IJ.showProgress((float) 1);

//new ImagePlus("Scaled Gabor output", scaleOutStack).show();

}//k

new ImagePlus("Gabor output", outStack).show();

}
}
