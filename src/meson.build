desktop_files_creator_sources = [
  'main.vala',
  'window.vala',
]

desktop_files_creator_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-1', version: '>= 1.0.0'),
]

desktop_files_creator_sources += gnome.compile_resources('desktop_files_creator-resources',
  'desktop_files_creator.gresource.xml',
  c_name: 'desktop_files_creator'
)

executable('desktop-files-creator', desktop_files_creator_sources,
  include_directories: config_h_dir,
  vala_args: ['--target-glib=2.50', meson.project_source_root() + '/src/config.vapi'],
  c_args: ['-include', 'config.h'],
  dependencies: desktop_files_creator_deps,
  install: true,
)
