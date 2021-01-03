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
///////////			- 25x microscopic data of the 								    ///////////
///////////			- zebrafish lateral line system	Timelapse data					///////////
/////////// 		- cldnb:lyn-gfp Label & H2BRFP labeling		   					///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////         			     David Kleinhans, 22.06.2016				    ///////////
///////////						  Kleinhansda@bio.uni-frankfurt.de				    ///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////	
	
// ################### GET PARAMETERS & DIRECTORIES, SHOW DIALOGS ######################
	//cleanup();
// Start up / get Screen parameters to set location of Dialog Boxes
	version = 1.77;
	header = "PLLpANALYZER2Dv"+version+" ";
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("started: "+ hour + ":" + minute);
	scrH = screenHeight();
		DiaH = scrH/5;
		InfoH = scrH/5;
		LogH = scrH/5;
	scrW = screenWidth();
		DiaW = scrW/6;
		InfoW = scrW/3;
		LogW = scrW/1;
	selectWindow("Log");
	setLocation(LogW,LogH);
		
// Check if plugins are installed
	//plugins = getDirectory("plugins");
	//pluginlist = getFileList(plugins);
	//mlj = plugins + File.separator + "MorphoLibJ_-1.3.1.jar"
		//if (!File.exists(mlj)) 
			//exit("Please install the 'Morpholib J' plugin first. \nGo to 'Help' -> 'Update...' -> 'Manage Update Sites' -> Choose 'IJPB-plugins'n\Click 'Close', then 'Apply changes'.n\Restart ImageJ and the pLLP Analyzer.");
		
	
// OPENING DIALOG
	guideI();
	String.resetBuffer;
	showStatus("STEP I / III: Data selection...");
	Dialog.create(header+"- STEP I / III");
	Migration = newArray("L - > R", "R - > L");
	Dialog.setLocation(DiaW,DiaH);
		Dialog.addMessage("Please define some parameters first...");
		Dialog.addMessage("STEP   I: Data selection");
		Dialog.addCheckbox("Segmentation", true);						// pre
		Dialog.addCheckbox("Include Cell Clusters", true);				// ccs
		Dialog.addCheckbox("Registration", true);						// reg
		Dialog.addCheckbox("Headless mode", true);						// head
		Dialog.setInsets(0,20,0);
		Dialog.addChoice("Direction of Migration", Migration);			// mig
		//Dialog.addCheckbox("Pre-processed", false);
	// Dialog.addMessage("STEP   I: Data selection");
		Dialog.addCheckbox("Time-Series", true);						// ts
		Dialog.addCheckbox("Multichannel (nuclei count)", false);		// mc
		Dialog.addCheckbox("Close all other windows", true);			// mc
		Dialog.addMessage("click 'HELP' for info");
	info(); // info Log
		Dialog.show();
		pre = Dialog.getCheckbox();
		ccs = Dialog.getCheckbox();
		reg = Dialog.getCheckbox();
		head = Dialog.getCheckbox();
		mig = Dialog.getChoice();
		ts = Dialog.getCheckbox();
		dual = Dialog.getCheckbox();
		ca = Dialog.getCheckbox();
	selectWindow(header);
	run("Close");

//	cleanup
	if (ca) {
		cleanup();
	}

// 	Input and Output directories
	guideI2();
	if (pre) {
		showStatus("STEP I / II: 8-/16-bit input");
	//	input directory for prim segmentation
		orgdir	= getDirectory("choose input directory: unprocessed 8-/16-bit image data");
		orgdirlist = getFileList(orgdir);
			par = File.getParent(orgdir); // get org parent directory
	//	input second channel
		if (dual) {
			dualdir	= getDirectory("choose second channel");
			dualdirlist = getFileList(dualdirdir);
		}
	// create subdirs
		bindir = par + File.separator + "03 - Binaries" + File.separator; // create directory to save binaries in
			File.makeDirectory(bindir);
		rcdir = par + File.separator + "02 - RC" + File.separator; // create directory to save binaries in
			File.makeDirectory(rcdir);
		output = par + File.separator + "05 - Analysis results" + File.separator; // create directory to save binaries in
			File.makeDirectory(output);
		pLLPdir = par + File.separator + "04 - pLLP registered" + File.separator; // create directory to save binaries in
			File.makeDirectory(pLLPdir);
		//debugX = par + File.separator + "00 - debugging" + File.separator; // create directory to save binaries in
			//File.makeDirectory(debugX);
	  	//orglength = ofl.length;
	  	//showStatus("STEP 1/2: output");
		//output 	= getDirectory("choose output directory");
	} else {
		showStatus("registered 8-/16-bit input");
		orgdir	= getDirectory("choose input directory: 8-/16-bit image data");
		orgdirlist = getFileList(orgdir);
		par = File.getParent(orgdir);
		rcdir = orgdir;
	  	showStatus("binaries input");
		bindir	= getDirectory("choose input directory: segmented binary");
	  	bindirlist = getFileList(bindir);
	  	//showStatus("STEP I / III: output");
		output = par + File.separator + "05 - Analysis results" + File.separator; // create directory to save binaries in
			File.makeDirectory(output);
		pLLPdir = par + File.separator + "04 - pLLP registered" + File.separator; // create directory to save binaries in
			File.makeDirectory(pLLPdir);
		}
	selectWindow(header);
	run("Close");
	// get dimensions of first original file
	run("Bio-Formats Macro Extensions");
	id = orgdir+orgdirlist[0]; // get ID of first element of org.filelist(ofl)
	Ext.setId(id);
	Ext.getSeriesName(seriesName);
	Ext.getImageCreationDate(creationDate);
  	Ext.getPixelsPhysicalSizeX(sizeX);
  	Ext.getPixelsPhysicalSizeY(sizeY);
  	Ext.getPixelsPhysicalSizeZ(sizeZ);
  	Ext.getPixelsTimeIncrement(sizeT);
  	Ext.getSizeC(sizeC);
// --- Variables and Identifiers Dialog Box ---
	sizeT = sizeT/3600;
	guideII();
	showStatus("STEP II / III");
	Dialog.create(header+"- STEP II / III");
	Dialog.setLocation(DiaW,DiaH);
	Dialog.addMessage("DATE OF EXPERIMENT"); 
		//Dialog.addString("Name of Experiment:", seriesName, 15);
		Dialog.addNumber("Date of Experiment:", creationDate, 0, 8, "[yymmdd]");
		//Dialog.addNumber("Scale:", 3.8760, 4, 5, "  [px/µm]:");
	Dialog.addMessage("CHECK IMAGE DIMENSIONS")
		Dialog.addNumber("X-spacing:", sizeX, 2, 4, "  [µm]");
		Dialog.addNumber("Y-spacing:", sizeY, 2, 4, "  [µm]");
		Dialog.addNumber("Z-spacing:", sizeZ, 2, 4, "  [µm]");
		Dialog.addNumber("Time interval:", sizeT, 3, 4, "  [h]");
		//Dialog.addNumber("Channels:", sizeC, 0, 1, "#");
		//Dialog.addCheckbox("Count nuclei?", true);
	Dialog.addMessage("click -> OK <- to proceed to STEP 3/3\nclick 'HELP' for info");
		// Help Button see functions section
	//help();
		Dialog.show();
	date = d2s(Dialog.getNumber(), 0); 	// get first dialog input
	xs = Dialog.getNumber(); 			// get second dialog input
	ys = Dialog.getNumber(); 			// get third dialog input
	zs = Dialog.getNumber(); 			// get fourth dialog input
	time = Dialog.getNumber(); 			// get fifth dialog input
	//nuc = Dialog.getChoice();
	// --- Genotype Input Dialog box ---
	showStatus("STEP III / III");
	selectWindow(header);
	run("Close");
	pos = newArray(orgdirlist.length);  // First, create empty array "pos" to be filled with Positional identifiers
	eTime = orgdirlist.length*2;
	guideIII();
	Dialog.create(header+"- STEP III / III");
	Dialog.setLocation(DiaW,DiaH);
	Dialog.addMessage("Define genotypes");
	for (j = 0; j < orgdirlist.length; j++){
		pos[j] = j;
		//d = pos[j];
		orgname = replace(orgdirlist[j], ".tif", "");
		c = pos[j]+1;
		//print(c);
			//if (j<9) { // because j starts from zero
			Dialog.addString(orgname, "??", 6);
			//} //else {Dialog.addString(orgdirlist[j], "??", 6);}
	}
	Dialog.addMessage("       ------------------------------------\n \nclick 'OK' to finish input and start macro\n \n       ------------------------------------");
		Dialog.show();
	selectWindow(header);
	run("Close");
		
// ##########################################################################################################################
// #################################################  PREPROCESSING #########################################################
// ##########################################################################################################################

// create empty arrays
	types = newArray(orgdirlist.length);
	embryoIDs = newArray(orgdirlist.length);
	embryodirs = newArray(orgdirlist.length);
	T0 = getTime();
if (pre) {
	for (q = 0; q < orgdirlist.length; q++) {
		if (head) {
		setBatchMode(true);
		}
		T1 = getTime();
		roiManager("reset");
	// 	Define and variables
		posi = pos[q]+1;
		if (posi<10) {position=d2s(0,0)+d2s(posi,0);}else{position=d2s(posi,0);}
		type = Dialog.getString(); // gets the genotype in every subsequent loop
		types[q] = type;
		embryoID = date + "." + position;
		embryoIDs[q] = embryoID;
	//	print processing process to log window
		if(q==0) {print("			START PRE-PROCESSING ORIGINAL FILES");}
		if(q>0) {print(" ");}
		print("------------------------ processing Embryo ID: " + embryoID + " ------------------------");
	//	open first file out of orgdir
		open(orgdir+orgdirlist[q]);
		if (dual) {
			run("Split Channels");
			selectWindow("C1-" + orgdirlist[q]);
			ORG = getTitle();
			selectWindow("C2-" + orgdirlist[q]);
			dualo = getTitle();
		} else {
		orgname = replace(orgdirlist[q], ".tif", ""); 
		ORG = getTitle();
		selectWindow(ORG);
		}
		if (mig == "R - > L") {
			run("Flip Horizontally", "stack");
		}
		n = nSlices();
		setSlice(n);
			
	//	################################### REGISTRATION PARAMETERS ####################################
	
	//	GET AVERAGE BACKGROUND VALUE
		print("Calculating registration parameters...");
		run("Z Project...", "projection=[Average Intensity]");
		ZPAVG = getTitle();
		//getDimensions(width, height, channels, slices, frames);
			//makeRectangle(0, 0, width, height);
			//List.setMeasurements;
  		//MeanInt = List.getValue("Mean");
		selectWindow(ORG);
		setSlice(n);
		run("Duplicate...", " "); // Duplicate single slice
		DORG = getTitle();
		imageCalculator("Subtract create", DORG, ZPAVG);
		//saveAs("Tiff", debugX + embryoID + "_ImgSub.tif");
		IC = getTitle();
		close(DORG);
		run("Morphological Filters", "operation=Closing element=Disk radius=15");
		REG = getTitle();
		close(IC);
		close(IC);
		close(DORG);
	//	########################## Thresholding ##############################
		run("Gaussian Blur...", "sigma=5.5 scaled"); // MC
		//saveAs("Tiff", debugX + embryoID + "_Blur.tif");
		REG = getTitle();
		run("Duplicate...", " ");
		REGD = getTitle();
		selectWindow(REG);
		run("Enhance Contrast...", "saturated=0.3 normalize");
		run("8-bit");
	//	get rotational angle and rotate
		selectWindow(REG);
		setAutoThreshold("MaxEntropy  dark");
		run("Convert to Mask");
		//saveAs("Tiff", debugX + embryoID + "_REG.tif");
		REG = getTitle();
	// ########################## ANGLE ############################## 
		run("Analyze Particles...", "size=150-10000 include exclude add");
		rmcount = roiManager("count")-1;
		if(roiManager("count")==1) {
			roiManager("select", 0);
			List.setMeasurements;
			Angle = List.getValue("FeretAngle");
			print("Angle: "+Angle);
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
		print("Angle: "+Angle);
		selectWindow(ZPAVG);
		run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear");
		//saveAs("Tiff", debugX + embryoID + "_ZPAVG.tif");
		//run("8-bit");
		ZPAVG = getTitle();
		selectWindow(REG);
		run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear");
		run("Make Binary");
		//saveAs("Tiff", debugX + embryoID + "_REGrot.tif");
		REG = getTitle();
	// ########################## CROPPING ############################## 
		//selectWindow(REG);
		roiManager("reset");
		run("Analyze Particles...", "size=150-10000 include add");
		roiManager("select", 0); // oder doch rmcount?
		List.setMeasurements;
		XRect = List.getValue("X");
		YRect = List.getValue("Y");
			//print("XRect: "+XRect);
			//print("YRect: "+YRect);
		selectWindow(REG);
		getDimensions(width, height, channels, slices, frames);
		List.setMeasurements;
			//YRect = List.getValue("Y");
		height = 400; // change height of rect here
		toUnscaled(YRect);
		YRect = YRect-(height/2);
		print("YRectcor: "+YRect);
		close(REG);
		print("  Registering "+embryoID+"...");
	// Apply registration parameters
	selectWindow(ORG);
		//run("8-bit");
		if (reg) {
			if (dual) {
			selectWindow(ORG);
			run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
			makeRectangle(0, YRect, width, height);
			run("Crop");
			selectWindow(dualo);
			run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
			makeRectangle(0, YRect, width, height);
			run("Crop");
			}
		run("Rotate... ", "angle="+Angle+" grid=1 interpolation=Bilinear stack");
		makeRectangle(0, YRect, width, height);
		run("Crop");
		}
		print("    Saving: "+embryoID+"_RC");
		saveAs("Tiff", rcdir + orgname + "_RC.tif");
		ORG = getTitle();  // Name ORG changed by saving
	// crop ZPAVG for image calc
	selectWindow(ZPAVG);
	makeRectangle(0, YRect, width, height);
	run("Crop");
	close(REGD);
		
	//  ###############################################################################################
	//	################################### STACK SEGMENTATION ########################################
	//  ###############################################################################################
	//  #################################### Background correction ####################################
	print("  Segmenting "+embryoID+"_RC...");
		selectWindow(ORG);
		getDimensions(width, height, channels, slices, frames);
		//run("Subtract...", "value=[MeanInt] stack");
		//run("Subtract Background...", "rolling=1000 sliding stack");
		imageCalculator("Subtract create stack", ORG, ZPAVG);
		IC = getTitle();
		close(ZPAVG);
		//close(ORG);
	selectWindow(IC);
		print("Bleach correction...");
		run("Bleach Correction", "correction=[Simple Ratio] background=0");
		BC = getTitle();
		close(IC);
		selectWindow(BC);
		for (j = 1; j < frames; j++) {
			selectWindow(BC);
			setSlice(j);
			run("Morphological Filters", "operation=Closing element=Disk radius=15");
		}
		close(BC);
		//setBatchMode("exit and display");
		wait(100);
		run("Images to Stack", "name="+ORG+" title=[] use");
		wait(100);
		//run("Morphological Filters (3D)", "operation=Closing element=Ball x-radius=15 y-radius=15 z-radius=0");
	//saveAs("Tiff", debugX + embryoID + "_MC3D.tif");
		MC = getTitle();
	//	########################## BLURRING ##############################
		//print("Blurring...");
		selectWindow(MC);
		run("Gaussian Blur...", "sigma=5.5 scaled stack"); // MC
	//	Normalize saturated pixels
		run("Enhance Contrast...", "saturated=0.5 normalize process_all");
	//	#####################  THRESHOLDIG ORG_RC	######################
		setSlice(n);
		resetThreshold();
		//run("Convert to Mask");
		setAutoThreshold("MaxEntropy dark");
		run("Convert to Mask", "method=MaxEntropy background=Dark black");
		run("Invert LUT");
		run("Fill Holes", "stack");
		run("Erode", "stack");
		run("Erode", "stack");
		//run("Dilate", "stack");
		print("    Saving binary");
		saveAs("Tiff", bindir + orgname + "_RC_bin.tif");
		MC = getTitle();
		close(MC); // close BIN
		// print duration of cycle
		T2 = getTime();
		Tdiff = T2-T1;
		print("  Duration: "+Tdiff+"ms");
	}
//Array.show(bindirlist);
//Array.show(rcdirlist);
closelog();
roiManager("reset");
setBatchMode(false);
}
rcdirlist = getFileList(rcdir);
bindirlist = getFileList(bindir);

// ##########################################################################################################################
// ####################################################  ANALYSIS ###########################################################
// ##########################################################################################################################
// ############################  ENTER 1st LOOP TO INCREMENT OVER EACH FILE OF INPUT FOLDERS ################################
	
	for (b = 0; b < orgdirlist.length; b++) {
		//setBatchMode(true);
		// get genotypes and embryoIDs from arrays
		type = types[b];
		embryoID = embryoIDs[b];
		orgname = replace(orgdirlist[b], ".tif", ""); 
		// create directories for single embryos to save results
		embryodir = output + File.separator + orgname + File.separator;
		File.makeDirectory(embryodir);
		// print StatsLog descriptors
		if (b==0) {StatsLogInfo();}
		// print Embryo ID 
		print("¸.·´¯`·.¸><(((º> "+" ID: "+embryoID+" | GT: "+type+"  <º))><¸.·`¯´·.¸");
		// open and define binary
		open(bindir+bindirlist[b]);
		wait(200);
		  BIN = getTitle();
		// open and define orginal 
		open(rcdir+rcdirlist[b]);
		wait(200);
		  RC = getTitle();
			dotIndex = indexOf(RC, ".");
			title = substring(RC, 0, dotIndex);
// 	Create Orphan measuring Row
	//makeOval(10, 10, 5, 5);
	//roiManager("add"); // ver important here
	//roiManager("measure");
	//roiManager("reset");
	
// #############################  ENTER 2nd LOOP TO INCREMENT OVER EACH SLICE OF THE TIME-SERIES ##############################
	selectWindow(BIN); 	 // select binary
		for (i=1 ; i<=nSlices(); i++) {
		s = nSlices();
		setSlice(i);
		wait(200);
		if (ccs) {
			run("Analyze Particles...", "size=200-7500 include add");
		} else {
		run("Analyze Particles...", "size=750-7500 include add");
		}
	//setBatchMode("exit and display");
	//waitForUser("Check if Neuromasts are segmented");
		// Loop though ROI List
		roiManager("show none"); // supress roimanager popping up
		//run("Select None");
		for (j=0 ; j<roiManager("count"); j++) {
			roiManager("select", j);
			run("Set Scale...", "distance=1 known=0.00005 pixel=1 unit=micron");
			List.setMeasurements;
  			//print(List.getList); // list all measurements
  			x = List.getValue("X");
			//run("Set Scale...", "distance=1 known=0.005270 pixel=1 unit=micron");
    		roiManager("rename", x);
		}
		// Sort ROIs and select last one
		roiManager("Sort");
		run("Properties...", "channels=1 slices=1 frames=[s] unit=micron pixel_width=[xs] pixel_height=[ys] voxel_depth=[zs] frame=[time] global");
		n = roiManager("count");
		m = n-1;
		selectWindow(RC);
	//  prim registration
		roiManager("show none"); // supress roimanager popping up
		roiManager("Select", m);
		sln = getSliceNumber();
		//print("slice "+sln+"/"+s);
		run("Enlarge...", "enlarge=6");
		run("Fit Ellipse");
		run("Duplicate...", "use");
		rename(sln);
		//wait(100);
		resetMinAndMax();
		// Rotate
		List.setMeasurements;
		A = List.getValue("Angle");
		run("Select None");
		if (A < 10) {
			run("Rotate... ", "angle=[A] grid=1 interpolation=Bilinear slice");
		} else {
			A = 180-A;
			A = A*(-1);
			run("Rotate... ", "angle=[A] grid=1 interpolation=Bilinear slice"); 
		}
			run("Flip Horizontally");
			selectWindow(RC); // select & deselect to remove selected ROIs
			run("Select None");
		// 	Measure and save segmented Mask ROI
			// create directory for ROIs
			pLLProis = embryodir + File.separator + "ROIs" + File.separator;
		//embryodirs[b] = embryodir;
			File.makeDirectory(pLLProis);
			pLLPxy = embryodir + File.separator + "ROIsXY" + File.separator;
		//embryodirs[b] = embryodir;
			File.makeDirectory(pLLPxy);
		wait(200);
		selectWindow(BIN);
		roiManager("show none"); // supress roimanager popping up
		roiManager("Select", m);
		//run("Fit Ellipse");
	//	save ROIs and XY coordinates
		//roiManager("save selected", pLLProis + "_s" + i + ".zip");
		roiManager("save", pLLProis + "_s" + i + ".zip");
		saveAs("XY Coordinates", pLLPxy + "_s" + i + ".txt");
	// 	measure
		run("Set Measurements...", "area centroid bounding fit shape feret's stack redirect=None decimal=2");
    	roiManager("measure");
    	roiManager("reset");
    	run("Select None");
    //  Calculate additional variables based on measurements
    	n = nResults();
    	r = n-1;  // actual RowNumber
    	r2 = n-2; // RowNumber -1
    	if (i == 1) {  // get X & Y coordinates, keep X0 and Y0 for normalization
    		X0 = getResult("X");
    		Y0 = getResult("Y");
    		} else {
    			X1 = getResult("X", r2);
    			X2 = getResult("X", r);
    			Y1 = getResult("Y", r2);
    			Y2 = getResult("Y", r); }
    	// get width of bounding rectangle
    	W = getResult("Width");
    	// calculations (XN = normalized X; LE = Leading Edge)
    	// Euclidian Distance of X + normalized to offspring 'zero'
    	if (i == 1) {
    		XED = 0;
    		XN = 0;
    	} else {
    		XED = sqrt((X2-X1)*(X2-X1)+(Y2-Y1)*(Y2-Y1));
    		XN = (X2 - X0) + XED;
    		}
    	LE = XN + (W/2); // Leading Edge 
    	T = time * r; // Time interval
    	setResult("embryo", r, orgname); // set Results
    	setResult("group", r, type);
    	setResult("time", r, T);
    	setResult("deg", r, A);
    	setResult("X_ED", r, XED);
    	setResult("X_N", r, XN);
    	setResult("LE", r, LE);
    	updateResults();
    	// Velocitiy LE (LE1 = LE @ timepoint 1; LEN = normalized value of LE, LENV = Velocity of the normalized value of LE)
    	if (i == 1) {
    		LE1 = LE; // LE1 will be the same for all further timepoints
    		LEN = 0; //
    		LENED = NaN; // 'Leading Edge Normalized Euclidian Distance'
    		LEV = NaN; // For the first timepoint there can be no speed, since there was no coordinate of X and Y before
    	} else {
    		LEN = LE - LE1; // The value of 'LE Normalized' to zero 
    		LED = getResult("LE_N", r2); // LED = The value of LE one row before
    		LENED = sqrt((LEN-LED)*(LEN-LED)+(Y2-Y1)*(Y2-Y1)); // LENED = LEN - (LEN-LED);
    		LEV = LENED / time;
    	}
    	setResult("LE_N", r, LEN); // setResult Leading Edge Normalized (LE_N)
    	setResult("LE_N_ED", r, LENED); // setResult Leading Edge Normalized Euclidian Distance (LE_N_ED)
    	setResult("LE_V", r, LEV); // setResult Leading Edge Velocity (LE_V)
    	updateResults();
		}
		close(BIN); // could be reduced to close(BIN, ORG); or close (".tif");
		close(RC);
		setBatchMode("exit and display");
		wait(500);
		print(nImages);
		run("Images to Stack", "method=[Copy (top-left)] name=Stack title=[] use");
		//Stack.getDimensions(width, height, channels, slices, frames);
		//run("Properties...", "channels=1 slices=99 frames=1 unit=micron pixel_width=0.4333334 pixel_height=0.4333334 voxel_depth=3.0000000");
	//run("Images to Stack", "method=[Scale (smallest)] name=Stack title=[] use");
		run("Flip Horizontally", "stack");
		saveAs("Tiff", pLLPdir + orgname + ".tif");
		close();
	// Save Results Table
		run("Input/Output...", "jpeg=100 gif=-1 file=.txt use_file copy_column copy_row save_column");
		saveAs("results", embryodir + orgname + "_Results" + ".txt");
		//if (i==1){
		//	String.copyResults();
		//} else {String.append(String.copyResults());}
	// Calulate Stats and show in Log
		StatsLog();
	// Correlate Results
		//print("------------------------ LM Fit ------------------------");
		//run("Correlate Results", "x=Time y=LE_N equation=[Straight Line] show graph=Circles");
		//saveAs("Tiff", embryodir + orgname + "_ScatterPlot");
		//close();
		//IJ.renameResults("Results");
		cleanup();
	}
	
// ################################ POSTPROCESSING #########################################

// Save statistics from log file
	selectWindow("Log");
	saveAs("Text", output + date + "_Stats" + ".txt");
	closelog();
// Run analysis again but combine all numbers in a giant table
	//print("Merging result tables, check main window to track progress...");
	//boxplot();
	//updateResults();
	//combRes = output + File.separator + date + "_CombinedResults.txt" + File.separator;
	//saveAs("results", output + date + "_CombinedResults" + ".txt");
	IJ.renameResults("Results"); // renames imported external results table to 'Results' to close it again
	cleanup();
	//run("Create Boxplot", "use=[External file...] open=combRes round group=group");
	//	wait(350);
	//	run("Capture Screen");
	//	wait(350);
	//	makeRectangle(810, 219, 300, 392);
	//	run("Crop");
	//	saveAs("Tiff", output + date + "_BoxRound");
	//	run("Close");
	//run("Create Boxplot", "use=[] area group=group");
	//	wait(350);
	//	run("Capture Screen");
	//	wait(350);
	//	makeRectangle(810, 219, 300, 392);
	//	run("Crop");
	//	saveAs("Tiff", output + date + "_Area");
	//	run("Close");
	//run("Create Boxplot", "use=[] le_v group=group");
	//	wait(350);
	//	run("Capture Screen");
	//	wait(350);
	//	makeRectangle(810, 219, 300, 392);
	//	run("Crop");
	//	saveAs("Tiff", output + date + "_BoxSpeed");
	//	run("Close");
	//	wait(200);
	//closelog();
	//	wait(200);
	T3 = getTime();
	Tend = (T3-T0)/60000;
	print("  Duration: "+Tend+" min.");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("finished: "+ hour + ":" + minute);
	selectWindow("Log");  //select Log-window 
	saveAs("Text", par + "Log_" + version + year+"0"+month+"0"+dayOfMonth+".txt"); 
	if(getBoolean("DONE! :).\nOpen output directory?"))
    	call("bar.Utils.revealFile", output);
    	print("Registered pLLPs can be found under...\n"+pLLPdir);

// ============================================================================================================================
// ######################################### FUNCTIONS ########################################################################
// ============================================================================================================================
function cleanup(){
		if (isOpen("Results")) { 
		selectWindow("Results"); 
		run("Close");} 
		if (isOpen("ROI Manager")){
		selectWindow("ROI Manager");
		run("Close");}
	run("Close All");
}

function roireset(){
	roiManager("reset");
	run("Select None");
}

function closelog() {
if (isOpen("Log")) { 
    selectWindow("Log"); 
    run("Close"); 
}}

function StatsLogInfo() {
	print("####################### ANALYSIS ######################");
	print("===================== STAT LEGEND =====================");
	print("[N] = number of datapoints");
	print("[Mean] = Added values / number of datapoints");
	print("[Var] = Variance = sigma^2 = E[(x-µ)^2]");
	print("[SD] = Standard Deviation = sigma = sqrt(E[X^2]-(E[X])^2)");
	print("[SE] = Standard Error = sigma/sqrt(n)");
	print("[95% CI] = Confidence Interval = 0.196*SE");
	print("[LM Fit] = Linear regression fitted model");
print("=======================================================");
}

function StatsLog() { // Richard Mort 13/04/2012:http://imagejdocu.tudor.lu/doku.php?id=macro:calculating_stats_from_a_results_table
		// Area STATS
			for (a = 0; a < nResults(); a++) {
    			total_area = total_area + getResult("Area", a);
    			mean_area = total_area / nResults;
				}
			for (a = 0; a < nResults(); a++) {
    			total_variance_Area = total_variance_Area + (getResult("Area",a)-(mean_area))*(getResult("Area",a)-(mean_area));
    			variance_area = total_variance_Area/(n-1);
			}
			SD_Area = sqrt(variance_area); // SD, SE and CI of "Area" column (note: requires variance)
			SE_Area = (SD_Area/(sqrt(n)));
			CI95_Area = 1.96*SE_Area;
		// Roundness STATS
			for (a = 0; a < n; a++) {
    			total_round = total_round + getResult("Round", a);
   				mean_round = total_round / n;
				}
			for (a = 0; a < n; a++) {
    			total_variance_round = total_variance_round + (getResult("Round",a)-(mean_round))*(getResult("Round",a)-(mean_round));
    			variance_round = total_variance_round/(n-1);
				}
			SD_Round = sqrt(variance_round); // SD of "Round" column (note: requires variance)
			SE_Round = (SD_Round/(sqrt(n)));
			CI95_Round = 1.96*SE_Round;
		// LE STATS
			for (a = 1; a < nResults(); a++) {
    			total_V = total_V + getResult("LE_V", a);
				}
				mean_V = total_V/nResults;
			for (a = 1; a < nResults(); a++) {
    			total_variance_velo = total_variance_velo + (getResult("LE_V", a)-(mean_V))*(getResult("LE_V",a)-(mean_V));
    			variance_V = total_variance_velo / (n-1);
				}
			nV = n-1;
			SD_V = sqrt(variance_V); // SD of "LE_V" column (note: requires variance)
			SE_V = (SD_V/(sqrt(nV)));
			CI95_V = 1.96*SE_V;
// Print stats
print("------------------------ AREA -------------------------");
	print("[N] Datapoints = "+ n);
	print("Mean = "+ mean_area + " [µm^2]");
	print("Var = "+ variance_area + " [µm^2]");
	print("StD = "+ SD_Area + " [µm^2]");
	print("StE = "+ SE_Area + " [µm^2]");
	print("95% CI = "+ CI95_Area + " [µm^2]");
print("---------------------- ROUNDNESS ----------------------");
	print("[N] Datapoints = "+ n);
	print("Mean = "+ mean_round + " [inv.AR]");
	print("Var = "+ variance_round + " [inv.AR]");
	print("StD = "+ SD_Round + " [inv.AR]");
	print("StE = "+ SE_Round + " [inv.AR]");
	print("95% CI = "+ CI95_Round + " [inv.AR]");
print("---------------------- VELOCITY -----------------------");
	print("[N] Datapoints = "+ nV);
	print("Mean = "+ mean_V + " [µm/h]");
	print("Var = "+ variance_V + " [µm/h]");
	print("StD = "+ SD_V + " [µm/h]");
	print("StE = "+ SE_V + " [µm/h]");
	print("95% CI = "+ CI95_V + " [µm/h]");
	print(" ");
}

function help() {
				html = "<html>"
			+"<h1><font color=purple>pLLP ANALYZER v0.6 INFO log</h1>"
     		+"<h><b>Date</b></h>"
     			+"Please enter the date in the format <b>'yymmdd'</b> for later identification.<br>"
     		+"<h><b>Position</b></h>"
     			+"Please enter the embryos positional ID in the format <b>'nn'</b>, like 01, 02, ....<br>"
     		+"<h><b>Scale</b></h>"
     			+"Please enter the spatial calibration in <b>Pixels / micron</b>.<br>"
     		+"<h><b>Time</b></h>"
     		     +"Please enter the time interval in <b>hours</b>.<br>"
     		+"<h><b>Genotype</b></h>"
     			+"Please enter a <b>genotype without semicolon or slashes<b>.<br>"
     		+"<h><b>Nuclei counting</b></h>"
     			+"If the Image Data contains a second channel with a Nuclei Label, you can check the box to have the nuclei counted as well.<br>"
     		+"<h><b>Pre-processing</b></h>"
     			+"If the Image Data contains a second channel with a Nuclei Label, you can check the box to have the nuclei counted as well.<br>"
     		+"<h1><u><small>contact<small></u></h1>"
     		+"<small>David Kleinhans, AK Lecaudey, GU FFM, 11/16.<small><br>"
     		//Dialog.create("Help");
     		Dialog.addHelp(html);
}

function info() {
				html = "<html>"
			+"<h1><font color=purple>pLLP ANALYZER v0.6 INFO log</h1>"
     		+"<h1><b>RESULT TABLES</b></h1>"
     		+"<h><b>Measurements</b><h>"
     		 +"<ul>"
     			+"<li> Area<br>"
     			+"<li> Centroid [X/Y]<br>"
     			+"<li> Bounding Rectangle [BX/BY/Width/Height]<br>"
     			+"<li> Ellipsoid fit<br>"
     			+"<li> Angle<br>"
     			+"<li> Shape Discriptors<br>"
     			+"<li> Ferret's diameter<br>"
     			+"<li> Stack position [Slice number]<br>"
     			+"<li> Aspect Ratio [AR]<br>"
     			+"<li> Roundness [inv.AR]<br>"
     			+"<li> Solidity<br>"
     		 +"</ul>"
     		+"<h><b>Identifiers</b><h>"
     		 +"<ul>"
     			+"<li> Embryo [yymmdd.nn]<br>"
     			+"<li> Genotype [++ +- --]<br>"
     		 +"</ul>"
     		+"<h><b>Calculated variables</b><h>"
     		 +"<ul>"
     		     +"<li> Time [Slice x Time interval]<br>"
     		     +"<li> X_ED [X corrected by euclidian distance measurement]<br>"
     		     +"<li> X_N [X_ED normalized to T1]<br>"
     		     +"<li> LE [X_N + Width/2]<br>"
     		     +"<li> LE_N [LE normalized to T1]<br>"
     		     +"<li> LE_N_ED [LE_N corrected by euclidian distance measurement]<br>"
     		     +"<li> LE_V [LE_N_ED / Time interval]<br>"
     		 +"</ul>"
     		+"<h><b>Nuclei counting</b></h>"
     		 +"<ul>"
     			+"<li>Nuclei are counted based on max-projected Z-stacks with a nuclei label (e.g. H2B:RFP).<br>"
     		 +"</ul>"
     			 +"<ol>"
     				+"<li>First, the nuclei are blurred according to the average nuclei width in µm<br>"
     				+"<li>Then, the maxima finder is used to detect the peaks of the signal.<br>"
     			 +"</ol>"
     		+"<h1><b>REGISTERED pLLP</b></h1>"
     		+"<h1><b>STATS</b></h1>"
     		+"<h1><b>PLOTS</b></h1>"
     		+"<h1><u><small>contact<small></u></h1>"
     		+"<small>David Kleinhans, AK Lecaudey, GU FFM, 11/16.<small><br>"
     		Dialog.addHelp(html);
}

function boxplot() {
	for (e = 0; e < rcdirlist.length; e++) {
		showProgress(-e, rcdirlist.length);
		setBatchMode(true);
		// get genotypes and embryoIDs from arrays
			type = types[e];
			embryoID = embryoIDs[e];
		print("Collecting data for: " + orgname);
		//if (e==0) {StatsLogInfo();}
		open(bindir+bindirlist[e]);
		  BIN = getTitle();
		open(rcdir+rcdirlist[e]);
		  RC = getTitle();
			dotIndex = indexOf(RC, ".");
			title = substring(RC, 0, dotIndex);
	//makeOval(10, 10, 5, 5);
	//roiManager("measure");
	roiManager("reset");
// ############################  ENTER 2nd LOOP TO INCREMENT OVER EACH SLICE OF THE TIME-SERIES ################################

	selectImage(BIN); // select binary
		for (f=1 ; f<=nSlices(); f++) {
		s = nSlices();
		setSlice(f);
		run("Analyze Particles...", "size=500-10000 include add");
		//roiManager("show none"); // supress roimanager popping up
			for (p=0 ; p<roiManager("count"); p++) { // Loop though ROI List
				roiManager("select", p);
				run("Set Scale...", "distance=1 known=0.00005 pixel=1 unit=micron");
				List.setMeasurements;
  				x = List.getValue("X");
    			roiManager("rename", x);
				}
		roiManager("Sort");
//waitForUser("666 Check Roi manager");
		n = roiManager("count");
		m = n-1;
			selectImage(BIN);
			roiManager("Show None"); // supress roimanager popping up
//waitForUser("671 Check Roi manager");
				roiManager("Select", m);
				run("Properties...", "channels=1 slices=1 frames=[s] unit=micron pixel_width=[xs] pixel_height=[ys] voxel_depth=[zs] frame=[time] global");
				run("Set Measurements...", "area centroid bounding fit shape feret's stack display redirect=None decimal=2");
				//run("Extended Particle Analyzer", "pixel show=Masks redirect=None keep=None display");
    			roiManager("measure");
    			roiManager("reset");
    			run("Select None");
    		//  Calculate additional variables based on measurements
    		    n = nResults();
    		    r = n-1;  // actual RowNumber
    		    r2 = n-2; // RowNumber -1
    				if (f == 1) {  // get X & Y coordinates, keep X0 and Y0 for normalization
    					X0 = getResult("X");
    					Y0 = getResult("Y");
    				} else {
    					X1 = getResult("X", r2);
    					X2 = getResult("X", r);
    					Y1 = getResult("Y", r2);
    					Y2 = getResult("Y", r); }
    			// get width of bounding rectangle
    				W = getResult("Width");
    				// calculations (XN = normalized X; LE = Leading Edge)
    					// Euclidian Distance of X + normalized to offspring 'zero'
    					if (f == 1) {
    						XED = 0;
    						XN = 0;
    					} else {
    						XED = sqrt((X2-X1)*(X2-X1)+(Y2-Y1)*(Y2-Y1));
    						XN = (X2 - X0) + XED; }
    					LE = XN + (W/2); // Leading Edge 
    					T = time * r; // Time interval
    				setResult("embryo", r, orgname); // set Results
    				setResult("group", r, type);
    				setResult("time", r, T);
    				setResult("deg", r, A);
    				setResult("X_ED", r, XED);
    				setResult("X_N", r, XN);
    				setResult("LE", r, LE);
    			updateResults();
    			// Velocitiy LE (LE1 = LE @ timepoint 1; LEN = normalized value of LE, LENV = Velocity of the normalized value of LE)
    				if (f == 1) {
    						LE1 = LE; // LE1 will be the same for all further timepoints
    						LEN = 0; //
    						LENED = NaN; // 'Leading Edge Normalized Euclidian Distance'
    						LEV = NaN; // For the first timepoint there can be no speed, since there was no coordinate of X and Y before
    					} else {
    						LEN = LE - LE1; // The value of 'LE Normalized' to zero 
    						LED = getResult("LE_N", r2); // LED = The value of LE one row before
    						LENED = sqrt((LEN-LED)*(LEN-LED)+(Y2-Y1)*(Y2-Y1)); // LENED = LEN - (LEN-LED);
    						//XEDV = XED/time;
    						LEV = LENED / T;
    						}
    				setResult("LE_N", r, LEN); // setResult Leading Edge Normalized (LE_N)
    			    setResult("LE_N_ED", r, LENED); // setResult Leading Edge Normalized Euclidian Distance (LE_N_ED)
    			    setResult("LE_V", r, LEV); // setResult Leading Edge Velocity (LE_V)
    			    //setResult("XED_V", r, XEDV); // setResult Leading Edge Velocity (LE_V)
    			updateResults();
			}
		close(BIN); // could be reduced to close(BIN, ORG); or close (".tif");
		close(RC);
	}
	print("Done. Saving "+ date + "_CombinedResults.txt" );
}

function guideI () {
	newImage(header, "8-bit black", 350, 490, 1);
	setLocation(InfoW, InfoH);
	setColor(200, 200, 200);
  	setFont("SansSerif", 20, "antiliased bold");
  	drawString("STEP I / III\n ", 10, 35);
  	setFont("SansSerif", 18, "antiliased");
  	setColor(255, 255, 255);
  	drawString(" \nPlease select your kind of input data\n \n1. If 'RAW data' is selected, image data\n    will be registered (rotated and cropped)\n    automatically. \n2. If 'Time Series' is selected, the\n    analyzer will loop though each slice of\n    a stack of images. \n3. If '2nd channel' is selected, nuclei will\n    be counted within the region of\n    interested derived from the membrane\n    label.\n4. If 'inverted migration' is selected, the\n    data will be flipped horizontally prior\n    to processing.", 10, 60);
}

function guideI2 () {
	newImage(header, "8-bit black", 350, 150, 1);
	setLocation(DiaW, DiaH);
  	setFont("SansSerif", 18, "antiliased");
  	setColor(255, 255, 255);
  	drawString("Please select your input directory, \nwhich is, where the data is stored \nthat should be processed.", 10, 30);
}

function guideII () {
	newImage(header, "8-bit black", 350, 490, 1);
	setLocation(InfoW, InfoH);
	setColor(200, 200, 200);
  	setFont("SansSerif", 20, "antiliased bold");
  	drawString("STEP II / III\n ", 10, 35);
  	setFont("SansSerif", 18, "antiliased");
  	setColor(255, 255, 255);
  	drawString(" \nTo add identifiers to your result tables, \nplease enter the date of the experiment\nas [yymmdd]. \n \nAlso, please check the dimensions in X,\nY and Z as this is the calibration\ninformation based on which the data\nwill be analyzed. Correct them if necessary. \n \nThe time interval in [h] is needed to\ncalculate the developmental-time\nprogress at each frame", 10, 60);
}

function guideIII () {
	newImage(header, "8-bit rgb black", 350, 490, 1);
	setLocation(InfoW, InfoH);
	setColor(200, 200, 200);
  	setFont("SansSerif", 20, "antiliased bold");
  	drawString("STEP III / III\n ", 10, 35);
  	setFont("SansSerif", 18, "antiliased");
  	setColor(255, 255, 255);
  	drawString(" \nPlease enter your genotypes \n \nthis will be necessary to \ngroup your data in subsequent \ndata analysis. \n \nIt might look like...\n++ or\n++ -- or\n++ -- ++ or even \nbla++ bla-- bla++\n \njust be consistent!\n-----------\nEstimated duration:", 10, 60);
	setFont("SansSerif", 25, "antiliased bold");
	setColor(0, 200, 0);
	drawString(eTime+" min.", 10, 460);
}

function getrois() {
	outputlist = getFileList(output);
		for (v = 0; v < outputlist.length; v++) {
			embryodir = embryodirs[v]; // From filled array edirs
			embryodirlist = getFileList(embryodir);
			for (w = 0; w < embryodirlist.length; w++) {
				rois = getFileList(embryodirlist[w]);
					for (y = 0; y < rois.length; y++) {
						roiManager("open", rois[y]);
						//run("Set Measurements...", "area centroid bounding fit shape feret's stack redirect=None decimal=2");
						//run("measure");
					}
				roiManager("save", embryodir + "ROIs.zip");
			}
		}
}
