import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;



public class Elemental_Motion_Detector2 implements PlugInFilter {

ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	return DOES_32 + STACK_REQUIRED; 
	}

public void run(ImageProcessor ip) {


	int w = stack.getWidth();
	int h = stack.getHeight();
	int nz = stack.getSize();
	int dim = w*h;

	String[] sliceNames = new String[nz];
	sliceNames = stack.getSliceLabels();

	float[] pixels= new float[dim]; // temp array for loading
	float[] pxs = new float[dim*nz]; // array containing all pixel values across all slices


	double Lpx0 = 0.0;
	double Lpx1 = 0.0;
	double Bpx0 = 0.0;
	double Bpx1 = 0.0;
	double Rpx0 = 0.0;
	double Rpx1 = 0.0;
	int loc = 0;

	//----------------Initialise Pixels-----------------------
	for(int i=0; i<nz; i++){
		pixels = (float[]) stack.getPixels(i+1);
		for(int j=0; j<dim; j++)
			pxs[(i*dim)+j] = pixels[j];
	}

	//---------------Motion Detectors-----------------

	ImageStack rStack = new ImageStack(w, h);
	ImageStack lStack = new ImageStack(w, h);
	ImageStack uStack = new ImageStack(w, h);
	ImageStack dStack = new ImageStack(w, h);
	double hDet = 0.0;
	double vDet = 0.0;

	for(int z=0; z<nz-1; z++){


		float[] lDet = new float[w*h]; // left motion detectors
		float[] rDet = new float[w*h]; // right motion detectors
		float[] uDet = new float[w*h]; // up motion detectors
		float[] dDet = new float[w*h]; // down motion detectors

		for(int y=0; y<h-1; y++){
		for(int x=0; x<w-1; x++){
			loc = (z*dim)+(y*w)+x;
			Lpx0 = pxs[loc]; //focal pixel
			Rpx0 = pxs[loc+1]; //right pixel
			Lpx1 = pxs[loc+dim]; //focal pixel next frame
			Rpx1 = pxs[loc+1+dim]; //right pixel
			Bpx0 = pxs[loc+w]; //bottom pixel
			Bpx1 = pxs[loc+w+dim]; //bottom pixel

			//hDet[(y*w)+x] = (float) (     (Lpx0 - Lpx1)  * (Lpx0-Rpx1)   + (-1* (Rpx0 - Rpx1)  * (Rpx0-Lpx1) )  ) ;
			//vDet[(y*w)+x] = (float) (      (Lpx0 - Lpx1)  * (Lpx0-Bpx1)   + (-1* (Bpx0 - Bpx1)  * (Bpx0-Lpx1) )  ) ;

			hDet = (Lpx0 - Lpx1)  * (Lpx0-Rpx1)   + (-1* (Rpx0 - Rpx1)  * (Rpx0-Lpx1) );
			vDet = (Lpx0 - Lpx1)  * (Lpx0-Bpx1)   + (-1* (Bpx0 - Bpx1)  * (Bpx0-Lpx1) );


			//-----Create separate left, right, up and down detectors------
			if(hDet > 0)
				lDet[(y*w)+x] = (float) (hDet);
			else rDet[(y*w)+x] = (float) (hDet * -1);

			if(vDet > 0)
				uDet[(y*w)+x] = (float) (vDet);
			else dDet[(y*w)+x] = (float) (vDet * -1);



		} //x
		} //y


		lStack.addSlice(sliceNames[z], lDet);
		rStack.addSlice(sliceNames[z], rDet);
		uStack.addSlice(sliceNames[z], uDet);
		dStack.addSlice(sliceNames[z], dDet);

	}


	new ImagePlus("Left Detectors", lStack).show();
	new ImagePlus("Right Detectors", rStack).show();
	new ImagePlus("Up Detectors", uStack).show();
	new ImagePlus("Down Detectors", dStack).show();
}
}
