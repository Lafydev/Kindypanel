project('com.github.lafydev.kindypanel', 'vala', 'c')

#include the translations module
i18n=import('i18n')

#set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),language:'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('gio-2.0'),
]

sources = files('src/Kindypanel.vala')

mes_icons = ['elementary-blanc', 'elementary-noir', 'elementary-bleu', 'halloween','flocon']

foreach m : mes_icons
    install_data(
        join_paths('data/icons', m + '.png'),
        install_dir: join_paths(get_option('datadir'), 'kindypanel', 'icons')
    )
endforeach

install_data(
        join_paths('data/icons', meson.project_name() +'.png'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor','48x48','apps')
    )

#installation de l'exe dans usr/bin
executable(meson.project_name(), 
	sources, 
	dependencies: dependencies, 
	install: true)

#translate and install our.desktop (vers le menu usr/share/applications)
i18n.merge_file(
	input:join_paths('data',meson.project_name() + '.desktop.in'),
	output: meson.project_name() +'.desktop',
	po_dir: join_paths(meson.source_root(),'po'),
	type: 'desktop',
	install: true,
	install_dir: join_paths(get_option('datadir'),'applications')
	)
	
#translate and install our .xml (pour appcenter)
i18n.merge_file(
	input: join_paths('data',meson.project_name()+ '.appdata.xml.in'),
	output: meson.project_name()+ '.appdata.xml',
	po_dir: join_paths(meson.source_root(),'po'),
	install:true,
	install_dir: join_paths(get_option('datadir'),'metainfo')
)
subdir('po')
