//Symmetric object generator Macro
/* 
    Symmetric_Object_Generator is an ImageJ macro developed to generate symmetric 3D objects,
    Copyright (C) 2020 Jorge Valero Gómez-Lobo
     Symmetric_Object_Generator is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    Symmetric_Object_Generator is distributed in the hope that it will be useful,
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
Dialog.addMessage("Symmetric_Object_Generator Copyright (C) 2020 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("Symmetric_Object_Generator comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();
roiManager("Select", 0);
roiManager("Add");
for(i=100; i<200; i++){
	roiManager("Select", 0);
	getStatistics(area, mean, min, max, std, histogram);
	run("Enlarge...", "enlarge=-1");
	roiManager("Update");
	getStatistics(area2, mean, min, max, std, histogram);
	if (area==area2) i=200;
	else{
		setSlice(i);
		fill();	
	}
}
for(i=100; i>0; i--){
	roiManager("Select", 1);
	getStatistics(area, mean, min, max, std, histogram);
	run("Enlarge...", "enlarge=-1");
	roiManager("Update");
	getStatistics(area2, mean, min, max, std, histogram);
	if (area==area2) i=0;
	else{
		setSlice(i);
		fill();	
	}
}
