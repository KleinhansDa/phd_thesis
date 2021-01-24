# My PhD Thesis

Author: David Kleinhans

Title: *Mechano – Chemical Feedback Loops During Vertebrate Organ Development*

Citation:

## Abstract

For my thesis, I was interested to understand better how cellular shape and geometry impacts downstream cell and organ development. One regulator of motor proteins like non-muscle myosin is Shroom3, which recently has been been shown to be expressed and involved in the development of the zebrafish lateral line organ. Literature on development of the lateral line suggests that in order for a cell cluster to be deposited from the pLLP, rosette formation is a key requirement. To our surprise, when we first inspected the end of migration lateral line phenotype we found many individuals with a significant *increase* in cell clusters deposited. Therefore, in order to accurately quantify the morphogenic processes Shroom3 is involved in, I developed a new toolset that significantly improved and facilitated my research. The toolset consists of (1) a new sample mounting method that is based on a 3D agarose gel that increases the number of embryos that can be mounted and imaged at once and speeds up the imaging process significantly (2) for subseqent image analysis I developed four programs that automate the process and therefore make the results much more reproducible and the analysis much more efficient. Here I show that in absence of Shroom3 rosette formation in the migrating pLLP is destabilized leading to facilitated cell cluster deposition and I show how this might be related to traction forces due to a possible interdependence of pLLP acceleration and speed of migration. My results and methodology demonstrate the importance of morphology in guiding developmental processes and how rather small morphological changes on the cellular level can impact further development significantly.

## Read on

Following [this link](https://kleinhansda.github.io/phd_thesis/) you will get to the gitbook version. A gitbook is an ebook that is formatted as html and hosted on git. In this project, the gitbook is hosted unter \~/docs. You may download the pdf version from the \~/docs directory or from the gitbook page.

## Changes to the thesisdown template

I modified the original thesisbook template in a number of ways, correcting for some annoying behaviour

### flipbook

Since I did my PhD in developmental biology I had a lot of timelapse movies of developing organs. Actually it wasn't my idea but I thought it was super cool to have a flipbook of one of those organs on each page printed next to each page number.

package used:

implemented:

image dimensions:

### gitbook

The original gitbook renders with the start page named 'index', which is unpleasent.

In order to change the title pages name... . However doing so requires to rename the file to again to index.html + you also have to edit index.html and exchange all occurences of the new name with index.html.

### automations

1.  table knitting in pdf and html
