// VolumestJ_v5.3.ijm
/* 
    VolumestJ is an ImageJ macro developed to estimate volumes from pre-generated ROIs and 
    microscopy images,
    Copyright (C) 2020  Jorge Valero Gómez-Lobo

    VolumestJ is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    VolumestJ is distributed in the hope that it will be useful,
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
Dialog.addMessage("VolumestJ Copyright (C) 2020 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("VolumestJ comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();


//CloseAll is a self generated function to close all windows;
CloseAll();

slicesuse=getBoolean("Do you want to analyze more than one section per image?");

run("Set Measurements...", "area perimeter redirect=None decimal=3");

//Select the Images folder, the macro will use the parent folder (dirgeneral) of the images folder as the place to save other folders and files generated
generalDir= getDirectory("Please, select general folder (it should contain the ROIS and Processed folders)");
if (File.exists(generalDir+"Results/")==false) File.makeDirectory(generalDir+"Results/");

//Obtain image areas per group;
groups=getFileList(generalDir+"ROIs/");
for (i=0; i<groups.length; i++){
	images=getFileList(generalDir+"Processed/"+groups[i]);
	ROIs=getFileList(generalDir+"ROIs/"+groups[i]);
	
	//Create tables for areas, perimeters and pixels
	tablearray=newArray(ROIs.length+1);
	tablearray[0]="Image name";
	for (ii=1; ii<tablearray.length; ii++) tablearray[ii]=substring(ROIs[ii-1], 0, lengthOf(ROIs[ii-1])-1);
	final=lengthOf(groups[i])-1;
	tabname=substring(groups[i], 0, final);
	TableCreator("Areas"+tabname, tablearray);
	TableCreator("Perimeters"+tabname, tablearray);
	TableCreator("Pixels"+tabname, tablearray);
	
	//Open and measure image areas
	roisArr=newArray();
	for (ii=0; ii<images.length; ii++){

		run("Bio-Formats Importer", "open=["+generalDir+"Processed/"+groups[i]+images[ii]+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");
		name=File.nameWithoutExtension();
		rename(name);
		run("Enhance Contrast", "saturated=0.35");
		sameimage=false;
		sectioncounter=1;
		do{
			//ROIs arrays to populate tables
			RAreas=newArray(ROIs.length+1);
			RPerim=newArray(ROIs.length+1);
			RPix=newArray(ROIs.length+1);
			RAreas[0]=name+sectioncounter;
			RPerim[0]=name+sectioncounter;
			RPix[0]=name+sectioncounter;

			sameimage=false;
			//Open and measure ROIs
			for(iii=0; iii<ROIs.length; iii++){
				
				if (File.exists(generalDir+"ROIs/"+groups[i]+ROIs[iii]+name+sectioncounter+".zip")){
					if (roisArr.length>0){
						if (name+sectioncounter+".zip"!=roisArr[roisArr.length-1]){
							roisArrtemp=newArray(name+sectioncounter+".zip");
							roisArr=Array.concat(roisArr, roisArrtemp);
						}
					}
					else {
						roisArrtemp=newArray(name+sectioncounter+".zip");
						roisArr=Array.concat(roisArr, roisArrtemp);
					}
					roiManager("open", generalDir+"ROIs/"+groups[i]+ROIs[iii]+name+sectioncounter+".zip");
					n=roiManager("count");
					if(n>1){
						roiManager("Combine");
						roiManager("Add");
						roiManager("Select", n);
						SliceNumber(sectioncounter);
						roiManager("Select", n);
					}
					else{
						roiManager("Select", 0);
						SliceNumber(sectioncounter);
						roiManager("Select", 0);
					}
					Overlay.addSelection
					roiManager("measure");
					RAreas[iii+1]=getResult("Area", 0);
					RPerim[iii+1]=getResult("Perim.", 0);
					getRawStatistics(nPixels, mean, min, max, std, histogram);
					RPix[iii+1]=nPixels;
					roiManager("reset");
					selectWindow("Results");
					run("Close");
					selectWindow(name);
					run("Select None");
					if (slicesuse==true){
						sectioncountertemp=sectioncounter+1;
						for(iv=0; iv<ROIs.length; iv++) {
							if(File.exists(generalDir+"ROIs/"+groups[i]+ROIs[iv]+name+sectioncountertemp+".zip")){
								sameimage=true;
								iv=ROIs.length+1;
							}	
						}
					}
				}
			}
			//Populate tables
			TablePrinter("Areas"+tabname, RAreas);
			TablePrinter("Perimeters"+tabname, RPerim);
			TablePrinter("Pixels"+tabname, RPix);
			sectioncounter++;
		}while (sameimage==true);
	}
			
	
	//Save tables
	SaveTable("Areas"+tabname, generalDir+"Results/");
	selectWindow("Areas"+tabname);
	run("Close");
	SaveTable("Perimeters"+tabname, generalDir+"Results/");
	selectWindow("Perimeters"+tabname);
	run("Close");
	SaveTable("Pixels"+tabname, generalDir+"Results/");
	selectWindow("Pixels"+tabname);
	run("Close");
	do{
		Table.open(generalDir+"Results/"+"Areas"+tabname+".xls");
	}while(isOpen("Areas"+tabname+".xls")==false);
	do{
		Table.open(generalDir+"Results/"+"Perimeters"+tabname+".xls");
	}while(isOpen("Perimeters"+tabname+".xls")==false);
	do{
		Table.open(generalDir+"Results/"+"Pixels"+tabname+".xls");
	}while(isOpen("Pixels"+tabname+".xls")==false);

		//Show images
		run("Tile");
		
		do{
			repeat=false;
			//Parameters and order of the images Menu
			Dialog.create("Image Data");
			Dialog.addNumber("Fraction of sections selected, 1 of each: ",6);
			Dialog.addNumber("Section thickness (same units as image calibration): ", 50);
			if (slicesuse==true)images=Array.copy(roisArr);
			it=newArray(images.length+1);
			it[0]="X";
			for (ii=1; ii<it.length; ii++) it[ii]=""+ii+"";
			for (ii=0; ii<images.length; ii++) Dialog.addChoice(images[ii], it, it[ii+1]);
			Dialog.show();
			
			//Menu values
			run("Close All");
			fraction=Dialog.getNumber();
			thickness=Dialog.getNumber();
			order=newArray(images.length);
			for (ii=0; ii<images.length; ii++){
				choice=Dialog.getChoice();
				if (choice!="X") order[ii]=parseFloat(choice);
				else order[ii]=choice;
			}
			orderWO=Array.deleteValue(order, "X");
			orderWO=Array.sort(orderWO);
			
			for (ii=0; ii<orderWO.length; ii++){
				if (orderWO[ii]!=ii+1){
					repeat=getBoolean("An error in the sequence of images has occured or a section is missing and volumes cannot be calculated", "Back to Menu", "DO NOT analyze these images");
					if (repeat==false) ROIs=newArray();
					ii=orderWO.length+1;
				}
			}
		} while(repeat==true);
		
		
		
		//Organize array for volume calculation
		for (ii=0; ii<ROIs.length; ii++){
			columnName=substring(ROIs[ii], 0, lengthOf(ROIs[ii])-1);
			selectWindow("Areas"+tabname+".xls");
			ArrArea=Table.getColumn(columnName);
			selectWindow("Perimeters"+tabname+".xls");
			ArrPerim=Table.getColumn(columnName);
			selectWindow("Pixels"+tabname+".xls");
			ArrPix=Table.getColumn(columnName);
			selectWindow("Areas"+tabname+".xls");
			ArrNames=Table.getColumn("Image name");
			
			//Counting non used sections
			Xn=0;
			for (iii=0; iii<order.length; iii++) if(toString(order[iii])=="X") Xn++;

			//Ordering sections values
			sizeArr=order.length-Xn;
			OrgAreas=newArray(sizeArr);
			OrgPerim=newArray(sizeArr);
			OrgPix=newArray(sizeArr);
			OrgNames=newArray(sizeArr);
			
			for (iii=0; iii<order.length; iii++) if(toString(order[iii])!="X"){
				OrgAreas[order[iii]-1]=ArrArea[iii];
				OrgPerim[order[iii]-1]=ArrPerim[iii];
				OrgPix[order[iii]-1]=ArrPix[iii];
				OrgNames[order[iii]-1]=ArrNames[iii];
			}
		
			//Call Cavalieri function
			CavVol=Cavalieri(OrgAreas, fraction, thickness);
			//Call ConicalVol function
			ConicVol=ConicalVol(OrgAreas, fraction, thickness);
			//Call Gundersen Coefficient of Error function
			ArrGCE=GCE(OrgAreas, OrgPerim, OrgPix, fraction, thickness);
			//Name of images used in order
			ImOrd="";
			for(rr=0; rr<OrgNames.length; rr++) ImOrd= ImOrd+toString(rr+1)+") "+OrgNames[rr]+" ";

			if (isOpen("Volumes")==false) VolTab();
			tablearray=newArray(tabname, columnName, CavVol, ConicVol, ArrGCE[0], ArrGCE[1], fraction, thickness, ImOrd);
			TablePrinter("Volumes", tablearray);
		}	
		CloseAllEx("Volumes");	
		waitForUser("You can now check and save volumes (Volumes table will be saved at the end)");		
}
//Save Volume Table
if (isOpen("Volumes")) SaveTable("Volumes", generalDir+"Results/");


//Cavalieri estimations
function Cavalieri(Areas, sectinterval, thickness){
	sumAr=0;
	n=Areas.length;
	//Summations
	for(i=0; i<n; i++) sumAr=sumAr+Areas[i];
	
	//Volume estimation
	V=sectinterval*thickness*sumAr;
	return(V);
}

//Conical volumes estimations

function ConicalVol(Areas, sectinterval, thickness){
	//Estimation of radius
	radius=newArray(Areas.length);
	for (i=0; i<Areas.length; i++) radius[i]=sqrt(Areas[i]/PI);
	//Estimation of distance between sections
	h=sectinterval*thickness;
	
	//Initial "virtual" section distance to first real section estimation
	h0=h/2;
	//Final "virtual" section distance to Final real section estimation
	hF=h/2;
	
	//Initial and final volumes estimations
	ini1=0;
	for (i=0; i<radius.length/2; i++){
		if(radius[i]==0) ini1=i+1; 
	}
	fin1=radius.length-1;
	for (i=radius.length-1; i>radius.length/2; i--){
		if(radius[i]==0) fin1=i-1; 
	}
	VolIni=PI*h0*pow(radius[ini1],2)/3;
	VolFinal=PI*hF*pow(radius[fin1],2)/3;
	SumVol=VolIni+VolFinal;

	//Total volume estimation
	for(i=0; i<radius.length-1; i++){
		if (radius[i]>0 && radius[i+1]>0) {
			Voltemp=(PI*h*(pow(radius[i],2)+pow(radius[i+1],2)+(radius[i]*radius[i+1])))/3;
			SumVol=SumVol+Voltemp;
		}
		
	}
	return(SumVol);
}

//Gundersen Coefficient of Error estimation
function GCE(Areas, Perims, Pixels, sectinterval, thickness){
	ArrGCE=newArray(2);
	sumPix=0;
	n=Areas.length;
	sumshapeF=0;
	A=0;
	//mod is a variable that allows considering images without ROIs
	mod=0;
	//Summations
	for(i=0; i<n; i++){
		sumPix=sumPix+Pixels[i];
		A=A+pow(Pixels[i], 2);
		if (Areas[i]>0) {
			shapeF=Perims[i]/sqrt(Areas[i]);
			sumshapeF=sumshapeF+shapeF;
		}
		else mod++;
	}
	n=n-mod;
	//Mean shape estimation
	meanShapeF=sumshapeF/n;

	//Variance due to noise estimation
	S2=0.0724*meanShapeF*sqrt(n*sumPix);

	//B and C estimations
	B=0;
	for(i=0; i<n-1; i++){
		if (Pixels[i]>0 && Pixels[i+1]>0) B=B+(Pixels[i]*Pixels[i+1]);
	}
	C=0;
	for(i=0; i<n-2; i++){
		if (Pixels[i]>0 && Pixels[i+2]>0) C=C+(Pixels[i]*Pixels[i+2]);
	}

	//Variance due to systematic random sampling
	Num=(3*(A-S2))-(4*B)+C;
	Varm0=Num/12;
	Varm1=Num/240;

	//m0 and m1 estimations
	TotalVarm0=S2+Varm0;
	TotalVarm1=S2+Varm1;

	//Gundersen coefficient of error estimations
	ArrGCE[0]=(sqrt(TotalVarm0))/sumPix;
	ArrGCE[1]=(sqrt(TotalVarm1))/sumPix;

	return ArrGCE;
	
}

//This function creates Volumes table
function VolTab(){
	tablearray=newArray("Folder", "ROI name", "Cavalieri", "TCS", "m0 CE", "m1 CE",  "Section interval", "Section Thickness", "Images order");
	TableCreator("Volumes", tablearray);
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

//This function closes all windows except one
function CloseAllEx(exception){
	run("Close All");
	list = getList("window.titles");
     for (i=0; i<list.length; i++){
    	 winame = list[i];
     	
     	if(winame!=exception){
     		selectWindow(winame);
     		run("Close");
     	}
     }
}

//This function generates tables
function TableCreator(tabname, tablearray){
	run("New... ", "name=["+tabname+"] type=Table");
	headings=tablearray[0];
	for (i=1; i<tablearray.length; i++)headings=headings+"\t"+tablearray[i];
	print ("["+tabname+"]", "\\Headings:"+ headings);
	
}

//This function prints values in tables
function TablePrinter(tabname, tablearray){
	line=tablearray[0];
	for (i=1; i<tablearray.length; i++) line=line+"\t"+tablearray[i];
	print ("["+tabname+"]", line);
	
}

//This function save tables
function SaveTable(tablename, dirRes){
		selectWindow(tablename);
		 saveAs("Text", dirRes+tablename+".xls");
	}

//This function place the text string1 in a pre-selected ROI
function SliceNumber(string1){
	getPixelSize(unit, pixelWidth, pixelHeight);
	getDimensions(width, height, channels, slices, frames);
	x=getValue("X")/pixelWidth;
	y=getValue("Y")/pixelWidth;
	run("Select None");
	setFont("SanSerif", width/10, "antialiased");
		setColor("red");0
	Overlay.drawString(""+string1+"", x, y);
	Overlay.show();
}
