project('com.github.Lafydev.Kindypanel', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gio-2.0'),
]

sources = files('src/Kindypanel.vala')

executable(meson.project_name(), sources, dependencies: dependencies, install: true)

#installation du .desktop vers le menu applications
install_data( 
	join_paths('data',meson.project_name()+'.desktop'),
	install_dir: join_paths(get_option('datadir'),'applications')
)
#installation du xml pour appcenter
install_data(
	join_paths('data',meson.project_name()+'.appdata.xml'),
	install_dir: join_paths(get_option('datadir'),'metainfo')
)
