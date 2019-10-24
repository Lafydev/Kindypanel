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
//Pour compiler après _() 
//insérer -X -DGETTEXT_PACKAGE="..."  directives de compil
//const string GETTEXT_PACKAGE = "...";

//Fonction de copie de rép récursive trouvée sur stackoverflow 
//modifiée pour ajouter les tests d'existence des fichiers et dossiers	
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
		} //fin for
	} else if ( src_type == GLib.FileType.REGULAR ) {
    if (!dest.query_exists ()) {
		src.copy (dest, flags, cancellable);}
    }

	return true;
}
 
int main (string[] args){
	Gtk.init (ref args);
		
	//Repertoires (A améliorer)
	var ICONDIR="/usr/share/kindypanel/icons/"; 
	string home = Environment.get_home_dir(); // car ~ refusé
	var PathPerso = File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/");
	var PathTheme= "/usr/share/themes/elementary/gtk-3.0/";
			
	//Fenetre de base
	var window = new Gtk.Window ();
	window.title = "Kindypanel";
	window.set_position (Gtk.WindowPosition.CENTER);
	window.set_default_size (350, 70);
	window.destroy.connect (Gtk.main_quit);
	window.border_width = 10; //marge intérieure
	
	//Grid 
	var mygrid = new Gtk.Grid();
	mygrid.set_row_spacing (10); //espace entre 2 lignes
    mygrid.set_column_spacing (10);
	
	//Radio buttons
	var  btn1 = new RadioButton.with_label_from_widget(null,_("Blue"));
	mygrid.attach(btn1, 0, 0);

	var btn2 = new Gtk.RadioButton.with_label_from_widget(btn1,_("White"));
	mygrid.attach(btn2, 0, 1);
      
	var btn3 = new Gtk.RadioButton.with_label_from_widget(btn1,_("Black"));
	mygrid.attach(btn3, 0, 2);
	  
	var btnopen = new Gtk.Button.with_label(_("Other PNG (24*24px) ..."));
	mygrid.attach(btnopen, 0, 3,2,1);
	 
	//affiche l'image choisie
	var ico=ICONDIR+ "elementary-bleu.png"; //par défaut
	var img = new Gtk.Image.from_file(ICONDIR+"/elementary-bleu.png");

	mygrid.attach(img, 1, 0,1,3);
		
	//signaux 
	btn1.clicked.connect( ()=> { 
		ico=ICONDIR+"/elementary-bleu.png" ;
		img.set_from_file(ico);});
	btn2.clicked.connect( ()=> { 
		ico=ICONDIR+"elementary-blanc.png";
		img.set_from_file( ico); });
	btn3.clicked.connect( ()=> {
		ico=ICONDIR+"elementary-noir.png";
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
				if (file_content_type =="image/png") { img.set_from_file( ico); }
			} catch (Error e) {
				stdout.printf("Error %s\n",e.message);
			}
				
			}
		dialogue.destroy();
		

	});		
	var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
	mygrid.attach(separator, 0,4,2);
		
	//Ajoute une case à cocher pour garder Application
	var btnApp = new Gtk.CheckButton.with_label(_("Keep the label Application"));
	mygrid.attach(btnApp, 0, 5,2);
	
	//Ajoute une case à cocher pour panel Transparent 
	var btnTransparent = new Gtk.CheckButton.with_label(_("Transparent Panel"));
	mygrid.attach(btnTransparent, 0,6,2);

	//Ajoute un bouton de validation
	var btn = new Gtk.Button.with_label (_("Create your theme!"));
	mygrid.attach( btn,0,7,2);
	
	//Deux boutons prévus pour appliquer le theme
	var btnappliquer = new Gtk.Button.with_label (_("Apply your theme"));
	var btnretour = new Gtk.Button.with_label (_("Return to elementary"));
	
	bool erreur=false;
	bool boutonvisible=false;
	
	btn.clicked.connect( ()=> { 
		try {
			//créer un repertoire dans home si pas déjà 
			if (!PathPerso.query_exists ()) {
				PathPerso.make_directory_with_parents ();}
				
			//copier récursivement les répertoire
			var DirTheme = File.new_for_path (PathTheme) ;
			
			copy_recursive(DirTheme,PathPerso,FileCopyFlags.NONE);
			//stdout.printf("Copie recursive des répertoires terminée");
	
			//Copier le fichier apps.css de elementary pour personnaliser
			var fichstyle=File.new_for_path (PathTheme+ "/apps.css");
			
			//var perso =  File.new_for_path (PathPerso+"/apps.css");
			var perso =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/apps.css");
			
			//Force la copie  de apps.css vers home perso même si déjà 
			fichstyle.copy (perso, FileCopyFlags.OVERWRITE);	
			//stdout.printf("Copie apps terminée\n");
			
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
			
		    //Ouvrir le fichier et ajouter modifs 
			FileOutputStream os = perso.append_to (FileCreateFlags.NONE);
			//stdout.printf("nb lignes=%d",lig.length);
			for (int i=0;i<=lig.length-1;i++) {
				os.write ((lig[i]+"\n").data);
			}	
			
		    //copier l'icone choisi 
		    var modeleico=File.new_for_path (ico);
		    var copie =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/elementaryicon.png");
			modeleico.copy (copie, FileCopyFlags.OVERWRITE );	
				
	  
		  } catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
			erreur=true;
		}
		
		
		if (erreur==false) {
			//message final
			var msg = _("Succeed!!! You can now test your theme\n");
			
			var messagedialog = new Gtk.MessageDialog (window,
								Gtk.DialogFlags.MODAL,
								Gtk.MessageType.INFO,
								Gtk.ButtonsType.OK,
								msg);

			messagedialog.run ();
			messagedialog.destroy();
			
			if (boutonvisible==false) {
			//Montre les boutons appliquer et retour
			mygrid.attach( btnappliquer,0,8);
			mygrid.attach( btnretour,1,8);
			mygrid.show_all();
			string[] cde= new string[3];
			
			btnappliquer.clicked.connect( ()=> { 
				cde[1]= "gsettings set org.gnome.desktop.interface gtk-theme \"kindypanel\"";
				//uniquement pour WM
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
			} //fin creation 2 boutons supplémentaires
			
		} //fin erreur générer theme = False
		
		});//fin click btn
	

	window.add (mygrid);
	window.show_all ();

	Gtk.main();
	return 0;
}
