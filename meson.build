project('libvorbis', 'c', version: '1.3.7')

compiler = meson.get_compiler('c')
link_deps = [
    dependency('ogg')
]

incdirs = ['include', 'include/vorbis']

vorbis_sources = [
    'lib/mdct.c',
    'lib/smallft.c',
    'lib/block.c',
    'lib/envelope.c',
    'lib/window.c',
    'lib/lsp.c',
    'lib/lpc.c',
    'lib/analysis.c',
    'lib/synthesis.c',
    'lib/psy.c',
    'lib/info.c',
    'lib/floor1.c',
    'lib/floor0.c',
    'lib/res0.c',
    'lib/mapping0.c',
    'lib/registry.c',
    'lib/codebook.c',
    'lib/sharedbook.c',
    'lib/lookup.c',
    'lib/bitrate.c',
]

vorbisfile_sources = [
    'lib/vorbisfile.c'
]

c_flags = []

if target_machine.system() == 'linux'
    c_flags += [
        '-DHAVE_ALLOCA_H'
    ]
endif

incdirs = include_directories(incdirs)

libvorbis = static_library(
    'vorbis',
    vorbis_sources,
    include_directories: incdirs,
    dependencies: link_deps,
    c_args: c_flags,
)
libvorbisfile = static_library(
    'vorbisfile',
    vorbisfile_sources,
    include_directories: incdirs,
    dependencies: link_deps,
    c_args: c_flags,
)

libvorbis_dep = declare_dependency(
    include_directories: incdirs,
    dependencies: link_deps,
    link_with: libvorbis,
    version: meson.project_version()
)
libvorbisfile_dep = declare_dependency(
    include_directories: incdirs,
    dependencies: link_deps,
    link_with: libvorbisfile,
    version: meson.project_version()
)

meson.override_dependency('vorbis', libvorbis_dep)
meson.override_dependency('vorbisfile', libvorbisfile_dep)

# vim: set ts=4 sts=4 sw=4 et:
