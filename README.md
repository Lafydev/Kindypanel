# Kindypanel

[Lire en français](https://github.com/Lafydev/Kindypanel/blob/master/LISEZMOI.md) 

# Description

Create your personalized panel based on elementary's wingpanel : 

- Add an icon at the top left of the screen
- Choose an elementary icon or upload your own image (PNG)
- Choose to remove or keep the Application's label
- Choose if you want a transparent panel

<img title="screenshot" src="screenshot_en.png" alt="screenshot" data-align="center">

Thanks to Angedestenebres and Wolfwarrior for their crash-tests  

# Easy install (user)

Download only the .deb file and run it with your installer  or 

`sudo dpkg -i com.github.lafydev.kindypanel_0.1ubuntu5_amd64.deb`

<img src="screenshot.png"/>

# Build and install (developer)

Download the last release (zip) et extract files

## Dependencies

These dependencies are needed for building : 

`sudo apt-get install gcc valac gtk+-3.0 meson`

## Build with meson

Open a Terminal in the extracted folder, build your application with meson and install it with ninja:

`meson build --prefix=/usr
cd build
ninja
sudo ninja install`

## Uninstall (need the extracted files)
In the previous folder ( /build) run the command :

`sudo ninja uninstall`
