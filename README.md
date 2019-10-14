# Kindypanel
Modify elementary's original theme : add an elementary icon<br/>
Choose to remove or only move near the Application's label<br/> 

This application is in French, translate coming soon

Manual install 
build with meson (sudo apt install meson)

Download the last release (zip) et extract files
Open a Terminal in the extracted folder, install your application with meson:

meson build --prefix=/usr
cd build
ninja
sudo ninja install

Uninstall (need the extracted files)
In the same extracted folder run the commands :
sudo ninja uninstall

