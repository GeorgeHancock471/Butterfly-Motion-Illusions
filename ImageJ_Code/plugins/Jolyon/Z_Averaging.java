import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;



public class Z_Averaging implements PlugInFilter {

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


	float[] pixels= new float[dim]; // temp array for loading
	float[] pxs = new float[dim*nz]; // array containing all pixel values across all slices


	//----------------Initialise Pixels-----------------------
	for(int i=0; i<nz; i++){
		pixels = (float[]) stack.getPixels(i+1);
		for(int j=0; j<dim; j++)
			pxs[(i*dim)+j] = pixels[j];
	}

	//double offMultiplier = 0.5; // weighting for the OFF-centre depolarising inhibiting the ON-centre. Higher values means OFF-centre ganlia will be more inhibitory
	float px1 = 0;
	float px2 = 0;

	ImageStack outStack = new ImageStack(w, h);

	for(int z=0; z<nz-1; z+=2){


		float[] onPX = new float[dim];
		float[] offPX = new float[dim];

		float[] tPX = new float[dim];

		for(int i=0; i<dim; i++){
			onPX[i] = 0;
			offPX[i] = 0;

			px1 = pxs[z*dim+i];
			px2 = pxs[(z+1)*dim+i];


			// technique assuming cross-inhibition - doesn't work well
			if(px1 >= 0 && px2 >= 0){  // both positive, select most positive
				if(px1 > px2)
					tPX[i] = px1;
				else tPX[i] = px2;
			} else if(px1 < 0 && px2 <0){  // both negative, select most negative
				if(px1 < px2)
					tPX[i] = px1;
				else tPX[i] = px2;
			} else {	// one negative, one positive
				tPX[i] = (px1 + px2)/2; // use average

				//if(px1 < px2) // assume the OFF channel is dominant
			//		tPX[i] = px1; 
			//	else tPX[i] = px2;
			}


			

		} //i

		outStack.addSlice("Z Averaged" + z, tPX);

	}

	new ImagePlus("Z Averaged", outStack).show();
}
}
