# Kindypanel
<h1>Description:</h1>
<ul>
Create an personnal theme based on elementary's original wingpanel : <br>
<li>Add an elementary icon at top left of the screen</li>
<li>Choose to remove or keep the Application's label</li> 
<li>Choose if you want a transparent panel</li>
</ul>

This application is in French, translations are coming soon
Thanks to Angedestenebres and Wolfy for their crash-tests 

<h1>Manual install </h1>

<h2>Dependencies</h2>
gcc valac gtk3 meson <br/><br/>

Build with meson:<br/>

Download the last release (zip) et extract files<br/>
Open a Terminal in the extracted folder, install your application with meson:<br/>

<code>meson build --prefix=/usr<br/>
cd build<br/>
ninja<br/>
sudo ninja install<br/>
</code>

<h1>Uninstall (need the extracted files)</h1>
In the previous folder ( /build) run the command :<br/>
<code>sudo ninja uninstall</code>

