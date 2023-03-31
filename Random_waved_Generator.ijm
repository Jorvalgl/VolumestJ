//Random waved generator Macro
/* 
    Random_waved_Generator is an ImageJ macro developed to generate a random waved 3D object,
    Copyright (C) 2020 Jorge Valero Gómez-Lobo
     Random_waved_Generator is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    Random_waved_Generator is distributed in the hope that it will be useful,
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
Dialog.addMessage("Random_waved_Generator Copyright (C) 2020 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("Random_waved_Generator comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();
setBatchMode("hide");
roiManager("Select", 0);
roiManager("Add");
for(i=100; i<200; i++){
	roiManager("Select", 0);
	run("Enlarge...", "enlarge="+(-20*random)+(random*20));
	roiManager("Update");
	setSlice(i);
	fill();
}
for(i=100; i>0; i--){
	roiManager("Select", 1);
	run("Enlarge...", "enlarge="+(random*-20)+(random*20));
	roiManager("Update");
	setSlice(i);
	fill();
}
run("Select None");
run("Gaussian Blur 3D...", "x=2 y=2 z=10");
selectWindow("Untitled");
setAutoThreshold("Default dark");
setThreshold(1, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Invert LUT");
setBatchMode("exit and display");
