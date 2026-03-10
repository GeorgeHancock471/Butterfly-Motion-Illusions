This README.md file was generated on 2025.10.07 [yyy,mm,dd] by George RA Hancock

# 1) GENERAL INFORMATION
---------------------------------------------------------------------------------------------------------------------------------------------------------

1. Title of Dataset: Biologically inspired warning patterns deter birds from wind turbines.

2. Author Information
	A. Principal Investigator Contact Information
		Name: Jolyon Troscianko
		Institution: University of Exeter
		Email: J.Troscianko@exeter.ac.uk
		
	B. Primary Author Contact Information
		Name: George Hancock
		Institution: University of Exeter
		Email: ghancockzoology@gmail.com		
		

3. Date of data collection.  2018 - 2026 

4. Data collection location: 

	Butterfly Flight Recording
		- France (Mareil-Marly, 78750)
		
	Butterfly EMD Measures
		- University of Exeter, Penryn Campus (50.1710° N, 5.1238° W)
		
	Butterfly Behavioural Experiments
		- University of Exeter, Penryn Campus (50.1710° N, 5.1238° W)

5. Funding Body: Biotechnology and Biological Sciences Research Council (BBSRC), grant number 128145R001

6. Software recommendations. 

	Statistical Analyses

	- R version 4.3.2+ [https://www.r-project.org/]

	- ImageJ 1.53
	
	- Custom ImageJ plugins
	



# 2) DATA & FILE OVERVIEW
---------------------------------------------------------------------------------------------------------------------------------------------------------
## 1. File List (In Alphabetical order):	


NOTE: to create the svg files you must run the R code first.


    **/Analysis_01_Takeoff/

	*Analysis_Takeoff.R
	
	- Contains the R code required for "Butterfly wing patterns create motion confusion during takeoff"

	*EMD output.csv
	
	- Contains the EMD data for each frame for each butterfly.

	*Figure_1_[..]_Violin.svg
	
	- The .svg files used for the violin plots in figure 1.

	*Info_Butterfly.csv
	
	- Contains the butterfly species and sex information for the unique butterfly ID codes.

	*Info_Treatment.csv
	
	- Containts details about each individual video such as the distance the butterfly flew, 
	  the speed it flew in lengths per second and the duration of each video.

	*Sup_[..].svg
	
	- The .svg files used for the supplementary figures in "Real butterfly takeoff recordings"



    **/Analysis_02_Collins/
	
	*/R_PNGs/
	- Contains downscaled image scans from Collins Guide To Butterflies. Each image has been scaled with the same
	  canvas size so that all butterflies are to scale with one another. NB, do not redistribute without permissions
	  from Collins Publisher and the original artist Richard Lewington.


	*/R_PNGs_unscaled/
	- Contains downscaled image scans from Collins Guide To Butterflies. Here the canvas sizes match the dimensions
	  of the imaages. NB, do not redistribute without permissions from Collins Publisher and the original artist Richard
	  Lewington.

	*Analysis_Collins.R
	
	- Contains the R code required for "Multiple character traits that are widespread in European butterflies maximise motion 
	  confusion"

	*DF_CIE.csv
	
	- Contains the CIE Lab colour measures for the Collins butterflies.

	*DF_EMD.csv
	
	- Contains the elementary motion detector results for the Collins butterflies.

	*DF_Info_Table.csv
	
	- Contains the phylogeny labels for the Collins butterflies.
		Family	Subfamily	Tribe	Genus	Species	Binomial	genusSpecies

	*DF_Pattern_Analysis.csv

	- Contains the pattern analysis measures for the Collins butterflies.

	*DF_Phylogeny_PCo.csv

	- Contains the principal coordinates for the Collins butterflies.
	
	*DF_Phylogeny_Tip.csv

	- Contains the angle, x, and y coordinates for the Collins butterflies.

	*DF_Size_WBF.csv

	- Contains the body length (mm), wing area, and wing beat frequency measures of the Collins butterflies.
	
	*DF_Wingshape.csv

	- Contains the wingshape measures of the Collins butterflies.

	*Figure_2_[..].svg
	
	- The .svg files used for the plots in figure 2.
	
	*SHAP_Summary_[..].csv
	
	- Copies of the SHAP output tables.

	*Sup_[..].svg
	
	- The .svg files used for the supplementary figures in "Motion confusion across European butterflies"


    **/Analysis_03_GA/

	*/Wing_PNGs/
	- Contains a copy of the /R_PNGs_unscaled/ included within /Analysis_02_Collins/ in addition to downscaled images
	 for all of the GA generated butterflies for each populations.

	*Analysis_GA.R
	- Contains the R code required for "Artificially evolved butterflies selected for motion confusion alone mimic real butterflies"

	*DF_EMD.csv
	- Contains the elementary motion detector results for the Collins butterflies.

	*DF_Info_Table.csv
	- Contains the phylogeny labels for the Collins butterflies.
		Family	Subfamily	Tribe	Genus	Species	Binomial	genusSpecies

	*DF_Pattern_Analysis.csv
	- Contains the pattern analysis measures for the Collins butterflies.

	*Figure_3_[..].svg
	- The .svg files used for the plots in figure 3.

	*GA_Pattern_Analysis.csv
	- Contains the pattern analysis measures for the genetic algorithm (GA) generated butterflies.

	*DF_Population_Data.csv
	- Contains the gene values and treatment assignments (wing shape and selection pressure) for each population.
	
	*Sup_[..].svg
	- The .svg files used for the supplementary figures in "Butterfly artificial evolution with genetic algorithms"

	
	**/Analysis_04_Game/

	*/Blender_Environment/
	- Contains the butterfly textures, background images and Blender files used to generate the flight paths and animations for the games.
	- To create the flight paths, execute the python script in 'BF_Experiment_Generate_Flight_Paths.blend'
	- To create all of the animations, excute the python script in 'BF_Experiment_Generate_Butterflies.blend'
	- /Motion_Paths_Isolated/ contains the 10 .json files for the flight paths used in the experiment.
	
	*/figure_photos2/
	- Contains the butterfly images from Collins Guide to Butterflies, used for the supp figures
	
	*/figure_photos3/
	- Contains the butterfly renders in blender to scale for the largest wing beat.
	
	*/Game_Environment/
	- Contains the Psychtoolbox and PECK functions and the scripts for the game.
	- To run you must have Psychtoolbox setup with OpenGL and gsync.
		o. once setup, use PECK Setup to enable PECK scripts
		o. then run butterfly_game_v5, in the butterfly game folder.
		
	*/Results/
	- Contains the raw results .csv files for each player.
	*Analysis_Game.R
	- Contains the R code required for "Figure 2 and the Supplementary Material Section 4/."

	*Butterfly_Body_Lengths_px.xls
	- Contains the calculation for the mean body lengths of the butterfly based on pixel lengths.
	
	*data_emd
	- Contains the elementary motion detector (EMD) output for each butterfly for each flight path.	
	
	*data_flightPath
	- Contains the coordinates and headings for the flight paths including unused measures of flight behaviour
	
	*data_hitbox
	- Contains posthoc imageJ measures for the hitboxes for every frame.
	
	*data_emd
	- Contains the elementary motion detector (EMD) output for each butterfly for each flight path.
	
	*data_triangle
	- Contains emd measures for a white triangle following the same path as the butterflies.
	
	*Output Shape Stats
	- Contains the elliptical shape statistics for three different percentails of the kernel density plot:
		top 25%,  50% and 75% densist regions, i.e. 75% is a larger selection.
	
	
	**/ImageJ_Code/
	Contains the plugins required for ImageJ.
	
	Blender model is located in /plugins/Butterfly Dazzle/Temp/.
	
	A user accessible version of our EMD model is provided in /plugins/EMD_Model_User/
		- Manual_Measure_EMD, for use when making motion maps and demos.
		- Auto_Measure_EMD, for automated batch scripts
	
	
	
	
	**/Phylogeny/
	*Circular_Phylogeny_[..].svg
	The .svg files used for the circular phylogeny in Figure 2.
	
	*DF_Info_Table.csv
	- Contains the phylogeny labels for the Collins butterflies.
		Family	Subfamily	Tribe	Genus	Species	Binomial	genusSpecies

	*DF_Phylogeny_PCo.csv
	- Contains the principal coordinates for the Collins butterflies.
	
	*DF_Phylogeny_Tip.csv
	- Contains the angle, x, and y coordinates for the Collins butterflies.

	*European_Butterflies_Full_DropTipped_Wiemers_2023.nwk
	- Contains the data for the time calibrated phylogeny

	*Generate_Circular_Phylogeny.R
	- Contains the R code used to generate the circular phylogeny plots from the .nwk file.

	*Generate_Circular_Phylogeny.R
	- Contains the R code used to generate the butterfly x,y, and angle data from the .nwk file.


## 2. Relationship between files, if important: 
	For all files the R code must be in the same location with respect to the data files to work.
	



# 3) DATA-SPECIFIC INFORMATION FOR: 
---------------------------------------------------------------------------------------------------------------------------------------------------------
	(In Alphabetical order)	


    **/Analysis_01_Takeoff/
	
	*EMD output.csv
	1. Number of variables: 9

	2. Number of cases/rows: 9564

	3. Variable List: 

	[1] ID. The unique ID for each butterfly flight recording.

	[2] Pattern. The appearance of the butterfly (Patterned, White, Black, Averaged), Patterned = the natural avian DBL pattern fo the butterfly.

	[3] MeanV. The mean DBL value of the butterfly.

	[4] Frame. The frame number.

	[5] Left. The energy output for the "Left" direction.

	[6] Right. The energy output for the "Right" direction.
	
	[7] Up. The energy output for the "Up" direction / "Forwards".

	[8] Down. The energy output for the "Down" direction / "Backwards".
	


	*Info_Butterfly.csv
	1. Number of variables: 5

	2. Number of cases/rows: 8

	3. Variable List: 

	[1] Code. The unique code for each butterfly morphotype.

	[2] Binomial. The binomial name of the butterfly.
	
	[3] Comon_Name. The common name of the butterfly.

	[4] Sex. The sex of the butterfly, M=male, F=female.

	[5] ButterflyNote. Species / morphotype notes.

	

	*Info_Treatment.csv
	1. Number of variables: 15

	2. Number of cases/rows: 18

	3. Variable List: 

	[1] Number. The video number.

	[2] ID. The ID of the video.
	
	[3] Code. The unique code of the butterfly in the video.

	[4] DistanceFlown. The number of pixels the butterfly travelled.

	[5] BodyLength. The length of the butterfly in pixels.
	
	[6] LengthsFlown. The number of body lengths flown.
	
	[7] Speed. The speed of the butterfly in lengths per second.
	
	[8] nFrames. The total number of frames of the video.
	
	[9] Duration. The duration of the video in seconds.
	
	[10] StartPhase. Which phase the wing beat started in.
	
	[11] FullBeats. How many full wing beats were completed.
	
	[12] EndPhase. Which phase the wing beat ended on.
	
	[13] Total. The number of wing beats performed.
	
	[14] WBS. The number of wing beats per second.
	
	[15] Note. Notes on the video.


	
	**/Analysis_02_Collins/
	
	*DF_CIE.csv
	
	1. Number of variables: 13

	2. Number of cases/rows: 2370

	3. Variable List: 

	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.

	[5] wing. Which wing of the butterfly is being measured (hindwing, forewing, or both).
	
	[6-13] CIE_[..]_[..]. Gives the CIE measures for the wing.
		
			L = L* = Luminance
			A = a* = Green-Red
			B = b* = Blue-Yellow
			
			mean = the mean valu of the wing.
			stdev = the standard deviation of the wing.
	
	
	

	*DF_EMD.csv
		
	1. Number of variables: 15

	2. Number of cases/rows: 4740

	3. Variable List: 

	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.
	
	[5] treatment. How was the butterfly rendered.

	[6] render_method. How was the butterfly patterned (Patterned,Averaged,White) Patterned = Natural appearance with avian dbl.
	
	[7] flight_method. Was the butterfly Gliding or Flapping.
	
	[8] CIE_[..]_[..]. Gives the CIE measures for the wing.
	
	[9-15] [..]_[..]. Gives the EMD Measures.
			left = left EMD
			right = right EMD
			up = up/forwards EMD
			down = down/backwardsEMD
			
			mean = the mean EMD values across frames.
			dev = the standard deviation across frames.
			

	*DF_Info_Table.csv
	
	1. Number of variables: 7

	2. Number of cases/rows: 399

	3. Variable List: 

	[1] Family. The family of the butterfly

	[2] Subfamily. The subfamily of the butterfly.
	
	[3] Tribe. The tribe of the butterfly.
	
	[4] Genus. The genus of the butterfly.
	
	[5] Species. The species of the butterfly.
	
	[6] Binomial. The species + genus of the butterfly.
	
	[7] genusSpecies. Duplicate of binomial.



	*DF_Pattern_Analysis.csv

	1. Number of variables: 29

	2. Number of cases/rows: 1580

	3. Variable List: 
	
	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.

	[5] wing. Which wing of the butterfly is being measured (hindwing, forewing, or both).
	
	[6-29] [..]_[..]. Gives the pattern metrics for the wing.
		
		
			The statistics map
			L = double cone luminance values in the RGB space (0-255)
			P = periodicity
			E = energy
			VH = vertical - horizontal
			OA = obtuse - acute
			DR = directionality
			
			The measures
			mean = the mean value of the wing image stat map.
			stdev = the standard deviation of the wing image stat map.
			x = the x gradient.
			y = the y graident.
	
	

	*DF_Phylogeny_PCo.csv

	1. Number of variables: 5

	2. Number of cases/rows: 496

	3. Variable List: 
	
	[1] PCo1. Principal coordinate 1.
	
	[2] PCo2. Principal coordinate 2.
	
	[3] PCo3. Principal coordinate 3.
	
	[4] PCo4. Principal coordinate 4.
	
	[5] Binomial. The binomial of the butterfly.
	
	
	
	
	
	*DF_Phylogeny_Tip.csv

	1. Number of variables: 4

	2. Number of cases/rows: 397

	3. Variable List: 
	
	[1] Binomial. The binomial of the butterfly.
	
	[2] Angle_deg. The angle of the butterfly on the phylogeny in degrees.
	
	[3] phy_x. The x coordinate of the butterfly.
	
	[4] phy_y. The y coordinate of the butterfly.

	
	*DF_Size_WBF.csv

	1. Number of variables: 7

	2. Number of cases/rows: 790

	3. Variable List: 
	
	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.
	
	[5] Body_Length. The length of the butterfly's body in mm.
	
	[6] Wing_Area. The area of the butterfly's hind and forewing in mm.
	
	[7] Wing_WBF. The calculated wing beat frequency (hz).
	
	
	
	*DF_Wingshape.csv

	1. Number of variables: 20

	2. Number of cases/rows: 790

	3. Variable List: 
	
	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.
	
	[5-20] [..]_[..]. Gives the pattern metrics for the wings.
		
		
			The wing
			fw = forewing
			hw = hindwing
			
			The measures in px
			length = length of the wing from the centre of the base to the most distal point
	        breadth = the breadth of the wing at the centroid of the line for the length of the wing
			fan = the rectangular length 
			stretch = the rectangular width of the wing
			area = the area of the wing relative to the body length (area/bodyLength) 
			ar = the aspect ratio of the wing (length/breadth)
			circ = the circularity of the wing (4pi(area/perimeter^2))
			rough = roughness of the wing (the convex area / the actual area)s.
	

	
	*SHAP_Summary_[..].csv
	
	1. Number of variables: 5

	2. Number of cases/rows: ...
	
	3. Variable List: 
	
	[1] feature. the butterfly feature that contributes to the prediction.
	
	[2] IncNodePurity. the purity of the features inclusion in the model.
	
	[3] mean_shap. the mean shap value
	
	[4] sd_shap. the standard deviation of the shap.
	
	[5] SHAP. the shap value +- the standard deviation.
	

	
	
	**/Analysis_03_GA/
	
	
		*DF_EMD.csv
		
	1. Number of variables: 15

	2. Number of cases/rows: 4740

	3. Variable List: 

	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.
	
	[5] treatment. How was the butterfly rendered.

	[6] render_method. How was the butterfly patterned (Patterned,Averaged,White) Patterned = Natural appearance with avian dbl.
	
	[7] flight_method. Was the butterfly Gliding or Flapping.
	
	[8] CIE_[..]_[..]. Gives the CIE measures for the wing.
	
	[9-15] [..]_[..]. Gives the EMD Measures.
			left = left EMD
			right = right EMD
			up = up/forwards EMD
			down = down/backwardsEMD
			
			mean = the mean EMD values across frames.
			dev = the standard deviation across frames.
			

	*DF_Info_Table.csv
	
	1. Number of variables: 7

	2. Number of cases/rows: 399

	3. Variable List: 

	[1] Family. The family of the butterfly

	[2] Subfamily. The subfamily of the butterfly.
	
	[3] Tribe. The tribe of the butterfly.
	
	[4] Genus. The genus of the butterfly.
	
	[5] Species. The species of the butterfly.
	
	[6] Binomial. The species + genus of the butterfly.
	
	[7] genusSpecies. Duplicate of binomial.



	*DF_Pattern_Analysis.csv

	1. Number of variables: 29

	2. Number of cases/rows: 1580

	3. Variable List: 
	
	[1] genus. The genus of the butterfly.

	[2] species. The species of the butterfly.
	
	[3] genusSpecies. The genus and species concatenated by "_"

	[4] sex. The sex of the butterfly.

	[5] wing. Which wing of the butterfly is being measured (hindwing, forewing, or both).
	
	[6-29] [..]_[..]. Gives the pattern metrics for the wing.
		
		
			The statistics map
			L = double cone luminance values in the RGB space (0-255)
			P = periodicity
			E = energy
			VH = vertical - horizontal
			OA = obtuse - acute
			DR = directionality
			
			The measures
			mean = the mean value of the wing image stat map.
			stdev = the standard deviation of the wing image stat map.
			x = the x gradient.
			y = the y graident.
			
			
			
	*GA_Pattern_Analysis.csv

	1. Number of variables: 80

	2. Number of cases/rows: 11424

	3. Variable List: 
	
	[1] ID. The ID of the individual GA generated butterfly within its population.

	[2] Generation. The generation (0 or 20) the butterfly was from.
	
	[3-71] The genes and heritage [parents] data for each indidual sex in this context is "-" as the genetic algorithm did not asign sexes to individuals.

	[72] Fitness. The fitness value of the individual given its selection pressure.
	
	[73] left_mean. The mean energy output for the "Left" direction across all frames.

	[74] right_mean. The meanenergy output for the "Right" direction across all frames.
	
	[75] up_mean. The mean energy output for the "Up" direction / "Forwards" across all frames.

	[76] down_mean. The mean energy output for the "Down" direction / "Backwards" across all frames.
	
	[77] Population. The population the butterfly was from. [Winshape]_[SelectionPressure]_[Repeat]
	
	[78] Wingshape. The butterfly binomial for the wingshape of the butterfly used.
	
	[79] SelectionPressure. What the butterfly was selected for.
	
				BF = backwards-forwards = forwards-confusion
				SF = sideways-forwards = sideways-confusion	
				FE = forwards-energy
				R = random-selection
				
	[80] Repeat. The repeat number for the treatment.
	
	


	**/Analysis_04_Game/
	
	*Butterfly_Body_Lengths_px.xls
		
	1. Number of variables: 8

	2. Number of cases/rows: 5

	3. Variable List: 

	[1] Butterfly. The ID code for the 5 selected butterflies for the game.

	[2] LengthRaw(px). The length of the butterfly's body for the blender output image.
	
	[3] LengthScreen(px). The length of the butterfly's body when on the screen, 1.5x RAW.

	[4] ScreenWidth(px). The width of the screen in pixels.
	
	[5] ScreenWidth(cm). The width of the screen in cm.

	[6] PxRatio. The ratio of pixels to cm.
	
	[7] Length(cm). The lengths of the butterfly in cm.
	
	[8] Mean. The mean length of the butterflies.
	
	
	
	*data_emd.csv
		
	1. Number of variables: 7

	2. Number of cases/rows: 17500

	3. Variable List: 

	[1] butterfly. The butterfly phenotype used (Binomail + sex).
	
	[2] PathID. The unique path number [1-10].

	[3] pathNumber. The unique path number [1-10].
	
	[4] EMD_Forward. The emd output for the forward direction (direction of start to end point).

	[5] EMD_Backward. The emd ouutput for the backward direction (inverse of start to end point).
	
	[6] EMD_Left. The emd output for the left direction (-90 from start to end point  direction).

	[7] EMD_Right. The emd output for the right direction (+90 from start to end point direction).
	

	*data_flightPath.csv
	
	1. Number of variables: 14

	2. Number of cases/rows: 17500

	3. Variable List: 

	[1] frame. The frame number [1-350]
	
	[2] x. The blender x coordinate, values of 1 to -1 are within the range of the screen.

	[3] y. The blender y coordinate, values of 1 to -1 are within the range of the screen.
	
	[4] heading_deg. The heading of the butterflies in degrees.
	
	[5] butterfly. The butterfly phenotype used (Binomail + sex).

	[6] PathID. The unique path number [1-10].
	
	[7] pathNumber. The unique path number [1-10].

	[8] meanHeading. The average heading of the butterfly.
	
	[9] heading_diff_from_mean. The difference in current heading from the mean.
	
	[10] rolling_mean_300ms. The mean heading from the past 300 milliseconds (72 frames).
	
	[11] rolling_sd_300ms. The standard deviation of headings from the past 300 milliseconds (72 frames).
	
	[12] heading_diff_300ms. The difference in heading from the heading 300 milliseconds ago (72 frames).
	
	[13] x_diff_300ms. The difference in x position from 300 milliseconds ago (72 frames).
	
	[14] y_diff_300ms. The difference in y position from 300 milliseconds ago (72 frames).

	

	
	*data_hitbox.csv
	
	1. Number of variables: 14

	2. Number of cases/rows: 17500

	3. Variable List: 

	[1] butterfly. The butterfly phenotype used (Binomail + sex).
	
	[2] pathNumber. The unique path number [1-10].

	[3] hitbox_image. The .png for thje frame.
	
	[4] frame. The frame number [1-350]
	
	[5] hitbox_x. The x coordinate of the centre of the hitbox in px.
	
	[6] hitbox_y. The y coordinate of the centre of the hitbox in px.

	[7] hitbox_w. The bounding width of the hitbox.
	
	[8] hitbox_h. The bounding height of the hitbox.

	[9] hitbox_r. The radius of the hitbox.
	
	[10] hitbox_area. The area of the whole hitbox (not bounding box)
	
	[11] body_area. The area of the body region.
	
	[12] forewing_area. The area of the forewing region.
	
	[13] hindwing_area. The area of the hindwing region.
	
	[14] tail_area. The area of the tail region.
	


	*data_emd.csv
		
	1. Number of variables: 7

	2. Number of cases/rows: 3500

	3. Variable List: 
	
	[1] PathID. The unique path number [1-10].

	[2] pathNumber. The unique path number [1-10].
	
	[3] TriangleEMD_Forward. The emd output for the forward direction (direction of start to end point).

	[4] TriangleEMD_Backward. The emd ouutput for the backward direction (inverse of start to end point).
	
	[5] TriangleEMD_Left. The emd output for the left direction (-90 from start to end point  direction).

	[6] TriangleEMD_Right. The emd output for the right direction (+90 from start to end point direction).
	
	
	
	*Output_Shape_Stats.csv
		
	1. Number of variables: 15

	2. Number of cases/rows: 15

	3. Variable List: 
	
	[1] Butterfly. The ID code for the 5 selected butterflies for the game.

	[2] probability. The probability range, lower values indicate denser regions selected.
	
	[3] centroid_x. The x coordinate of the centre of the ellipse.

	[4] centroid_y. The y coordinate of the centre of the ellipse.
	
	[5] major_axis. The widest diameter.

	[6] minor_axis. The diameter perpendicular to the widest diameter.
	
	[7] aspect_ratio. Major/minor.
	
	[8] angle_deg. The angle of the ellipse in degrees.
	
	[9] area. The area of the ellipse.
	
	[10] xmin. The min x value of the ellipse.
	
	[11] xmax. The max x value of the ellipse.
	
	[12] ymin. The min y value of the ellipse.
	
	[13] ymax. The max y value of the ellipse.
	
	[14] width. The width of the ellipse (xMax-xMin).
	
	[15] height. The height of the llipse (yMax-yMin).