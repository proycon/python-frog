#!/bin/sh

# Builds dependencies (latest stable releases) from source
# Used for building wheels. Invoke via 'make wheels' rather
# than directly!

set -e

. /etc/os-release
echo "OS: $ID">&2
echo "VERSION: $VERSION_ID">&2

get_latest_version() {
    #Finds the latest git tag or falls back to returning the git default branch (usually master or main)
    #Assumes some kind of semantic versioning (possibly with a v prefix)
    TAG=$(git tag -l | grep -E "^v?[0-9]+(\.[0-9])*" | sort -t. -k 1.2,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 1)
    if [ -z "$TAG" ]; then
        echo "No releases found, falling back to default git branch!">&2
        #output the git default branch for the repository in the current working dir (usually master or main)
        git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
    else
        echo "$TAG"
    fi
}

[ -z "$PREFIX" ] && PREFIX="/usr/local/"
if [ "$ID" = "almalinux" ] || [ "$ID" = "centos" ] || [ "$ID" = "rhel" ]; then
    if [ -d /usr/local/share/aclocal ]; then
        #needed for manylinux_2_28 container which ships custom autoconf, possibly others too?
        export ACLOCAL_PATH=/usr/share/aclocal
    fi
    case $VERSION_ID in
        7*)
            yum install -y libexttextcat-devel
            if [ -d /opt/rh/devtoolset-10/root/usr/lib ]; then
                #we are running in the manylinux2014 image
                export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/opt/rh/devtoolset-10/root/usr/lib
                #libxml2 is out of date, compile and install a new one
                yum install -y xz
                wget https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz
                unxz libxml2-2.9.14.tar.xz
                tar -xf libxml2-2.9.14.tar
                cd libxml2-2.9.14 && ./configure --prefix=$PREFIX --without-python && make && make install
                cd ..
            fi
            ;;
        8*)
            #they forgot to package libexttextcat-devel? grab one manually:
            wget https://github.com/proycon/LaMachine/raw/master/deps/centos8/libexttextcat-devel-3.4.5-2.el8.x86_64.rpm
            yum install -y libexttextcat-devel-3.4.5-2.el8.x86_64.rpm
            ;;
    esac
fi

PWD="$(pwd)"
BUILDDIR="$(mktemp -dt "build-deps.XXXXXX")"
cd "$BUILDDIR"
for PACKAGE in LanguageMachines/ticcutils LanguageMachines/libfolia LanguageMachines/uctodata LanguageMachines/ucto LanguageMachines/timbl LanguageMachines/mbt LanguageMachines/frogdata LanguageMachines/frog; do
    echo "Git cloning $PACKAGE ">&2
    git clone https://github.com/$PACKAGE
    PACKAGE="$(basename $PACKAGE)"
    cd "$PACKAGE"
    if [ "$1" != "--devel" ]; then
        VERSION="$(get_latest_version)"
        if [ "$VERSION" != "master" ] && [ "$VERSION" != "main" ] && [ "$VERSION" != "devel" ]; then
            echo "Checking out latest stable version: $VERSION">&2
            git -c advice.detachedHead=false checkout "$VERSION"
        fi
    fi
    echo "Bootstrapping $PACKAGE ">&2
    if [ ! -f configure ] && [ -f configure.ac ]; then
        #shellcheck disable=SC2086
        autoreconf --install --verbose
    fi
    echo "Configuring $PACKAGE" >&2
    ./configure --prefix="$PREFIX" >&2
    echo "Make $PACKAGE" >&2
    make
    echo "Make install $PACKAGE" >&2
    make install
    cd ..
done
cd $PWD
[ -n "$BUILDDIR" ] && rm -Rf "$BUILDDIR"
echo "Dependencies installed" >&2
