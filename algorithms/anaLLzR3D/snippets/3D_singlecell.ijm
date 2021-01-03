	ORG = getTitle();
	//n = nSlices();
	run("3D Manager");
	//selectWindow(R);
	Ext.Manager3D_AddImage();
	Ext.Manager3D_Count(nb); //get number of objects
	Ext.Manager3D_MultiSelect();
	for(k=0; k<nb; k++) {
		selectWindow(ORG);
		run("Duplicate...", "duplicate");
		if (k>0) {Ext.Manager3D_AddImage();}
		roscell = getTitle();
		Ext.Manager3D_GetName(k,obj);
		Ext.Manager3D_SelectAll();
		Ext.Manager3D_Select(k);
		Ext.Manager3D_Erase();
		run("Enhance Contrast...", "saturated=0.3 equalize process_all");
		run("8-bit");
		//saveAs("Tiff", rosdir + name + "_R" + pos + "_" + obj + "_RC_OMap" + ".tif");
		close(roscell);
		Ext.Manager3D_Reset();
	}
	Ext.Manager3D_Close();