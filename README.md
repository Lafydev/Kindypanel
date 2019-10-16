# Kindypanel
Modify elementary's original theme : add an elementary icon<br/>
Choose to remove or only move near the Application's label<br/> 

This application is in French, translate coming soon

<h1>Manual install </h1>
build with meson (sudo apt install meson)<br/>

Download the last release (zip) et extract files<br/>
Open a Terminal in the extracted folder, install your application with meson:<br/>

meson build --prefix=/usr<br/>
cd build<br/>
ninja<br/>
sudo ninja install<br/>

<h1>Uninstall (need the extracted files)</h1>
In the same extracted folder run the commands :<br/>
sudo ninja uninstall

