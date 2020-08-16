///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////									INSTRUCTIONS			 		        ///////////	
///////////////////////////////////////////////////////////////////////////////////////////////
///////////								OPTIMIZED FOR... 						    ///////////
///////////			- 25x microscopic data of the 								    ///////////
///////////			- zebrafish lateral line system	@ end of migration				///////////
/////////// 		- cldnb:lyn-gfp Label & DAPI Staining		   					///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////	This macro is designed to count cell clusters and nuclei inside of each	///////////
/////////// This macro reads '.tif' files from an input directory of your choice,   ///////////
/////////// 				applies some processing algorithms and				    ///////////
///////////  puts out a results table with geometrical measures and the nuclei count///////////
/////////// into a directory of your choice. It also captures flattened pictures of ///////////
/////////// each channel displaying all ROIs measured and saves them as well. Before///////////
/////////// usage plase run the ' general purpose FolderBatch_Tiff.SD_RC.ijm' macro ///////////
/////////// 							on your RAW data.							///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////			To use this macro, press 'Run', then follow instructions. 		///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////         			     David Kleinhans, 22.06.2016				    ///////////
///////////						  Kleinhansda@bio.uni-frankfurt.de				    ///////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//	------------------ VARIABLES -----------------
	version = "1.0";
	header = "anaLLzR2D v"+version+" ";
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

// 	CLEANUP
	cleanup();
	//open();
//	------------------ DIALOG -----------------
	Dialog.create(header);
	//Dialog.addMessage("~~~~~~~~~~~ MACRO OPTIONS ~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	Dialog.addCheckbox("Count nuclei?", false);									// 1. multi
	Dialog.addCheckbox("Sort ROIs", true);										// 1. multi
	Dialog.addSlider("Membrane label blur (C1)", 1, 8, 3);						// 2. MemBlur
	Dialog.addSlider("Closing filter [px] (C1)", 1, 20, 10);					// 2. CloseMorph
	Dialog.addSlider("Nuclei label blur (C2)", 0.25, 0.55, 0.4);				// 3. NucBlur
	Dialog.show();
		multi 	= Dialog.getCheckbox();											// 1. multi
		sort	= Dialog.getCheckbox();											// 2. sort
		memblur = Dialog.getNumber();											// 2. MemBlur
		closemorph = Dialog.getNumber();										// 2. MemBlur
		nucblur = Dialog.getNumber();											// 3. NucBlur
	
//	--------- SET VARIABLES AND DIRECTORIES --------
	// dirs
	dir = getDirectory("Choose image data directory");
	list = getFileList(dir);
	shuffle(list);
	setBackgroundColor(0,0,0);
	run("Colors...", "foreground=black background=black selection=red");
	
// 	--------------------------------------------------
// 	--------------------- Loop -----------------------
// 	--------------------------------------------------

	for (i = 0; i < list.length; i++) {
	IJ.redirectErrorMessages();
	roiManager("reset");
	// load file
		file = dir+list[i];
	if (multi) {
		run("Bio-Formats Importer", "open=["+file+"] color_mode=Grayscale split_channels view=Hyperstack stack_order=XYCZT");
		} else {run("Bio-Formats Importer", "open=["+file+"] color_mode=Grayscale view=Hyperstack stack_order=XYCZT");}
		// get filename from list
		name = list[i];
		// remove file ending
		filename = replace(name, ".tif", "");
		// rename to hide image name in panel
		rename("ibetyouwould");
		name = "ibetyouwould";
		// directories
		dir = File.directory;
		pardir = File.getParent(dir);
	//	CREATE SUBDIRS
		imgdir = pardir + File.separator + "03 - processed" + File.separator;
			File.makeDirectory(imgdir);
		if (multi) {
			ccdir = imgdir + File.separator + "CCs" + File.separator;
			File.makeDirectory(ccdir);
		}
		datdir = pardir + File.separator + "04 - results" + File.separator;
			File.makeDirectory(datdir);
		roidir = datdir + File.separator + "rois" + File.separator;
			File.makeDirectory(roidir);
		tabdir = datdir + File.separator + "tables" + File.separator;
			File.makeDirectory(tabdir);
	//	GET BIOFORMATS DATA
	run("Bio-Formats Macro Extensions");
		id = dir+list[i];
		Ext.setId(id);
		Ext.getSeriesName(seriesName);
		Ext.getImageCreationDate(creationDate);
  		Ext.getPixelsPhysicalSizeX(sizeX);
  		Ext.getPixelsPhysicalSizeY(sizeY);
  		Ext.getPixelsPhysicalSizeZ(sizeZ);
	//	PRINT METADATA TO LOG WINDOW
		if (i==0) {
		print(header);
		print("start: "+ hour + ":" + minute);
		print("Dimensions:");
			if (multi) {print("   Dual channel");} else {print("   single channel");}
  			print("   X/Y Resolution: "+sizeX+"/"+sizeY + " µm");
  			print("   Z Resolution: "+sizeZ+" µm");
		print("Macro options:");
			if (multi) {
			print("   C1 - Membrane blur: 5");
			print("   C2 - Nuclei blur: 0.6");
			} else {print("   C1 - Membrane blur: 6");}
		}
	// NAME IMAGES
		if (multi) {
		selectWindow(name+" - C=0");
		rename(filename+"_C1");
		C1 = getTitle();
		selectWindow(name+" - C=1");
		rename(filename+"_C2");
		C2 = getTitle();
		} else {
			selectWindow(name);
			rename(name+"C1");
			C1 = getTitle();
			}
			//waitForUser("wait");
// 	--------------- PRE-PROCESSING -----------------
	// BACKGROUND SUBTRACTION
		selectWindow(C1);
		resetMinAndMax();
		run("Duplicate...", " ");
		C1D = getTitle();
		run("Subtract Background...", "rolling=100");
		//run("Morphological Filters", "operation=Closing element=Disk radius=50");
		run("Morphological Filters", "operation=Opening element=Disk radius="+closemorph);
		C1DF = getTitle();
		close(C1D);
		run("Gaussian Blur...", "sigma="+memblur+" scaled");
		resetMinAndMax();
		//run("Gaussian Blur...", "sigma=5 scaled");
	//	THRESHOLDING
		//waitForUser("threshold");
		//setAutoThreshold("MaxEntropy dark");
		setAutoThreshold("Moments dark");
		setOption("BlackBackground", false);
		//waitForUser("138 Moments");
		run("Convert to Mask");
	//	PARTICLE ANALYSIS
		run("Analyze Particles...", "size=250-2000 exclude add");
		selectWindow(C1);
		roiManager("Show All without labels");
		run("Enhance Contrast", "saturated=0.35");
		//run("In [+]");
	//	CHECK ROIS
		waitForUser("Check ROIs, correct if necessary\n \nuse the 'Elliptical selections' tool to add rois\nuse the 'Selection Brush Tool' to modify rois\nuse the roi managers 'Add'/'Update'/'Delete' functions\n \nclick 'OK' to proceed");
		if (sort) {
		sortROIs();
		}
	// capture of C1 + ROIs
		selectWindow(C1);
		run("Enhance Contrast", "saturated=0.35");
		roiManager("Show All without labels");
		run("Capture Image");
		saveAs("Tiff", imgdir + filename + "_C1_capt");
		close();
//	------------ COUNTING & MEASUREMENTS -------------
	//	MEASURE ROIs
		run("Set Measurements...", "area centroid center perimeter bounding shape feret's redirect=None decimal=2");
		roiManager("deselect");
		roiManager("measure");
		//saveAs("results", datdir + "CC.txt");
		roiManager("deselect"); 
		//IJ.renameResults("Numbers");
     	roiManager("save", roidir + filename + "_ROIset.zip");
		close(C1);
		print("~~~~~ processed "+list[i]+" ~~~~~");
		if (multi) {
	// 	COUNT NUCLEI
		selectWindow(C2);
		run("Enhance Contrast", "saturated=0.35");
		run("Gaussian Blur...", "sigma="+nucblur+" scaled");
		for (j=0 ; j<roiManager("count"); j++) {
			selectWindow(C2);
    		roiManager("select", j);
    			run("Duplicate...", " ");
    			CCD = getTitle();
    			run("Enhance Contrast", "saturated=0.35");
    			run("Find Maxima...", "noise=12 output=[Point Selection]");
    			run("Capture Image");
    			saveAs("Tiff", ccdir + filename + "_CC"+j);
    			close();
    			close(CCD);
    		selectWindow(C2);
    		roiManager("select", j);
    		IJ.renameResults("This");
			run("Find Maxima...", "noise=0 output=Count");
			//waitForUser("wait");
			NC = getResult("Count");
			selectWindow("This");
			IJ.renameResults("Results")
			setResult("Nuclei", j, NC);
			setResult("Pos", j, j+1);
		}
	// 	capture of C2 + ROIs
		selectWindow(C2);
		roiManager("Show All without labels");
		run("Capture Image");
		saveAs("Tiff", imgdir + filename + "_C2_capt");
	}
	saveAs("results", tabdir + filename + ".txt");
	cleanup();
	}
// FINISH LOOP
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("finished: "+ hour + ":" + minute);
selectWindow("Log");  //select Log-window 
saveAs("Text", pardir + "Log_" + "v"+version+"_"+year+month+"0"+dayOfMonth+".txt"); 

//############################################### FUNCTIONS ######################################################
function cleanup(){
	run("Close All");
	run("Clear Results");
	roiManager("reset");
	call("java.lang.System.gc");
	if (isOpen("Results")) {
    selectWindow("Results");
    run("Close");
   } 
}

function metadata() {
	//Meta = getMetadata("Info");
	//Info = getImageInfo();
	//print("Meta", "Info");
}

function sortROIs() {
	run("Set Measurements...", "centroid redirect=None decimal=0");
			for (j=0 ; j<roiManager("count"); j++) {
    			roiManager("select", j);
   			 	roiManager("measure");
    			x = getResult("X",0);
    			w = getWidth();
    			a = x/w;
    			roiManager("rename", a);
    			run("Clear Results");
				}
		setBatchMode(false);
		roiManager("sort");	
			for (j=0 ; j<roiManager("count"); j++) {
    			roiManager("select", j);
    			roiManager("rename", j);
    			run("Clear Results");
				}	
			for (j=0 ; j<roiManager("count"); j++) {
    			roiManager("select", j);
    			roiManager("rename", j+1);
    			run("Clear Results");
				}	
			//close();
}
function shuffle(array) { //http://imagej.1557.x6.nabble.com/Randomize-order-of-an-array-td3693530.html
  n = array.length;       // The number of items left to shuffle (loop invariant).
  print("Number of images to process: "+n);
  while (n > 1) {
    k = randomInt(n);     // 0 <= k < n. 
    n--;                  // n is now the last pertinent index; 
    temp = array[n];      // swap array[n] with array[k] (does nothing if k == n). 
    array[n] = array[k]; 
    array[k] = temp; 
  } 
}
function randomInt(n) { 
  return n * random(); 
}
