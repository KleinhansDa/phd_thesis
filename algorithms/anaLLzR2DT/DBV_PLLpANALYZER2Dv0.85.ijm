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
	// Screen params
	scrH = screenHeight();
		DiaH = scrH/4;
	scrW = screenWidth();
		DiaW = scrW/4;
	// Opening Dialog
	String.resetBuffer;
	showStatus("STEP 1/3: directories...");
	Dialog.create("pLLP ANALYZER v0.8 - STEP 1/3");
	Dialog.setLocation(DiaW,DiaH);
	  Dialog.addMessage("click  'OK'  or hit space to define directories for...");
	  Dialog.addMessage("1. 8- / 16-bit image data \n2. segmented binaries \n3. output folder for... \n\n     - result tables.txt \n     - registered pLLP.tif \n     - stats.txt \n     - plots.tif");
	  Dialog.addCheckbox("Check to include segmentation", false);
	  Dialog.addMessage("click 'HELP' for info");
	info(); // info Log
	Dialog.show();
	nuc = Dialog.getChoice();
// 	### Variables and identifiers dialog box ###
	//	--- Directories 
	// Directories
		showStatus("STEP 1/3: 8-/16-bit input");
		org	= getDirectory("choose input directory: 8-/16-bit image data");
	  	ofl = getFileList(org);
	  	orglength = ofl.length;
	  	showStatus("STEP 1/3: binary input");
		bin	= getDirectory("choose input directory: segmented binary");
	  	bfl = getFileList(bin);
	  	binlength = bfl.length;
	  	showStatus("STEP 1/3: output");
		output 	= getDirectory("choose output directory");
			// get dimensions
			run("Bio-Formats Macro Extensions");
			id = bin+bfl[0];
			Ext.setId(id);
			Ext.getSeriesName(seriesName);
			Ext.getImageCreationDate(creationDate);
  			Ext.getPixelsPhysicalSizeX(sizeX);
  			Ext.getPixelsPhysicalSizeY(sizeY);
  			Ext.getPixelsPhysicalSizeZ(sizeZ);
  			Ext.getPlaneTimingDeltaT(deltaT, 2);
  			Ext.getSizeC(sizeC);
	// --- Variables and Identifiers Dialog Box ---
	showStatus("STEP 2/3");
	Dialog.create("pLLP ANALYZER v0.8 - STEP 2/3");
	Dialog.setLocation(DiaW,DiaH);
	Dialog.addMessage("DATE OF EXPERIMENT"); 
		//Dialog.addString("Name of Experiment:", seriesName, 15);
		Dialog.addNumber("Date of Experiment:", creationDate, 0, 8, "[yymmdd]");
		//Dialog.addNumber("Scale:", 3.8760, 4, 5, "  [px/µm]:");
	Dialog.addMessage("CHECK IMAGE DIMENSIONS")
		Dialog.addNumber("X-spacing:", sizeX, 2, 4, "  [µm]");
		Dialog.addNumber("Y-spacing:", sizeY, 2, 4, "  [µm]");
		Dialog.addNumber("Z-spacing:", sizeZ, 2, 4, "  [µm]");
		Dialog.addNumber("Time interval:", deltaT, 3, 4, "  [h]");
		//Dialog.addNumber("Channels:", sizeC, 0, 1, "#");
		//Dialog.addCheckbox("Count nuclei?", true);
	Dialog.addMessage("click -> OK <- to proceed to STEP 3/3\nclick 'HELP' for info");
		// Help Button see functions section
	help();
		Dialog.show(); // show dialog before retrieving input
	date = d2s(Dialog.getNumber(), 0); // get first dialog input
	xs = Dialog.getNumber(); // get second dialog input
	ys = Dialog.getNumber(); // get fthird dialog input
	zs = Dialog.getNumber(); // get fourth dialog input
	time = Dialog.getNumber(); // get fifth dialog input
	nuc = Dialog.getChoice();
	// --- Genotype Input Dialog box ---
	showStatus("STEP 3/3");
	pos = newArray(binlength);  // First, create empty array "pos" to be filled with Positional identifiers
			//print(pos[0], pos[1], pos[2]);
	Dialog.create("pLLP ANALYZER v0.8 - STEP 3/3");
	Dialog.setLocation(DiaW,DiaH);
	Dialog.addMessage("Define genotypes");
	for (j = 0; j < binlength; j++){
		pos[j] = j;
		//d = pos[j];
		c = pos[j]+1;
		//print(c);
			if (j<9) { // because j starts from zero
			Dialog.addString("Position "+d2s(0,0)+d2s(c,0), "??", 6);
			} else {Dialog.addString("Position "+d2s(c,0), "??", 6);}
	}
	Dialog.addMessage("       ------------------------------------\nclick 'OK' to finish input and start macro\n       ------------------------------------");
		Dialog.show();
	// --- Progress Bar ---
	//progress = "[Progress]";
	//run("Text Window...", "name="+ progress +" width=30 height=2 monospaced");
	
// ############################  ENTER 1st LOOP TO INCREMENT OVER EACH FILE OF INPUT FOLDERS ################################
	// create empty arrays
	types = newArray(binlength);
	embryoIDs = newArray(binlength);
	embryodirs = newArray(binlength);
	
	for (b = 0; b < binlength; b++) {
		setBatchMode(true);
		// 	Define and variables
			posi = pos[b]+1;
			//position = d2s(posi, 0);
			if (posi<10) {position=d2s(0,0)+d2s(posi,0);}else{position=d2s(posi,0);}
			type = Dialog.getString(); // gets the genotype in every subsequent loop
			types[b] = type;
			embryoID = date + "." + position;
			embryoIDs[b] = embryoID;
		// create directories for single embryos to save results
		embryodir = output + File.separator + embryoID + File.separator;
		File.makeDirectory(embryodir);
		// print StatsLog descriptors
		if (b==0) {StatsLogInfo();}
		// print Embryo ID 
		print("¸.·´¯`·.¸><(((º> "+" ID: "+embryoID+" | GT: "+type+"  <º))><¸.·`¯´·.¸");
//Stack.getActiveChannels(string)
		// open and define binary
		open(bin+bfl[b]);
		  BIN = getTitle();
		// open and define orginal 
		open(org+ofl[b]);
		  ORG = getTitle();
			dotIndex = indexOf(ORG, ".");
			title = substring(ORG, 0, dotIndex);
// 	Create Orphan measuring Row
	makeOval(10, 10, 5, 5);
	roiManager("measure");
	roiManager("reset");
// ############################  ENTER 2nd LOOP TO INCREMENT OVER EACH SLICE OF THE TIME-SERIES ################################

	selectImage(BIN); // select binary
		for (i=1 ; i<=nSlices(); i++) {
		s = nSlices();
		setSlice(i);
		run("Analyze Particles...", "size=150-Infinity pixel include add");
		// Loop though ROI List
		roiManager("show none"); // supress roimanager popping up
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
		//waitForUser("WAIT");
		run("Properties...", "channels=1 slices=1 frames=[s] unit=micron pixel_width=[xs] pixel_height=[ys] voxel_depth=[zs] frame=[time] global");
		//run("Set Scale...", "distance=[scale] known=1 pixel=1 unit=micron"); // Scale defined in first dialog box
		n = roiManager("count");
		m = n-1;
			// Duplicate most-right ROI
			selectImage(ORG);
			roiManager("show none"); // supress roimanager popping up
				roiManager("Select", m);
				run("Enlarge...", "enlarge=5");
				run("Duplicate...", "use");
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
							run("Rotate... ", "angle=[A] grid=1 interpolation=Bilinear slice"); }
				run("Flip Horizontally");
			selectImage(ORG); // select & deselect to remove selected ROIs
				run("Select None");
			// 	Measure and save segmented Mask ROI
				// create directory for ROIs
					embryorois = embryodir + File.separator + "ROIs" + File.separator;
					embryodirs[b] = embryodir;
					File.makeDirectory(embryorois);
			selectImage(BIN);
			roiManager("show none"); // supress roimanager popping up
				roiManager("Select", m);
				roiManager("save selected", embryorois + "_s" + i + ".zip");
				run("Set Measurements...", "area centroid bounding fit shape feret's stack redirect=None decimal=2");
				//run("Extended Particle Analyzer", "pixel show=Masks redirect=None keep=None display");
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
    						XN = (X2 - X0) + XED; }
    					LE = XN + (W/2); // Leading Edge 
    					T = time * r; // Time interval
    				setResult("Embryo", r, embryoID); // set Results
    				setResult("GT", r, type);
    				setResult("Time", r, T);
    				setResult("Deg", r, A);
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
		close(ORG);
		setBatchMode("exit and display");
			run("Images to Stack", "method=[Copy (top-left)] name=Stack title=[] use");
	//run("Images to Stack", "method=[Scale (smallest)] name=Stack title=[] use");
		run("Flip Horizontally", "stack");
		saveAs("Tiff", embryodir + embryoID + "_pLLP.tif");
		close();
	// Save Results Table
		run("Input/Output...", "jpeg=100 gif=-1 file=.txt use_file copy_column copy_row save_column");
		saveAs("results", embryodir + embryoID + "_Results" + ".txt");
		//if (i==1){
		//	String.copyResults();
		//} else {String.append(String.copyResults());}
	// Calulate Stats and show in Log
		StatsLog();
	// Correlate Results
		print("------------------- LM Fit --------------------");
		run("Correlate Results", "x=Time y=LE_N equation=[Straight Line] show graph=Circles");
		saveAs("Tiff", embryodir + embryoID + "_ScatterPlot");
		close();
		//IJ.renameResults("Results");
		cleanup();
	}
// Save statistics from log file
	selectWindow("Log");
	saveAs("Text", output + date + "_Stats" + ".txt");
	//getrois();
	boxplot();
	updateResults();
	combRes = output + File.separator + date + "_CombinedResults.txt" + File.separator;
	saveAs("results", output + date + "_CombinedResults" + ".txt");
	cleanup();
	run("Create Boxplot", "use=[External file...] open=combRes round group=GT");
		wait(350);
		run("Capture Screen");
		makeRectangle(810, 181, 300, 428);
		run("Crop");
		saveAs("Tiff", output + date + "_BoxRound");
		run("Close");
	run("Create Boxplot", "use=[] le_v group=GT");
		wait(350);
		run("Capture Screen");
		makeRectangle(810, 181, 300, 428);
		run("Crop");
		saveAs("Tiff", output + date + "_BoxSpeed");
		run("Close");
	if(getBoolean("DONE! :)./n Open output directory?"))
    call("bar.Utils.revealFile", output);

// ===================================================================================================
// ######################################### FUNCTIONS ###############################################
// ===================================================================================================
function cleanup(){
		if (isOpen("Results")) { 
		selectWindow("Results"); 
		run("Close"); 
    	} 
		if (isOpen("ROI Manager")){
		selectWindow("ROI Manager");
		run("Close");
		}
	run("Close All");
}

function StatsLogInfo() {
	print("======================== STATS ========================");
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
    		variance_area = total_variance_Area/(nResults-1);
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
    			mean_V = total_V/nResults;
				}
			for (a = 1; a < nResults(); a++) {
    			total_variance = total_variance + (getResult("LE_V", a)-(mean_V))*(getResult("LE_V", a)-(mean_V));
    			variance_V = total_variance / (nResults-1);
				}
			nV = n-1;
			SD_V = sqrt(variance_V); // SD of "LE_V" column (note: requires variance)
			SE_V = (SD_V/(sqrt(nV)));
			CI95_V = 1.96*SE_V;
// Print stats
print("------------------------ AREA -------------------------");
	print("[N] Datapoints = "+ n);
	print("Mean Area = "+ mean_area + " [µm^2]");
	print("Var Area = "+ variance_area);
	print("SD Area = "+ SD_Area);
	print("SE Area = "+ SE_Area);
	print("95% CI Area = "+ CI95_Area);
print("---------------------- ROUNDNESS ----------------------");
	print("[N] Datapoints = "+ n);
	print("Mean Roundness = "+ mean_round + " [inv.AR]");
	print("Var Roundness = "+ variance_round);
	print("SD Roundness = "+ SD_Round);
	print("SE Roundness = "+ SE_Round);
	print("95% CI Roundness = "+ CI95_Round);
print("---------------------- VELOCITY -----------------------");
	print("[N] Datapoints = "+ nV);
	print("Mean Velocity = "+ mean_V + " [µm/h]");
	print("Var Velocity = "+ variance_V);
	print("SD Velocity = "+ SD_V);
	print("SE Velocity = "+ SE_V);
	print("95% CI Velocity = "+ CI95_V);
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
showMessage("Gathering results....\n \nCheck progress bar to track progress");
	for (e = 0; e < binlength; e++) {
		showProgress(e, binlength);
		setBatchMode(true);
			//posi = pos[e]+1;
			//if (posi<9) {position=d2s(0,0)+d2s(posi,0);}else{position=d2s(posi,0);}
			type = types[e];
			embryoID = embryoIDs[e];
		//if (e==0) {StatsLogInfo();}
		open(bin+bfl[e]);
		  BIN = getTitle();
		open(org+ofl[e]);
		  ORG = getTitle();
			dotIndex = indexOf(BIN, ".");
			title = substring(BIN, 0, dotIndex);
	makeOval(10, 10, 5, 5);
	roiManager("measure");
	roiManager("reset");
// ############################  ENTER 2nd LOOP TO INCREMENT OVER EACH SLICE OF THE TIME-SERIES ################################

	selectImage(BIN); // select binary
		for (f=1 ; f<=nSlices(); f++) {
		s = nSlices();
		setSlice(f);
		run("Analyze Particles...", "size=150-Infinity pixel include add");
		// Loop though ROI List
		roiManager("show none"); // supress roimanager popping up
			for (p=0 ; p<roiManager("count"); p++) {
				roiManager("select", p);
				run("Set Scale...", "distance=1 known=0.00005 pixel=1 unit=micron");
				List.setMeasurements;
  				x = List.getValue("X");
    			roiManager("rename", x);
				}
		roiManager("Sort");
		run("Properties...", "channels=1 slices=1 frames=[s] unit=micron pixel_width=[xs] pixel_height=[ys] voxel_depth=[zs] frame=[time] global");
		n = roiManager("count");
		m = n-1;
			selectImage(BIN);
			roiManager("show none"); // supress roimanager popping up
				roiManager("Select", m);
				run("Set Measurements...", "area centroid bounding fit shape feret's stack redirect=None decimal=2");
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
    				setResult("Embryo", r, embryoID); // set Results
    				setResult("GT", r, type);
    				setResult("Time", r, T);
    				setResult("Deg", r, A);
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
    						LEV = LENED / time;
    						}
    				setResult("LE_N", r, LEN); // setResult Leading Edge Normalized (LE_N)
    			    setResult("LE_N_ED", r, LENED); // setResult Leading Edge Normalized Euclidian Distance (LE_N_ED)
    			    setResult("LE_V", r, LEV); // setResult Leading Edge Velocity (LE_V)
    			updateResults();
			}
		close(BIN); // could be reduced to close(BIN, ORG); or close (".tif");
		close(ORG);
	}
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
