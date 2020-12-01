using BinaryBuilder

name = "ZeroMQ"
version = v"4.0.4"

# Collection of sources required to build ZMQ
sources = [
    ArchiveSource("https://archive.org/download/zeromq_$(version)/zeromq-$(version).tar.gz",
                  "1ef71d46e94f33e27dd5a1661ed626cd39be4d2d6967792a275040e34457d399"),
    DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/zeromq-*
# if [[ "${target}" == *-mingw* ]]; then
#     # Apply patch from
#     # https://github.com/msys2/MINGW-packages/blob/350ace4617661a4df7b9474c573b08325fa716c3/mingw-w64-zeromq/001-mingw-__except-fixes.patch
#     atomic_patch -p1 ../patches/001-mingw-__except-fixes.patch
# elif [[ "${target}" == *86*-linux-musl* ]]; then
#     pushd /opt/${target}/lib/gcc/${target}/*/include
#     # Fix bug in Musl C library, see
#     # https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/387
#     atomic_patch -p0 $WORKSPACE/srcdir/patches/mm_malloc.patch
#     popd
# fi
sh autogen.sh
update_configure_scripts

export LDFLAGS="-lstdc++"
./configure --prefix=$prefix \
    --host=${target} \
    --without-docs \
    --enable-drafts \
    --disable-libunwind \
    --disable-perf \
    --disable-Werror \
    --disable-eventfd \
    --without-gcov \
    --disable-curve-keygen \
    --enable-static \
    --disable-shared \
    --with-pic \
    CXXFLAGS="-O2 -fms-extensions"
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(supported_platforms())

# The products that we will ensure are always built
products = [
    FileProduct(["lib/libzmq.a", "bin/libzmq.lib"], :libzmq40),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)