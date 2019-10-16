project('com.github.Lafydev.Kindypanel', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gio-2.0'),
]

sources = files('src/Kindypanel.vala')

mes_icons = ['elementary-blanc', 'elementary-noir', 'elementary-bleu']

foreach m : mes_icons
    install_data(
        join_paths('data/icons', m + '.png'),
        install_dir: join_paths(get_option('datadir'), 'Kindypanel', 'icons')
    )
endforeach

#installation de l'exe dans usr/bin
executable(meson.project_name(), 
	sources, 
	dependencies: dependencies, 
	install: true)

#installation du .desktop vers le menu usr/share/applications
install_data( 
	join_paths('data',meson.project_name()+'.desktop'),
	install_dir: join_paths(get_option('datadir'),'applications')
)
#installation du xml pour appcenter
install_data(
	join_paths('data',meson.project_name()+'.appdata.xml'),
	install_dir: join_paths(get_option('datadir'),'metainfo')
)
