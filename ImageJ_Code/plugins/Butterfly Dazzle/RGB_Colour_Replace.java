/*

-----------------------------RGB Colour Replace--------------------

Replaces foreground colour with background colour







*/




import ij.plugin.filter.PlugInFilter;
import ij.*;
import ij.gui.*;
import ij.process.*;
import ij.measure.*;
import java.awt.*;


public class RGB_Colour_Replace implements PlugInFilter {

ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	return DOES_RGB; 
	}

public void run(ImageProcessor ip) {


	int w = stack.getWidth();
	int h = stack.getHeight();
	int d = stack.getSize();


	int fgCol = Toolbar.getForegroundColor().getRGB();
	int bgCol = Toolbar.getBackgroundColor().getRGB();

	//int[] pixels =(int[]) ip.getPixels();

	for(int i=1; i<=d; i++){
		int[] pixels =(int[]) stack.getPixels(i);

		for(int j=0; j<w*h; j++){

			if(pixels[j] == fgCol)
				pixels[j] = bgCol;

		}//j
	}//i

}
}
