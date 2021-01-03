///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////								MACRO INSTRUCTIONS			 		        ///////////	
///////////////////////////////////////////////////////////////////////////////////////////////
/////////// To use this macro you need to open a (segmented) binary and the 		///////////
/////////// according original image data, then press Run, then follow instructions.///////////
///////////	It was designed to Analyze (shape & nuclei number) and register 		///////////
/////////// the movement of the dr pLLP in Timelapse data.							///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////								OPTIMIZED FOR... 						    ///////////
///////////			- 40x microscopic data of the 								    ///////////
///////////			- zebrafish pLLP												///////////
/////////// 		- different labels							   					///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////         			     David Kleinhans, 09.02.2017				    ///////////
///////////						  Kleinhansda@bio.uni-frankfurt.de				    ///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////	
	
// ################### GET PARAMETERS & DIRECTORIES, SHOW DIALOGS ######################
	
// Start up / get Screen parameters to set location of Dialog Boxes
	cleanup();
	saveSettings();
	version = 1.0;
	header = "pLLP ANALYZER 3D v"+version+" "; 
	scrH = screenHeight();
		DiaH = scrH/5;
		InfoH = scrH/5;
	scrW = screenWidth();
		DiaW = scrW/6;
		InfoW = scrW/3;
//	Opening Dialog
	guideI();
	Dialog.create(header);
	Dialog.setLocation(DiaW,DiaH);
	labelsC1 = newArray("515", "-139");
	labelsC2 = newArray("H2BRFP", "Arl13b", " ");
		Dialog.setInsets(0,10,0);
		Dialog.addMessage("                  INPUT DATA DIMENSIONS");
	  	  	//Dialog.addCheckbox("Deconvolved", false);
	  	  	Dialog.setInsets(0,20,0);
			Dialog.addChoice("C1:", labelsC1);
			Dialog.setInsets(0,20,0);
			Dialog.addChoice("C2:", labelsC2, " ");
			Dialog.setInsets(0,20,0);
			Dialog.addCheckbox("Invert Channels", false);
			Dialog.addCheckbox("Time-Series", false);
			Dialog.addCheckbox("Multi Channel", false);
		Dialog.setInsets(0,10,0);
		Dialog.addMessage("                           MACRO OPTIONS");
			Dialog.addCheckbox("Save metadata", false);
			Dialog.addCheckbox("Register primordium", true);
		Dialog.setInsets(0,20,0);
		Dialog.addMessage("Membrane Segmentation tolerance level:");
			Dialog.addSlider("", 0, 500, 10);
		Dialog.addMessage("Click 'OK' to proceed to input folder selection");
		//Dialog.addMessage("click 'HELP' for info");
		Dialog.show();
			//decon = Dialog.getCheckbox();
			ts = Dialog.getCheckbox();
			multi = Dialog.getCheckbox();
			C1label = Dialog.getChoice();
			C2label = Dialog.getChoice();
			inv = Dialog.getCheckbox();
			meta = Dialog.getCheckbox();
			reg = Dialog.getCheckbox();
			tol = Dialog.getNumber();
	selectWindow(header);
	wait(100);
	run("Close");
//	CHOOSE DIRECTORIES
		dir = getDirectory("Choose directory");
		//output = getDirectory("Choose an output directory");
//	Batch Mode
		list = getFileList(dir);
//	##################################################################################################################
//	#################################################### ENTER LOOP ##################################################
//	##################################################################################################################
	for (i = 0; i < list.length; i++) {
		setBatchMode(true);
		roiManager("reset");
		//if (endsWith(list[i],".nd2")) {
		file = dir+list[i];
	// 	Import images + Split channels
		run("Bio-Formats Importer", "open=["+file+"] color_mode=Grayscale view=Hyperstack stack_order=XYCZT");
		ORG = getTitle();
		name = File.nameWithoutExtension;
		dir = File.directory;
		pardir = File.getParent(dir);
	//	Channel preparation
		if (multi) {
				if (inv) {
				run("Arrange Channels...", "new=21");}
				wait(200);
		
			run("Split Channels");
			close(ORG);
		}
	//	Create subdirectories
			imgdir = pardir + File.separator + "(2) Image Analysis" + File.separator;
				File.makeDirectory(imgdir);
			datdir = pardir + File.separator + "(3) Data Analysis" + File.separator;
				File.makeDirectory(datdir);
			posdir = imgdir + name + File.separator;
				File.makeDirectory(posdir);
				if (multi) {
					C2dir = posdir + File.separator + "C2" + File.separator;
					File.makeDirectory(C2dir);
					C1dir = posdir + File.separator + "C1" + File.separator;
					File.makeDirectory(C1dir);
				}
			metadir = posdir + File.separator + "meta" + File.separator;
					File.makeDirectory(metadir);
			//resultsdir = pardir + File.separator + "Results" + File.separator;
					//File.makeDirectory(resultsdir);
	//	PRINT METADATA TO LOG WINDOW
	if (i==0) {
		print("Channels:");
			print("   C1: "+C1label);
			print("   C2: "+C2label);
		print("Directories:");
		if (multi) {
			print("   Positions directory: "+posdir);
			print("   C1 directory: "+C1dir);
			print("   C2 directory: "+C2dir);
			} else {
			print("   Positions directory: "+posdir);
		}
		if (meta) {
			print("   Meta data: "+metadir);
		}
		print("   Results: "+datdir);
	}
	//	SAVE CHANNELS
		if (multi) {
		selectWindow("C1-"+ORG);
			//saveAs("Tiff", C1dir + name + "-C1.tif");
			ORGC1 = getTitle();
		selectWindow("C2-"+ORG);
			//saveAs("Tiff", C2dir + name + "-C2.tif");
			ORGC2 = getTitle();
		} //else {
			//selectWindow(ORG);
			//saveAs("Tiff", pdir + name + ".tif");
			//ORG = getTitle();
		//}
			resetMinAndMax();
	//	Get BioFormats
		n = nSlices();
		run("Bio-Formats Macro Extensions");
		if (multi) {
			id = C1dir+ORGC1; // get ID of first element of org.filelist(ofl)
		} else {
			//id = pdir+ORG;
			id = dir+list[i];
		}
			Ext.setId(id);
			Ext.getSeriesName(seriesName);
			Ext.getImageCreationDate(creationDate);
  			Ext.getPixelsPhysicalSizeX(sizeX);
  			Ext.getPixelsPhysicalSizeY(sizeY);
  			Ext.getPixelsPhysicalSizeZ(sizeZ);
  			Ext.getPlaneTimingDeltaT(deltaT, 2);
  			Ext.getSizeC(sizeC);
  		if (i==0) {
  		print("Bio-Formats metadata:");
  		print("   X/Y Resolution: "+sizeX+"/"+sizeY);
  		print("   Z Resolution: "+sizeZ);
  		print("   T Resolution: "+deltaT);
  		print("   Slices per Channel: "+n); 
  		setSlice(n/2);
  		}
  	  	
//	#################################################### PRE-PROCESSING ##################################################
		print("");
		print("################## Processing file "+name+" ##################");
//	######################### REGISTRATION PARAMETERS ########################
	print("Calculating registration parameters...");
	setSlice(n/2);
	resetMinAndMax();
	// 	create Z-projection to generate masks and do calculations on
		//run("Z Project...", "projection=[Max Intensity]");
		if (multi) {selectWindow(ORGC1);} else {selectWindow(ORG);}
			run("Z Project...", "projection=[Standard Deviation]");
			ZPSTD = getTitle();
			run("16-bit");
			//run("Duplicate...", " ");
		if (multi) {selectWindow(ORGC1);} else {selectWindow(ORG);}
			run("Z Project...", "projection=[Max Intensity]");
			ZPMAX = getTitle();
	// Create Minimum Thresholded Mask
		selectWindow(ZPSTD);
			run("Gaussian Blur...", "sigma=4 scaled");
			setAutoThreshold("Minimum dark");
			run("Convert to Mask");
//	############################### ANGLE ##########################
	//angle();
	run("Analyze Particles...", "include add");
	rmcount = roiManager("count")-1;
		if(roiManager("count")==1) {
			roiManager("select", 0);
			List.setMeasurements;
			Angle = List.getValue("FeretAngle");
			if (Angle < 0) {Angle = Angle*(-1);}
			if (Angle > 90) {Angle = (180-Angle)*(-1);}
		} else {
			roiManager("select", 0);
			List.setMeasurements;
				X1Line = List.getValue("X");
				Y1Line = List.getValue("Y");
			roiManager("select", rmcount);
			List.setMeasurements;
				X2Line = List.getValue("X");
				Y2Line = List.getValue("Y");
			makeLine(X1Line, Y1Line, X2Line, Y2Line); 
				//roiManager("add");
			List.setMeasurements;
			Angle = List.getValue("Angle");
		if (Angle < -90) {Angle = Angle+180;}
		if (Angle > 90) {Angle = 180-Angle;}
		}
	print("   Rotation angle: "+Angle);
		selectWindow(ZPSTD);
		run("Select None");
		run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear");
		if (meta) {
			saveAs("Tiff", metadir + name + "_ZPSTD_R.tif");
			ZPSTD = getTitle();
		}
			//close(ZPMAX);
//	########################## CROPPING ############################## 
	roiManager("reset");
	run("Select None");
	run("Make Binary");
		selectWindow(ZPSTD);
		run("Analyze Particles...", "size=150-10000 include exclude add");
		rmcount = roiManager("count")-1;
			if(roiManager("count")==1) {
				roiManager("select", 0);
				} else {
				roiManager("select", rmcount);
				}
		List.setMeasurements;
			XRect = List.getValue("X");
			YRect = List.getValue("Y");
		selectWindow(ZPSTD);
		getDimensions(width, height, channels, slices, frames);
			height = 400; // change height of rect here
			toUnscaled(YRect);
			YRect = YRect-(height/2);
		close(ZPSTD);
	print(" Cropping parameters");
	print("   Y Location: "+YRect);
	print("   Height: "+height);
	print(" Registering "+ORG+"...");
				roiManager("reset");
				selectWindow(ZPMAX);
				// Rotate
				   run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
				// Crop
				   makeRectangle(0, YRect, width, height);
				   run("Crop");
				   print("   Saving "+ name + "ZPMAX_RC.tif");
				   saveAs("Tiff", posdir + name + "_ZPMAX_RC.tif");
				   ZPMAX = getTitle();
				// Create threshold mask to clear signals outside ROI
				   run("Morphological Filters", "operation=Closing element=Disk radius=50");
				   if (meta) {
				   	saveAs("Tiff", metadir + name + "_ZPMAX_RC_Close.tif");
				   }
				   ZPMAXClose = getTitle();
				   close(ZPMAX);
				   run("Gaussian Blur...", "sigma=2 scaled");
				   //run("Enhance Contrast...", "saturated=0 equalize");
				   run("Normalize Local Contrast", "block_radius_x=300 block_radius_y=20 standard_deviations=2 stretch");
				   run("16-bit");
				   run("Gaussian Blur...", "sigma=2 scaled");
				   run("Normalize Local Contrast", "block_radius_x=300 block_radius_y=20 standard_deviations=2 stretch");
				   run("16-bit");
				   if (meta) {
				   	saveAs("Tiff", metadir + name + "_ZPMAX_RC_NLC.tif");
				   }
				   //setOption("BlackBackground", true);
				   setAutoThreshold("Otsu dark");
				   run("Convert to Mask");
				   run("Invert");
				// save
				   if (meta) {
				   	print("   Saving "+ name + "ZPMAX_RC_bin.tif");
				   	saveAs("Tiff", metadir + name + "_ZPMAX_RC_bin.tif");
				   }
				   ZPMAXCloseF = getTitle();
				   run("Make Binary");
				   roiManager("reset");
				   run("Analyze Particles...", "include add");
				// Select most right Roi
						for (j=0 ; j<roiManager("count"); j++) {
							roiManager("select", j);
							run("Set Scale...", "distance=1 known=0.00005 pixel=1 unit=micron");
							List.setMeasurements;
  							//print(List.getList); // list all measurements
  							x = List.getValue("X");
    						roiManager("rename", x);
							}
						roiManager("Sort");
						run("Properties...", "channels=1 slices=1 frames=1 unit=micron pixel_width=[sizeX] pixel_height=[sizeY] voxel_depth=[sizeZ]");
				   primroi = roiManager("count")-1; // since roi count starts from zero
				   roiManager('select', primroi); // include selection of most right
				   run("Enlarge...", "enlarge=10");
				   run("Fit Ellipse");
				   roiManager('update');
				   roiManager('select', primroi);
				   roiManager("save selected", metadir + name + ".zip");
				   close(ZPMAXClose);
				   close(ZPMAXCloseF);
		// ############### C2 3D PROCESSING #################
		   if (multi) {
		   	selectWindow(ORGC2);
		   // Rotate
		      run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
		   // Crop
		      makeRectangle(0, YRect, width, height);
		      run("Crop");
		   // Save
		   	  print("   Saving: "+name+"-C2_RC.tif");
		      saveAs("Tiff", C2dir + name + "-C2_RC.tif");
		       ORGC2 = getTitle();
		   // label specific actions
		      if (C2label=="H2BRFP") {
		      	run("Gaussian Blur 3D...", "x=3 y=3 z=3");
		      }
		      if (C2label=="Arl13b") {
		      	run("Z Project...", "projection=[Average Intensity]");
		      	AVG = getTitle();
		      	imageCalculator("Subtract stack", ORGC2, AVG);
		      	close(AVG);
		      	run("Gaussian Blur 3D...", "x=1 y=1 z=2");
		      }
		   	  saveAs("Tiff", C2dir + name + "-C2_RC_Pre-P.tif");
		   	  ORGC2 = getTitle();;
		      roiManager("select", 0);
		      //run("Clear Outside", "stack");
		      run("Crop");
		   }
		// ############### C1 3D PROCESSING #################
		   if (multi) {
		   	selectWindow(ORGC1);
		   	} else {
		   		selectWindow(ORG);}
		   run("Bleach Correction", "correction=[Simple Ratio] background=0");
		   C1BC = getTitle();
		   run("Properties...", "channels=1 slices="+n+" frames=1 unit=microns pixel_width="+sizeX+" pixel_height="+sizeY+" voxel_depth="+sizeZ);
		   if (multi) {
		   	selectWindow(ORGC1);
		   	} else {
		   		selectWindow(ORG);}
		// Rotate
		   selectWindow(C1BC);
		   run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
		// Crop
		   makeRectangle(0, YRect, width, height);
		   run("Crop");
		// Save
		 print("   Saving: "+name+"-C1_RC.tif");
		   if (multi) {
		   	saveAs("Tiff", C1dir + name + "-C1_RC.tif");
		   	} else {
		   		saveAs("Tiff", posdir + name + "_RC.tif");}
		   C1BC = getTitle();  // Name ORG changed by saving
		   C1F = getTitle();
		   //run("Select None");
		   roiManager("reset");
		   		roiManager("Open", metadir + name + ".zip");
		   selectWindow(C1BC);
		   		if (reg) {
		   			roiManager("select", 0);
		   			if (ts) {
		   			} else {
		   				run("Crop");
		   			}
		   			run("Clear Outside", "stack");
		   		}
		   		if(C1label==515) {
		   			run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=2 y-radius=2 z-radius=2");
		   		} else { // C1Label==-139
		   			run("Duplicate...", "duplicate");
		   		}
		   C1F = getTitle();
		   setBatchMode("exit and display");
		   //setForegroundColor(65536, 65536, 65536);
		   //setBackgroundColor(0, 0, 0);

//	###############################################################################################
//	##################################### CREATING OBJECTS ########################################
//	###############################################################################################

// 	###################### MORPHOLOGICAL SEGMENTATION Membranes ###########################
	selectWindow(C1F);
	setSlice(n/2);
	//run("Enhance Contrast", "saturated=0.35");
	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
	resetMinAndMax();
		run("Morphological Segmentation");
	wait(2000);
		selectWindow("Morphological Segmentation");
			call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border");
			//if (C1label==515) {
				//if (decon) {
					//call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=300", "calculateDams=true", "connectivity=6"); //if deconvolved with RichardsonLucy & 5 iterations
				//} else {
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=[tol]", "calculateDams=true", "connectivity=6"); //30ms exposure
				//}
			//}
			//if (C1label==-139) {
				//if (decon) {
					//call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=300", "calculateDams=true", "connectivity=6");
				//} else {
					//call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=[tol]", "calculateDams=true", "connectivity=6");
				//}
			//}
	wait(90000);
			call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
			call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
			//run("Properties...", "channels=1 slices="+n+" frames=1 unit=microns pixel_width=0.1625000 pixel_height=0.1625000 voxel_depth=0.4");
			run("Properties...", "channels=1 slices="+n+" frames=1 unit=microns pixel_width="+sizeX+" pixel_height="+sizeY+" voxel_depth="+sizeZ);
			if (meta) {
				if (multi) {
		   			saveAs("Tiff", C1dir + name + "-C1_RC_MS.tif");
		   			} else {
		   			saveAs("Tiff", posdir + name + "_RC_MS.tif");}}
			C1CB = getTitle();
			run("Grays");
		selectWindow("Morphological Segmentation");
		close();
		selectWindow(C1F);
		close();
// 	###################### Channel 1: Cell Measurements and Maps ###########################
	selectWindow(C1CB);
	run("16-bit");
	   run("3D Exclude Borders", "remove");
	   	if (multi) {
			saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DM_O-Map.tif");
			} else {
				saveAs("Tiff", posdir + name + "_RC_WS_3DM_O-Map.tif");
			}
	   		//run("Enhance Contrast...", "saturated=0 equalize process_all");
	   		//if (C1label == 515) {run("Green");}
	   		//if (C1label == -139) {run("Red");}
	   		OMap = getTitle();
	   		close(C1CB);
	   		selectWindow(OMap);
	   		//run("8-bit");
	   		getDimensions(width, height, channels, slices, frames);
	   		//run("Enhance Contrast...", "saturated=0 equalize process_all");
	   			// measure with 3DManager
	   				// without feret
	   			   //run("3D Manager Options", "volume surface compactness fit_ellipse 3d_moments integrated_density mean_grey_value std_dev_grey_value mode_grey_value minimum_grey_value maximum_grey_value centroid_(pix) centroid_(unit) distance_to_surface centre_of_mass_(pix) centre_of_mass_(unit) bounding_box radial_distance surface_contact closest exclude_objects_on_edges_xy exclude_objects_on_edges_z sync distance_between_centers=10 distance_max_contact=1.80");
	   			   	// with feret
	   			   run("3D Manager Options", "volume surface compactness fit_ellipse 3d_moments integrated_density mean_grey_value std_dev_grey_value mode_grey_value feret minimum_grey_value maximum_grey_value centroid_(pix) centroid_(unit) distance_to_surface centre_of_mass_(pix) centre_of_mass_(unit) bounding_box radial_distance surface_contact closest exclude_objects_on_edges_xy exclude_objects_on_edges_z sync distance_between_centers=10 distance_max_contact=1.80");
	   			   run("3D Manager");
	   			   Ext.Manager3D_AddImage();
	   			   Ext.Manager3D_DeselectAll(); // to refresh RoiManager
	   			   Ext.Manager3D_Measure();
	   			   Ext.Manager3D_SaveResult("M", datdir + name + ".csv");
				   Ext.Manager3D_CloseResult("M");
				   Ext.Manager3D_Reset();
				   Ext.Manager3D_Close();
	   		selectWindow(OMap);
	   		run("8-bit");
    // CREATE COMPOSITE
       selectWindow(C1BC);
       	run("8-bit");//run("Crop");
	   	run("Merge Channels...", "c2="+OMap+" c4="+C1BC+" create keep");
	   	close(C1BC);
	   	selectWindow("Composite");
	   		if (multi) {
	   		saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DM_OMap_Composite.tif");
				} else {
				saveAs("Tiff", posdir + name + "_RC_WS_3DM_OMap_Composite.tif");
			}
	   close();
       
// 	###################### C2 clearing + 3D Maxima finder ###########################
	if (multi) {
	setBatchMode(true);
	selectWindow(OMap);
		if (C2label=="H2BRFP") {
			sliceclear();
		}
		if (C2label=="Arl13b") {
			primseg();
			//selectWindow(indiv+"-3Dseg");
			close(); // close -3Dseg
			wait(200);
			close(OMap);
			selectWindow(name + "-C2_RC_prim-seg.tif");
			//waitForUser("HALT");
			OMap = getTitle();
			sliceclear();
		}
	selectWindow(ORGC2);
	saveAs("Tiff", C2dir + name + "-C2_RC_clear.tif");
	C2cleared = getTitle();
	run("8-bit");
	wait(200);
	selectWindow(C2cleared);
	run("8-bit");
	wait(200);
	close(OMap);
	// 	create composite
		run("Merge Channels...", "c1="+SMap+" c2="+C2cleared+" create keep");
		selectWindow("Composite");
		saveAs("Tiff", C2dir + name + "-C2_RC_prim-seg_clear_SMap_Composite.tif");
		close();
		close(SMap);
		if (C2label == "Arl13b") {
		// 	3D Maxima finder
			selectWindow(C2cleared);
			run("3D Maxima Finder", "radiusxy=5 radiusz=10 noise=30");
			selectWindow("peaks");
			saveAs("Tiff", C2dir + name + "-C2_RC_prim-seg_3DM_peaks.tif");
			close();
			selectWindow("Results");
			saveAs("results", datdir + name + "_3DMngr_3DMax_results" + ".txt");
		}
		//waitForUser("HALT");
		results(); // see functions
		setBatchMode("exit and display");
		close(C2cleared);
    	} // if (multi)
    	// CLOSE everything
	closewindows(); // see functions
	} // list.length 
//}
	setBatchMode(false);
	if(getBoolean("DONE! :).\nOpen output directory?"))
    call("bar.Utils.revealFile", pdir);
    restoreSettings();

// ==============================================================================================================================================
// ############################################################# FUNCTIONS ######################################################################
// ==============================================================================================================================================
function cleanup(){
		if (isOpen("Results")) { 
		selectWindow("Results"); 
		run("Close");} 
		if (isOpen("ROI Manager")){
		selectWindow("ROI Manager");
		run("Close");}
	run("Close All");
	}

function results () {
	   	  if (isOpen("Results")) { 
          selectWindow("Results"); 
          run("Close"); 
    	  }
	} 
function closewindows () {
	//if (isOpen(SMap)) {  
		//selectWindow(SMap);
		//close();} 
	if (isOpen(ORG)) { 
		selectWindow(ORG);
		close(); }
	if (isOpen(OMap)) {  
		selectWindow(OMap);
		close();} 
}

function allroi () {
	array1 = newArray("0");; 
		for (i=1;i<roiManager("count");i++){ 
        	array1 = Array.concat(array1,i); 
		} 
	//print("selecting all rois");
	roiManager("select", array1); 
	}

function sliceclear() {
		for (j=1; j<=n; j++) {
		selectWindow(OMap);
		roiManager("reset");
		setSlice(j);
		run("Analyze Particles...", "include add slice");
		if (roiManager("count")==0) {
			selectWindow(ORGC2);
			setSlice(j);
			makeRectangle(0, 0, width, height);
			run("Cut");
		}
		if (roiManager("count")==1) {
			selectWindow(ORGC2);
			setSlice(j);
			allroi();
			wait(200);
			run("Clear Outside", "slice");
		}
		if (roiManager("count")>1) {
			selectWindow(ORGC2);
			setSlice(j);
			allroi();
			roiManager("Combine");
			wait(200);
			run("Clear Outside", "slice");
		}
	}
}

function primseg() {
	run("Duplicate...", "duplicate");
	indiv = getTitle();
	run("Enhance Contrast...", "saturated=0.3 equalize process_all");
	run("Options...", "iterations=3 count=1 black do=Close stack");
	run("Fill Holes", "stack");
// save
	saveAs("Tiff", C2dir + name + "-C2_RC_prim-seg.tif");
	indiv = getTitle();
// set 3D Manager Options (Feret doesn't work here)
	run("3D Manager Options", "volume surface compactness fit_ellipse 3d_moments integrated_density mean_grey_value std_dev_grey_value mode_grey_value minimum_grey_value maximum_grey_value centroid_(pix) centroid_(unit) distance_to_surface centre_of_mass_(pix) centre_of_mass_(unit) bounding_box radial_distance surface_contact closest exclude_objects_on_edges_xy exclude_objects_on_edges_z sync distance_between_centers=10 distance_max_contact=1.80");
// run the manager 3D and add image
	selectWindow(indiv);
	run("3D Manager");
		Ext.Manager3D_Segment(128,255);
		Ext.Manager3D_AddImage();
		Ext.Manager3D_DeselectAll(); // to refresh RoiManager
// do some measurements, save measurements and close window
		//Ext.Manager3D_Count(nb_obj);
		//Ext.Manager3D_SelectAll();
		Ext.Manager3D_Measure();
		Ext.Manager3D_SaveResult("M", resultsdir + name + "_3DMngr_PrimMeasure.csv");
		Ext.Manager3D_CloseResult("M");
		Ext.Manager3D_Reset();
		Ext.Manager3D_Close();
}

function guideI () {
	newImage(header, "8-bit black", 350, 490, 1);
	setLocation(InfoW, InfoH);
	setColor(200, 200, 200);
  	setFont("SansSerif", 20, "antiliased bold");
  	drawString("   DIMENSIONS\n ", 10, 35);
  	setFont("SansSerif", 18, "antiliased");
  	setColor(255, 255, 255);
  	drawString("\n \n1. Multi Channel\n    If you want to analyze more than one \n    channel, select 'Multi Channel'.\n2. Invert Channels\n    If C1 in your original files is not your\n    membrane label, select \n    'Invert Channels'.\n3. Time Series\n    If your data comprises an additional\n    time dimension, select 'Time Series'.\n \n \n    next: Choose directory to process", 10, 60);
}
