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
	version = 1;
	header = "ClusterAnalysis v"+version+" ";
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

// 	CLEANUP
	cleanup();
	//open();
//	------------------ DIALOG -----------------
	Dialog.create(header);
	//Dialog.addMessage("~~~~~~~~~~~ MACRO OPTIONS ~~~~~~~~~~~\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	Dialog.addCheckbox("Count nuclei?", true);									// 1. multi
	Dialog.addCheckbox("Sort ROIs", true);										// 1. multi
	//Dialog.addSlider("Membrane label blur (C1)", 4, 8, 6.4);					// 2. MemBlur
	//Dialog.addSlider("Nuclei label blur (C2)", 0.25, 0.55, 0.4);				// 3. NucBlur
	Dialog.show();
		multi 	= Dialog.getCheckbox();											// 1. multi
		sort	= Dialog.getCheckbox();											// 2. sort
		//memblur = Dialog.getNumber();											// 2. MemBlur
		//nucblur = Dialog.getNumber();											// 3. NucBlur
	
//	--------- SET VARIABLES AND DIRECTORIES --------
	// dirs
	dir = getDirectory("Choose image data directory");
	list = getFileList(dir);
	setBackgroundColor(0,0,0);
	
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
		name = list[i];
		filename = replace(name, ".tif", ""); 
		dir = File.directory;
		pardir = File.getParent(dir);
		run("8-bit");
	//	CREATE SUBDIRS
		imgdir = pardir + File.separator + "02 - Processed Images" + File.separator;
			File.makeDirectory(imgdir);
		ccdir = imgdir + File.separator + "CCs" + File.separator;;
			File.makeDirectory(ccdir);
		datdir = pardir + File.separator + "03 - Measurements" + File.separator;
			File.makeDirectory(datdir);
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
		print("   "+header);
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
		print("~~~~~ processing: "+list[i]+" ~~~~~");
	// NAME IMAGES
		if (multi) {
		selectWindow(name+" - C=0");
		rename(filename+"_C1");
		C1 = getTitle();
		selectWindow(name+" - C=1");
		rename(filename+"_C2");
		C2 = getTitle();
		} else {
			selectWindow(name+" - C=0");
			rename(name+"C1");
			C1 = getTitle();
			}
			//waitForUser("wait");
// 	--------------- PRE-PROCESSING -----------------
	// BACKGROUND SUBTRACTION
		selectWindow(C1);
		run("Duplicate...", " ");
		C1D = getTitle();
		run("Subtract Background...", "rolling=50");
		//run("Morphological Filters", "operation=Closing element=Disk radius=50");
		run("Morphological Filters", "operation=Opening element=Disk radius=20");
		C1DF = getTitle();
		close(C1D);
		//run("Gaussian Blur...", "sigma="+memblur+" scaled");
		run("Gaussian Blur...", "sigma=5 scaled");
	//	THRESHOLDING
		//waitForUser("threshold");
		//setAutoThreshold("MaxEntropy dark");
		setAutoThreshold("Moments dark");
		setOption("BlackBackground", false);
		run("Convert to Mask");
	//	PARTICLE ANALYSIS
		run("Analyze Particles...", "size=250-Infinity exclude add");
		selectWindow(C1);
		roiManager("Show All without labels");
		run("Enhance Contrast", "saturated=0.35");
		waitForUser("Check ROIs, correct if necessary");
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
		//waitForUser("multi");
		//IJ.renameResults("Numbers");
		roiManager("show none");
		print(datdir);
     	roiManager("Save", datdir + filename + "_ROIset.zip");
     	//waitForUser("roiM still open?");
		close(C1);
		//waitForUser("roiM still open?");
		//waitForUser("multi");
		if (multi) {
	// 	COUNT NUCLEI
		selectWindow(C2);
		run("Gaussian Blur...", "sigma=0.6 scaled");
		roiManager("open", datdir + filename + "_ROIset.zip");
		rcount = roiManager("count");
		//print(rcount);
		for (j=0 ; j<rcount; j++) {
			selectWindow(C2);
			roiManager("open", datdir + filename + "_ROIset.zip");
    		roiManager("select", j);
    		//waitForUser("multi");
    			run("Duplicate...", " ");
    			CCD = getTitle();
    			run("Enhance Contrast", "saturated=0.35");
    			run("Find Maxima...", "noise=0 output=[Point Selection]");
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
		saveAs("results", datdir + filename + ".txt");
		cleanup();
	}
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
