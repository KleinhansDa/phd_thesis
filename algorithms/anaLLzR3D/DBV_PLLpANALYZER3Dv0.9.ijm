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
	version = 0.75;
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
		Dialog.addMessage("Step   I / III: DATA FORMAT");
	  	  	Dialog.addCheckbox("Deconvolved", false);
			Dialog.addCheckbox("Time-Series", false);
			Dialog.addCheckbox("Multi Channel", false);
		Dialog.addMessage("Step  II / III: MACRO OPTIONS");
			Dialog.addChoice("C1:", labelsC1);
			Dialog.addChoice("C2:", labelsC2, " ");
			Dialog.addCheckbox("Invert Channels", false);
			Dialog.addCheckbox("Register primordium", false);
		Dialog.addMessage("Next:\nStep III / III: Choose directory");
		Dialog.addMessage("click 'HELP' for info");
		Dialog.show();
			decon = Dialog.getCheckbox();
			ts = Dialog.getCheckbox();
			multi = Dialog.getCheckbox();
			C1label = Dialog.getChoice();
			C2label = Dialog.getChoice();
			inv = Dialog.getCheckbox();
			reg = Dialog.getCheckbox();
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
	//	Channel preparation
		if (multi) {
				if (inv) {
				run("Arrange Channels...", "new=21");}
				wait(200);
		
			run("Split Channels");
			close(ORG);
		}
	//	Create subdirectories
			pdir = dir +  name + File.separator;
				File.makeDirectory(pdir);
			if (multi) {
				C2dir = pdir + File.separator + "C2" + File.separator;
					File.makeDirectory(C2dir);
				C1dir = pdir + File.separator + "C1" + File.separator;
					File.makeDirectory(C1dir);
			}
				metadir = pdir + File.separator + "meta" + File.separator;
					File.makeDirectory(metadir);
				resultsdir = dir + File.separator + "Results" + File.separator;
					File.makeDirectory(resultsdir);
	//	PRINT METADATA TO LOG WINDOW
	if (i==0) {
		print("Channels:");
			print("   C1: "+C1label);
			print("   C2: "+C2label);
		print("Directories:");
		if (multi) {
			print("   Positions directory: "+pdir);
			print("   C1 directory: "+C1dir);
			print("   C2 directory: "+C2dir);
			} else {
			print("   Positions directory: "+pdir);
		}
		print("   Meta data: "+metadir);
		print("   Results: "+resultsdir);
	}
	//	SAVE CHANNELS
		if (multi) {
		selectWindow("C1-"+ORG);
			saveAs("Tiff", C1dir + name + "-C1.tif");
			ORGC1 = getTitle();
		selectWindow("C2-"+ORG);
			saveAs("Tiff", C2dir + name + "-C2.tif");
			ORGC2 = getTitle();
		} //else {
			//selectWindow(ORG);
			//saveAs("Tiff", pdir + name + ".tif");
			//ORG = getTitle();
		//}
			resetMinAndMax();
	//	Get BioFormats
		if (multi) {
			selectWindow(ORGC1);
		} else {
			selectWindow(ORG);
		}
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
	// 	create Z-projection to do calculations on
		run("Z Project...", "projection=[Max Intensity]");
		ZP = getTitle();
				run("Duplicate...", " ");
				ZPD = getTitle();
	// Create Minimum Thresholded Mask
		selectWindow(ZP);
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
		selectWindow(ZP);
		run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear");
		//saveAs("Tiff", dir + name + "_ZP_R.tif");
		ZP = getTitle();
			//close(ZPMAX);
//	########################## CROPPING ############################## 
	roiManager("reset");
	run("Select None");
	run("Make Binary");
		selectWindow(ZP);
		run("Analyze Particles...", "size=150-10000 include exclude add");
			if(roiManager("count")==1) {
				roiManager("select", 0);
				} else {
				roiManager("select", rmcount);
				}
		List.setMeasurements;
			XRect = List.getValue("X");
			YRect = List.getValue("Y");
		selectWindow(ZP);
		getDimensions(width, height, channels, slices, frames);
			height = 400; // change height of rect here
			toUnscaled(YRect);
			YRect = YRect-(height/2);
		close(ZP);
	print(" Cropping parameters");
	print("   Y Location: "+YRect);
	print("   Height: "+height);
	print(" Registering "+ORG+"...");
				roiManager("reset");
				selectWindow(ZPD);
				// Rotate
				   run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
				// Crop
				   makeRectangle(0, YRect, width, height);
				   run("Crop");
				   print("   Saving "+ name + "ZPD_RC.tif");
				   saveAs("Tiff", metadir + name + "_ZPD_RC.tif");
				   ZPD = getTitle();
				// Create threshold mask to clear signals outside ROI
				   run("Morphological Filters", "operation=Closing element=Disk radius=50");
				   ZPDF = getTitle();
				   close(ZPD);
				   run("Gaussian Blur...", "sigma=2 scaled");
				   //run("Enhance Contrast...", "saturated=0 equalize");
				   run("Normalize Local Contrast", "block_radius_x=300 block_radius_y=20 standard_deviations=2 stretch");
				   run("16-bit");
				   run("Gaussian Blur...", "sigma=2 scaled");
				   run("Normalize Local Contrast", "block_radius_x=300 block_radius_y=20 standard_deviations=2 stretch");
				   run("16-bit");
				   saveAs("Tiff", metadir + name + "_ZPD_RC_NLC.tif");
				   //setOption("BlackBackground", true);
				   setAutoThreshold("Minimum dark");
				   run("Convert to Mask");
				   run("Invert");
				// save
				   print("   Saving "+ name + "ZPD_RC_bin.tif");
				   saveAs("Tiff", metadir + name + "_ZPD_RC_bin.tif");
				   ZPDF = getTitle();
				   run("Make Binary");
				   roiManager("reset");
				   run("Analyze Particles...", "include add");
				   roiManager('select', 0);
				   run("Enlarge...", "enlarge=8");
				   roiManager('update');
				   //roiManager('select', 0);
				   //getSelectionBounds(x, y, w, h);
				   //setSelectionLocation(x+20, y+0);
				   //run("Crop");
				   //roiManager('update');
				   roiManager('select', 0);
				   roiManager("save selected", metadir + name + ".zip");
				   close(ZPDF);
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
	    // Background
		   //run("Z Project...", "projection=[Average Intensity]");
		   //AVG = getTitle();
		   //imageCalculator("Subtract stack", ORGC1, AVG);
		   //close(AVG);
		// Save
		   print("   Saving: "+name+"-C1_RC.tif");
		   if (multi) {
		   	saveAs("Tiff", C1dir + name + "-C1_RC.tif");
		   	} else {
		   		saveAs("Tiff", pdir + name + "_RC.tif");}
		   C1BC = getTitle();  // Name ORG changed by saving
		   //run("Enhance Contrast...", "saturated=1 process_all");
		   //run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=2 y-radius=2 z-radius=2");
		   C1F = getTitle();
		   //run("Select None");
		   roiManager("reset");
		   		roiManager("Open", metadir + name + ".zip");
		   selectWindow(C1BC);
		   		if (reg) {
		   			roiManager("select", 0);
		   			run("Crop");
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
	//run("8-bit");
		run("Morphological Segmentation");
	wait(2000);
		selectWindow("Morphological Segmentation");
			call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border");
			if (C1label==515) {
				if (decon) {
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=300", "calculateDams=true", "connectivity=6"); //if deconvolved with RichardsonLucy & 5 iterations
				} else {
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=15", "calculateDams=true", "connectivity=6"); //30ms exposure
				}
			}
			if (C1label==-139) {
				if (decon) {
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=300", "calculateDams=true", "connectivity=6");
				} else {
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10", "calculateDams=true", "connectivity=6");
				}
			}
	wait(90000);
			//call("inra.ijpb.plugins.MorphologicalSegmentation.toggleOverlay");
			//call("inra.ijpb.plugins.MorphologicalSegmentation.setShowGradient", "true");
			call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
			call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
			//run("Properties...", "channels=1 slices="+n+" frames=1 unit=microns pixel_width=0.1625000 pixel_height=0.1625000 voxel_depth=0.4");
			run("Properties...", "channels=1 slices="+n+" frames=1 unit=microns pixel_width="+sizeX+" pixel_height="+sizeY+" voxel_depth="+sizeZ);
			if (multi) {
		   		saveAs("Tiff", C1dir + name + "-C1_RC_CB.tif");
		   		} else {
		   			saveAs("Tiff", pdir + name + "_RC_CB.tif");}
			C1CB = getTitle();
			run("Grays");
		selectWindow("Morphological Segmentation");
		close();
		selectWindow(C1F);
		close();
// 	###################### Channel 1: Cell Measurements and Maps ###########################
	selectWindow(C1CB);
	//run("3D Exclude Borders", "remove");
	// Dilate binary borders
	  // run("GreyscaleDilate ", "iterations=1");
	// set 3D options & run
	  // run("Set 3D Measurements", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box close_original_images_while_processing_(saves_memory) dots_size=5 font_size=10 redirect_to=none");
	   //run("3D object counter...", "threshold=128 slice=39 min.=1000 max.=100000 exclude_objects_on_edges objects surfaces centroids statistics summary");
	   //run("3D object counter...", "threshold=128 slice=39 min.=1000 max.=37658115 exclude_objects_on_edges objects surfaces centroids");
	// save surface and OBJECTS MAP
	   //selectWindow("Surface map of "+C1WS);
	   //selectWindow("Objects_removed");
	   run("16-bit");
	   run("3D Exclude Borders", "remove");
	   	if (multi) {
			saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DM_O-Map.tif");
			} else {
				saveAs("Tiff", pdir + name + "_RC_WS_3DM_O-Map.tif");
			}
	   		//run("Enhance Contrast...", "saturated=0 equalize process_all");
	   		//if (C1label == 515) {run("Green");}
	   		//if (C1label == -139) {run("Red");}
	   		OMap = getTitle();
	   		run("8-bit");
	   //selectWindow("Objects map of "+C1WS);
	   	 //  	if (multi) {
			//saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DOC_O-Map.tif");
			//} else {
				//saveAs("Tiff", pdir + name + "_RC_WS_3DOC_O-Map.tif");
			//}
	   		//OMap = getTitle();
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
	   			   Ext.Manager3D_SaveResult("M", resultsdir + name + ".csv");
				   Ext.Manager3D_CloseResult("M");
				   Ext.Manager3D_Reset();
				   Ext.Manager3D_Close();
	   		//run("8-bit");
	   		//run("Analyze Particles...", "add stack");
	   		//close(OMap);
	   //	selectWindow("Centroids map of "+C1WS);
	   	 //  	if (multi) {
		//	saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DOC_C-Map.tif");
		//		} else {
		//		saveAs("Tiff", pdir + name + "_RC_WS_3DOC_C-Map.tif");
		//	}
	   	//	close();
	// save Results
	   //saveAs("results", C1Imgdir + name + "_3DOC_Results" + ".txt");//IJ.renameResults("Results"); // renames imported external results table to 'Results' to close it again//nr = nResults();//print("Counted objects: "+nr);//results();
    // CREATE COMPOSITE
       selectWindow(C1BC);
       	run("8-bit");//run("Crop");
	   	run("Merge Channels...", "c2="+OMap+" c4="+C1BC+" create keep");
	   	close(C1BC);
	   	selectWindow("Composite");
	   		if (multi) {
	   		saveAs("Tiff", C1dir + name + "-C1_RC_WS_3DM_OMap_Composite.tif");
				} else {
				saveAs("Tiff", pdir + name + "_RC_WS_3DM_OMap_Composite.tif");
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
			saveAs("results", resultsdir + name + "_3DMngr_3DMax_results" + ".txt");
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
    call("bar.Utils.revealFile", dir);
    restoreSettings();
		
	// Find Maxima in 3D
	   //run("3D Maxima Finder", "radiusxy=5 radiusz=5 noise=100");
	   //selectWindow("peaks");
	   //saveAs("Tiff", dir + name + "-C2_RC_peaks.tif");
	   //peaks = getTitle();
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
