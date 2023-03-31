//Sphere Generator Macro
/* 
    Sphere_Generator is an ImageJ macro developed to generate spheres,
    Copyright (C) 2020 Jorge Valero Gómez-Lobo
     Sphere_Generator is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    Sphere Generator is distributed in the hope that it will be useful,
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
Dialog.addMessage("Sphere_Generator Copyright (C) 2020 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage("Sphere_Generator comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();
planes=100;
for (i=1; i<=planes/2; i++){
	setSlice(i);
	d=2*(sqrt(i*(planes-i)));
	print(d);
	run("Specify...", "width="+d+" height="+d+" x=100 y=100 slice=1 oval centered");
	setSlice(i);
	run("Fill", "slice");
}
s=(planes/2);
for (i=planes/2; i>0; i--){
	s++;
	setSlice(s);
	d=2*(sqrt(i*(planes-i)));
	print(d);
	run("Specify...", "width="+d+" height="+d+" x=100 y=100 slice=1 oval centered");
	setSlice(s);
	run("Fill", "slice");
}