/* 
    VolumestJ_ROIsGenerator is an ImageJ macro developed to manually generate ROIs,
    Copyright (C) 2020  Jorge Valero Gómez-Lobo

    VolumestJ_ROIsGenerator is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    VolumestJ_ROIsGenerator is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//This macro has been developed by Dr Jorge Valero (jorge.valero@achucarro.org). 
//If you have any doubt about how to use it, please contact me.

//License


Dialog.create("GNU GPL License");
Dialog.addMessage("VolumestJ_ROIsGenerator Copyright (C) 2020 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("VolumestJ_ROIsGenerator comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();

//CloseAll is a self generated function to close all windows
CloseAll();

//Select the Images folder, the macro will use the parent folder (dirgeneral) of the images folder as the place to save other folders and files generated

dirimage= getDirectory("Please, select the images folder");
dirgeneral=File.getParent(dirimage);

//generation of ROIs and Processed Images folders
roiFolder=dirgeneral+"/ROIs/";
ProccFolder=dirgeneral+"/Processed/";

if (File.exists(roiFolder)==false) File.makeDirectory(roiFolder);
if (File.exists(ProccFolder)==false) File.makeDirectory(ProccFolder);


//Checking of the existence of a Parameters file (ROIGParameters.txt) and if does not exists opens a Parameters menu to select ROIs names and visualization parameters
if (File.exists(dirgeneral+"/ROIGParameters.txt")==false){
	n=getNumber("How many ROI types do you want to define?", 1);
	tiporoi=newArray(n);
	
	//Parameters menu
	Dialog.create("Parameters Menu");
	for(i=1; i<=n; i++) Dialog.addString("Name for ROI type "+ i+ ":","ROI" +i );
	Dialog.addNumber("Select the number of the channel you will use to draw contours", 1);
	Dialog.addCheckbox("Enhance contrast", true);
	Dialog.show();

	//Variables collection from paramters menu
	for(i=1; i<=n; i++) tiporoi[i-1]=Dialog.getString();
	chan=Dialog.getNumber();
	enh=Dialog.getCheckbox();

	//Log register of ROIs Parameters
	print ("ROI types: \n"+n); 
	print("TIPO ROIs:");
	for (i=0; i<tiporoi.length; i++) print(tiporoi[i]);
	print("Channel:");
	print(chan);
	print ("Enhance contrast:");
	print(enh);
	selectWindow("Log");
	saveAs("Text", dirgeneral+"/ROIGParameters.txt");
	selectWindow("Log");
	run("Close");
}

//Loading Parameters from ROIGParameters.txt file
else{
	param=File.openAsString(dirgeneral+"/"+"ROIGParameters.txt");
	Vparam=split(param, "\n");
	n=parseFloat(Vparam[1]);
	tiporoi=newArray(n);
	for (i=0; i<n; i++) tiporoi[i]=Vparam[3+i];
	chan=Vparam[n+4];
	enh=Vparam[n+6];
}

//Activation of drawing loop
previous="";
imageload(dirimage, roiFolder, ProccFolder);


//Function to find files inside the images folder
function imageload(path, roipath, propath){
	folders=getFileList(path);
	for (i=0; i<folders.length; i++){
		if (File.isDirectory(path+folders[i])){
			previous=substring(folders[i], 0, lengthOf(folders[i])-1);
			
			//generation of group folder inside ROIs folder
			roiFolder2=roipath+previous+"/";
			if (File.exists(roiFolder2)==false) File.makeDirectory(roiFolder2);
			ProccFolder2=propath+previous+"/";
			if (File.exists(ProccFolder2)==false) File.makeDirectory(ProccFolder2);
			
			imageload(path+folders[i], roiFolder2, ProccFolder2);
		}
		else DrawRoi(path+folders[i], roiFolder2, ProccFolder2);
	}
}

//Function to Draw Rois
function DrawRoi(imagepath, roipath, propath){
	
	//Opening of image
	run("Bio-Formats Importer", "open=["+imagepath+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
	name=File.nameWithoutExtension;
	if (enh==true) run("Enhance Contrast", "saturated=0.35");
	run("Brightness/Contrast...");
	
	//call to the function to manually create ROIs
	rs=1;
	do{
		dibujaPol(rs);
		sameimage=getBoolean("Do you want to generate more ROIs in this image?");
		rs++;
	}while (sameimage==true);
	//Closing and moving them to processed folder
	run("Close All");
	File.rename(imagepath, propath+folders[i]);	
}






//function to draw ROIs in one particular image
function dibujaPol(rs){
	//ROIs loop
	for (q=0; q<tiporoi.length; q++){
		
		roiFolder3=roipath+tiporoi[q]+"/";
		//drawing tool
		setTool("polygon");
		
		do{
			//Allowed user interaction
			waitForUser("Please, draw ROIs "+tiporoi[q]+", and add them to the ROI Manager by clicking t");

			//Rois checking
			numberrois=roiManager("count");
			if (numberrois==0){
				waitForUser("YOU DID NOT DRAW ANY ROI");
				cont=getBoolean("Do you want to continue with next ROI/Image?");
			}
			else {
				roiManager("Show All");
				cont=getBoolean("Do you want to save this/these ROIs?");
			}
		}while (cont==false);
		
		numberrois=roiManager("count");
		if (numberrois>0 && cont==true){
			roiManager("Deselect");
			
			//Generation of folders for each type of ROI inside group and ROIs folders
			if (File.exists(roiFolder3)==false) File.makeDirectory(roiFolder3);
			
			//Saving of ROIs
			roiManager("Save", roiFolder3+name+rs+".zip");
			roiManager("reset");
		}	
	}
	
}


//This function closes all windows
function CloseAll(){
	run("Close All");
	list = getList("window.titles");
     for (i=0; i<list.length; i++){
    	 winame = list[i]; 
     	selectWindow(winame);
     	run("Close");
     }
}