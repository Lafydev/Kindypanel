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
	//Fonction récusrsive trouvée sur stackoverflow 
	//modifiée pour ajouter des tests d'existence des fichiers et dossiers	
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
		}
	} else if ( src_type == GLib.FileType.REGULAR ) {
    if (!dest.query_exists ()) {
		src.copy (dest, flags, cancellable);}
  }

  return true;
}
	
int main (string[] args){
	Gtk.init (ref args);

	//Notre fenetre de base
	var window = new Gtk.Window ();
	window.title = "Choix multiples";
	window.set_position (Gtk.WindowPosition.CENTER);
	window.set_default_size (350, 70);
	window.destroy.connect (Gtk.main_quit);
	window.border_width = 10; //marge intérieure

	//Paned vertical
	var VBox = new Gtk.Box(Gtk.Orientation.VERTICAL,5);
	VBox.spacing=6;
	var ico="elementaryicon.png"; //par défaut

	//Radio buttons
	var  btn1 = new RadioButton.with_label_from_widget(null,"Bleu");
	VBox.pack_start(btn1, false, false,0);
	
	var btn2 = new Gtk.RadioButton.with_label_from_widget(btn1,"Blanc");
	VBox.pack_start(btn2, false, false,0);
      
	var btn3 = new Gtk.RadioButton.with_label_from_widget(btn1,"Noir");
	VBox.pack_start(btn3, false, false,0);
	
	//Case à cocher Garder Application
	var btnApp = new Gtk.CheckButton.with_label("Garder Application");
	VBox.pack_start(btnApp, false, false,0);
	  
	//affiche l'image choisie
	var img = new Gtk.Image.from_file("elementaryicon.png");
	VBox.pack_start(img, false, false,0);
	//signaux 
	btn1.clicked.connect( ()=> { 
		ico="elementaryicon.png" ;
		img.set_from_file(ico);});
	btn2.clicked.connect( ()=> { 
		ico="elementary-blanc.png";
		img.set_from_file( ico); });
	btn3.clicked.connect( ()=> {
		ico="elementary-noir.png";
		img.set_from_file( ico);});
		
      //Ajoute un bouton de validation
      var btn = new Gtk.Button.with_label ("Cliquer ici!");
      VBox.pack_start( btn,true,false,0);
	  btn.clicked.connect( ()=> { 
		try {
			//créer un repertoire dans home si pas déjà 
			string home = Environment.get_home_dir(); // ~ refusé
			var Dirperso = File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/");
			
			if (!Dirperso.query_exists ()) {
				Dirperso.make_directory_with_parents ();}
				
			//copier tous le répertoire
			var PathTheme= "/usr/share/themes/elementary/gtk-3.0/";
			var DirTheme = File.new_for_path (PathTheme) ;
			copy_recursive(DirTheme,Dirperso,FileCopyFlags.NONE);
			
	
			//Modifier le fichier apps.css de elementary 
			var fichstyle=File.new_for_path (PathTheme+ "/apps.css");
			var perso =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/apps.css");
			
			//Force la copie  de apps.css vers home perso même si déjà 
			/*stdout.printf ("Création d'une copie personnalisée de apps.css.\n");*/
			fichstyle.copy (perso, FileCopyFlags.OVERWRITE);	
			
			
			   
		    string[] lig= new string[14];
		    
		    lig[0]= "/**** ADD AN ICON ELEMENTARY */";
			lig[1]= ".panel{";
			lig[2]="background-image: url(\"elementaryicon.png\"); ";
			lig[3]="background-repeat: no-repeat;";
			lig[4]="}";
			lig[5]="/* NO magnifier*/";
			lig[6]=".panel menubar:first-child .composited-indicator > revealer image{";
			lig[7]="margin-left:-30px;";
			lig[8]="}";
			
			if (btnApp.active) {
				lig[9]="/* MOVE APPLICATION*/";
				lig[10]=".panel menubar:first-child .composited-indicator > revealer label{";
				lig[11]="margin-left:20px;";
				lig[12]="}";
			}
			else {
				lig[9]="/* Minimize APPLICATION*/";
				lig[10]=".panel menubar:first-child {";
				lig[11]="font-size:0px;";
				lig[12]="}";
			}
			
		    //Ouvrir le fichier et ajouter modifs 
			FileOutputStream os = perso.append_to (FileCreateFlags.NONE);
			for (int i=0;i<=12;i++) {
				os.write ((lig[i]+"\n").data);
			}	
			
		    //copier l'icone choisi 
		    var modeleico=File.new_for_path (ico);
		    var copie =  File.new_for_path (home +"/.themes/kindypanel/gtk-3.0/elementaryicon.png");
			modeleico.copy (copie, FileCopyFlags.OVERWRITE );	
				
	  
		  } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
        
		}
		Gtk.main_quit();
		
	});

      window.add (VBox);
      window.show_all ();

      Gtk.main();
      return 0;
}
