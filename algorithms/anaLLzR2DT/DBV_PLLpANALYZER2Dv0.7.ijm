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
	
	run("Clear Results");
	roiManager("Associate", "false");
	String.resetBuffer;
	showStatus("STEP 1/3: directories...");
	Dialog.create("pLLP ANALYZER v0.6 - STEP 1/3");
	Dialog.setLocation(300,200);
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
	// --- Variables and Identifiers Dialog Box ---
	showStatus("STEP 2/3");
	Dialog.create("pLLP ANALYZER v0.6");
	Dialog.setLocation(300,200);
	Dialog.addMessage("DATE OF EXPERIMENT"); 
		Dialog.addNumber("Date of Experiment:", 161126, 0, 6, "[yymmdd]");
		//Dialog.addNumber("Scale:", 3.8760, 4, 5, "  [px/µm]:");
	Dialog.addMessage("IMAGE DIMENSIONS")
		Dialog.addNumber("X-spacing:", 0.2, 2, 4, "  [px]:");
		Dialog.addNumber("Y-spacing:", 0.2, 2, 4, "  [px]:");
		Dialog.addNumber("Z-spacing:", 0.5, 2, 4, "  [px]:");
		Dialog.addNumber("Time interval [h]:", 0.159, 3, 4, "    [h]:");
	//Dialog.addMessage("");
		Dialog.addCheckbox("Count nuclei?", false);
	//Dialog.addMessage("");
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
	Dialog.create("pLLP ANALYZER v0.6");
	Dialog.setLocation(300,200);
	Dialog.addMessage("Please define genotypes");
	for (j = 0; j < binlength; j++){
		c = pos[j];
			if (c<9) {
			Dialog.addString("Position 0"+d2s(c,0), "??", 4);
			} else {Dialog.addString("Position "+d2s(c,0), "??", 4)}}
	Dialog.addMessage("       ------------------------------------\nclick 'OK' to finish input and start macro\n       ------------------------------------");
		Dialog.show();
	// --- Progress Bar ---
	progress = "[Progress]";
	run("Text Window...", "name="+ progress +" width=30 height=2 monospaced");
	
// ############################  ENTER 1st LOOP TO INCREMENT OVER EACH FILE OF INPUT FOLDERS ################################
	for (b = 0; b <= binlength; b++) {
		setBatchMode(true);
		print(progress, "\\Update:"+b+"/"+100+" ("+(b*100)/10+"%)\n"+getBar(b, 10));
     	wait(200);
        //  if (endsWith(ofl[a],".tif")) { // only fetch tiff files
		// 	Define and variables
			posi = pos[b]+1;
			//position = d2s(posi, 0);
			if (posi<9) {position=d2s(0,0)+d2s(posi,0);}else{position=d2s(posi,0);}
			type = Dialog.getString(); // gets the genotype in every subsequent loop
			embryo = date + "." + position;
		// print StatsLog descriptors
		if (b==0) {StatsLogInfo();}
		// print Embryo ID 
		print("¸.·´¯`·.¸¸.·´¯`·.¸><(((º> "+" ID: "+embryo+" | GT: "+type+"  <º))><¸.·`¯´·.¸¸.·`¯´·.¸");
    	//print("--- preprocessing ---");
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
			// 	Measure segmented Mask ROI
			selectImage(BIN);
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
    				setResult("Embryo", r, embryo); // set Results
    				setResult("GT", r, type);
    				setResult("Time", r, T);
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
	//waitForUser("JOJO");
		run("Images to Stack", "method=[Copy (top-left)] name=Stack title=[] use");
	//run("Images to Stack", "method=[Scale (smallest)] name=Stack title=[] use");
		run("Flip Horizontally", "stack");
		//run("Enhance Contrast...", "saturated=0.3 process_all use");
		rename(embryo + "_pLLP.tif");
		pLLP = getTitle();
		saveAs("Tiff", output + pLLP + ".tif");
		close();
	// Save Results Table
		run("Input/Output...", "jpeg=100 gif=-1 file=.txt use_file copy_column copy_row save_column");
		saveAs("results", output + embryo + "_Measurements" + ".txt");
// Calulate Stats and show in Log
		StatsLog();
		//selectWindow("Log");
		//List.clear();
		cleanup();
	}
// Save statistics from log file
saveAs("Text", output + date + "_Stats" + ".txt");
// close progress bar
print(progress, "\\Close");

// ######################################### FUNCTIONS ###############################################
function cleanup(){
	run("Clear Results");
	roiManager("reset");
	run("Close All");
}

function getBar(p1, p2){
    n = 20;
    bar1 = "--------------------";
    bar2 = "********************";
    index = round(n*(p1/p2));
    if (index<1) index = 1;
    if (index>n-1) index = n-1;
    return substring(bar2, 0, index) + substring(bar1, index+1, n);
}

function gettime {
	years = newArray("10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20");
    months = newArray("01","02","03","04","05","06","07","08","09","10","11","12");
    days = newArray("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24", "25", "26", "27", "28", "29", "30", "31");
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     acdate ="Date: "+DayNames[dayOfMonth]+" ";
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+":";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute+":";
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     showMessage(TimeString);
  }

function StatsLogInfo() {
	print("======================== STATS ========================");
	print("[N] = number of datapoints");
	print("[Mean] = Added values / number of datapoints");
	print("[Var] = Variance = sigma^2 = E[(x-µ)^2]");
	print("[SD] = Standard Deviation = sigma = sqrt(E[X^2]-(E[X])^2)");
	print("[SE] = Standard Error = sigma/sqrt(n)");
	print("[95% CI] = Confidence Interval = 0.196*SE");
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
