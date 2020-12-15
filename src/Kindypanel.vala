/*
* Copyright 2019 Lafydev 
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not,
* see http :// www . gnu . org /licences / .
*/

using Gtk;

//Function recursive copy finded on stackoverflow author nemequ ? 
//modified : add exist tests for files and dirs
public bool copy_recursive (GLib.File src, GLib.File dest, GLib.FileCopyFlags flags = GLib.FileCopyFlags.NONE, GLib.Cancellable? cancellable = null) throws GLib.Error {
GLib.FileType src_type = src.query_file_type (GLib.FileQueryInfoFlags.NONE, cancellable);

if ( src_type == GLib.FileType.DIRECTORY ) {
	if (!dest.query_exists ()) {
	dest.make_directory (cancellable); }
	
	src.copy_attributes (dest, flags, cancellable);

	string src_path = src.get_path ();
	string dest_path = dest.get_path ();
	GLib.FileEnumerator enumerator = src.enumerate_children (GLib.FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE, cancellable);
	for ( GLib.FileInfo? info = enumerator.next_file (cancellable) ; info != null ; info = enumerator.next_file (cancellable) ) {
	copy_recursive (
		GLib.File.new_for_path (GLib.Path.build_filename (src_path, info.get_name ())),
		GLib.File.new_for_path (GLib.Path.build_filename (dest_path, info.get_name ())),
		flags, cancellable);
		} //end for
	} else if ( src_type == GLib.FileType.REGULAR ) {
    if (!dest.query_exists ()) {
		src.copy (dest, flags, cancellable);}
    }

	return true;
}
 
public void set_cle(string schema, string cle, string valeur) {
	//access gsettings
	
	//verifie schema existe
	var settings_schema = SettingsSchemaSource.get_default ().lookup (schema, true);
    if (settings_schema != null) {
    if (settings_schema.has_key (cle)) {
        var settings = new GLib.Settings (schema);
        settings.set_string(cle,valeur);
		} 
	} else critical("no schema");
}

int main (string[] args){
	Gtk.init (ref args);
	
	int curline=0;	
	//Directories (to be modified)
	var ICONDIR="/usr/share/kindypanel/icons/"; 
	string home = Environment.get_home_dir(); // because ~ not accepted
	var PathPerso = File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/");
	var PathTheme= "/usr/share/themes/elementary/gtk-3.0/";
			
	//Window 
	var window = new Gtk.Window ();
	window.title = "Kindypanel";
	window.set_position (Gtk.WindowPosition.CENTER);
	window.set_default_size (350, 70);
	window.destroy.connect (Gtk.main_quit);
	window.border_width = 10; //inner margin
	
	//Grid 
	var mygrid = new Gtk.Grid();
	mygrid.set_row_spacing (10); //space between 2 lines
    mygrid.set_column_spacing (10);
	
	//Radio buttons (no more labels, just an icon)
	string[] name = {"elementary-bleu", "elementary-blanc", "elementary-noir","halloween","flocon"};
	RadioButton[] btn=new RadioButton[5];
	for (int i=1; i<=5; i++) {
			if (i == 1) {
				btn[i]=new RadioButton.from_widget (null);}
			else {
				btn[i]=new RadioButton.from_widget (btn[1]); }
			var imgbtn = new Gtk.Image.from_file(ICONDIR+"/"+name[i-1]+".png");
			btn[i].add(imgbtn);
			btn[i].tooltip_text=name[i-1];
			int nrow = (i -1) / 3 ;
			if (i==4) {curline = 0;}
            mygrid.attach(btn[i], nrow, curline++);
        }
    curline = 3;  
	//view image
	var lblimg = new Gtk.Label (_("Your choice:"));
	mygrid.attach(lblimg, 2, 0,1,curline);//label at the top right
	var ico=ICONDIR+ "elementary-bleu.png"; //défault
	var img = new Gtk.Image.from_file(ICONDIR+"/elementary-bleu.png");

	mygrid.attach(img, 2, 1,1,curline++); //image at the top right
	var btnopen = new Gtk.Button.with_label(_("Other PNG (24*24px) ..."));
	
	mygrid.attach(btnopen, 0, curline++,2,1);
		
	//signaux 
	btn[1].clicked.connect( ()=> {  
		ico=ICONDIR+"/elementary-bleu.png" ;
		img.set_from_file(ico);});
	btn[2].clicked.connect( ()=> { 
		ico=ICONDIR+"elementary-blanc.png";
		img.set_from_file( ico); });
	btn[3].clicked.connect( ()=> {
		ico=ICONDIR+"elementary-noir.png";
		img.set_from_file( ico);});
	btn[4].clicked.connect( ()=> {
		ico=ICONDIR+"halloween.png";
		img.set_from_file( ico);});
	btn[5].clicked.connect( ()=> {
		ico=ICONDIR+"flocon.png";
		img.set_from_file( ico);});
	
	btnopen.clicked.connect( ()=> {
		var dialogue=new Gtk.FileChooserDialog( _("Open..."),window, Gtk.FileChooserAction.OPEN,
		_("_Cancel"),Gtk.ResponseType.CANCEL,
		_("_Open"),Gtk.ResponseType.ACCEPT);
		Gtk.FileFilter filter =new Gtk.FileFilter();
		filter.set_name("Icon (*.png)");
		filter.add_pattern( "*.[Pp][Nn][Gg]");
		dialogue.add_filter(filter);

		if (dialogue.run()==Gtk.ResponseType.ACCEPT) 
			{
			ico=dialogue.get_filename();
			File newicon = File.new_for_path(ico);
			try {
				string file_content_type = newicon.query_info ("*", FileQueryInfoFlags.NONE).get_content_type();
				//Verify size and type
				var file_info = newicon.query_info ("*", FileQueryInfoFlags.NONE);
				var file_size= file_info.get_size();
				//size 2,5Ko max
				if ((file_size <= 2500) && (file_content_type =="image/png")) 
				 { img.set_from_file( ico); }
				 else
				{
				var messagedialog = new Gtk.MessageDialog (window,
								Gtk.DialogFlags.MODAL,
								Gtk.MessageType.INFO,
								Gtk.ButtonsType.OK,
								_("Waiting for an image 2.5 Ko Max"));

					messagedialog.run ();
					messagedialog.destroy();}
					
			} catch (Error e) {
				stdout.printf("Error %s\n",e.message);
			}
				
			}
		dialogue.destroy();
		

	});		
	var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
	mygrid.attach(separator, 0,curline++,2);
		
	//check : keeping the word Application
	var btnApp = new Gtk.CheckButton.with_label(_("Keep the label Application"));
	mygrid.attach(btnApp, 0,curline++,2);
	
	//check : Transparent panel  
	var btnTransparent = new Gtk.CheckButton.with_label(_("Transparent Panel"));
	mygrid.attach(btnTransparent, 0,curline++,2);

	//Validation 
	var btncreate = new Gtk.Button.with_label (_("Create your theme!"));
	mygrid.attach( btncreate,0,curline++,2);
	
	//2 Buttons : Apply your theme or return
	var btnappliquer = new Gtk.Button.with_label (_("Apply your theme"));
	var btnretour = new Gtk.Button.with_label (_("Prefer elementary's theme"));
	
	bool erreur=false;
	bool boutonvisible=false;
	
	btncreate.clicked.connect( ()=> { 
		try {
			//create a directory in home (if not exists) 
			if (!PathPerso.query_exists ()) {
				PathPerso.make_directory_with_parents ();}
				
			//recursive copy 
			var DirTheme = File.new_for_path (PathTheme) ;
			
			copy_recursive(DirTheme,PathPerso,FileCopyFlags.NONE);
			//Copy recursive...done
	
			//Copy file apps.css from elementary before tweaks
			var fichstyle=File.new_for_path (PathTheme+ "/apps.css");
			
			//var perso =  File.new_for_path (PathPerso+"/apps.css");
			var perso =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/apps.css");
			
			//Copy apps.css in home (does it exists or not) 
			fichstyle.copy (perso, FileCopyFlags.OVERWRITE);	
			//Copy apps.css... done
			
		    string[] lig= new string[1];
		    
		    lig[0]= "/**** KINDYPANEL - ADD AN ELEMENTARY ICON  */";
			lig+= ".panel{";
			lig+="background: url(\"elementaryicon.png\") no-repeat 4px; ";
			lig+="}";
			
			lig+="/* NO magnifier - pas de loupe*/";
			lig+=".panel menubar:first-child .composited-indicator > revealer image{";
			lig+="margin-left:-30px;";
			lig+="}";
			
			//Dans tous les cas sinon flèche des applis mal positionnée
			lig+="/* MOVE APPLICATION*/";
			lig+=".panel menubar:first-child .composited-indicator > revealer label{";
			lig+="margin-left:20px;";
			lig+="}";
			
			if (! btnApp.active)  {
				lig+="/* Minimize APPLICATION*/";
				lig+=".panel menubar:first-child {";
				lig+="font-size:0px;";
				lig+="}";
			
			}	
			
			if (btnTransparent.active ) {
				lig+="/* Panel Transparent */";;
				lig+=".panel.maximized {";
				lig+="background-color: transparent ;";
				lig+="}";	
			}
			
		    //Open the file and add new lines 
			FileOutputStream os = perso.append_to (FileCreateFlags.NONE);
			//stdout.printf("nb lignes=%d",lig.length);
			for (int i=0;i<=lig.length-1;i++) {
				os.write ((lig[i]+"\n").data);
			}	
			//close the file
			os.close();
			
		    //Copy choosen icon
		    var modeleico=File.new_for_path (ico);
		    var copie =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/elementaryicon.png");
			modeleico.copy (copie, FileCopyFlags.OVERWRITE );	
			
		  } catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
			erreur=true;
		}
		
		
		if (erreur==false) {
			//final message
			var msg = _("Succeed!!! You can now test your theme\n");
			
			var messagedialog = new Gtk.MessageDialog (window,
								Gtk.DialogFlags.MODAL,
								Gtk.MessageType.INFO,
								Gtk.ButtonsType.OK,
								msg);

			messagedialog.run ();
			messagedialog.destroy();
			
			if (boutonvisible==false) {
			//Show 2 buttons :apply and return 
			mygrid.attach( btnappliquer,0,curline);
			mygrid.attach( btnretour,1,curline++);
			mygrid.show_all();
			string[] cde= new string[3];
			
			btnappliquer.clicked.connect( ()=> { 
				cde[1]= "gsettings set org.gnome.desktop.interface gtk-theme \"kindypanel\"";
				cde[2]= "gsettings set org.gnome.desktop.wm.preferences theme \"kindypanel\"";
				
				cde[3]= "killall wingpanel";
			
				try {
					for (int i=1;i<=3;i++) {
					Process.spawn_command_line_sync(cde[i]);
					}
				} catch (SpawnError e) {
					stdout.printf ("Error: %s\n", e.message);
					}
				});
				
			btnretour.clicked.connect( ()=> { 
				cde[1]= "gsettings set org.gnome.desktop.interface gtk-theme \"elementary\"";
				cde[2]= "gsettings set org.gnome.desktop.wm.preferences theme \"elementary\"";
				
				try {for (int i=1;i<=2;i++) {
					Process.spawn_command_line_sync(cde[i]);
					}
				} catch (SpawnError e) {
					stdout.printf ("Error: %s\n", e.message);
					}
				});
			boutonvisible=true;
			} //End create 2 buttons
			
		} //End  false= no error in generate theme 
		
		});//end btncreate clic
	

	window.add (mygrid);
	window.show_all ();

	Gtk.main();
	return 0;
}
