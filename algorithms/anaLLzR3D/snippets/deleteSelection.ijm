	ORG = getTitle();
	//selectWindow(R);
	n = nSlices();
	for(k=1; k<n; k++) {
		setSlice(k);
		run("Cut");
	}
	setSlice(1);