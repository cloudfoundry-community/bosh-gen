set -e          # exit immediately if a simple command exits with a non-zero status
set -u          # report the usage of uninitialized variables
set -o pipefail # return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status

# Usage: src/common/fetch_debs.sh postgresql [src/apt/postgresql]
#
#   src/common/fetch_debs.sh postgresql
#   src/common/fetch_debs.sh postgresql src/apt/postgresql
#
PACKAGE_NAME=$1
RELEASE_DIR=${RELEASE_DIR:-/vagrant}
if [[ "${2:-X}" == "X" ]]; then
    PACKAGE_SRC_DIR=$RELEASE_DIR/src/apt/$PACKAGE_NAME
else
    PACKAGE_SRC_DIR=$RELEASE_DIR/$2
fi
APTFILE=$PACKAGE_SRC_DIR/aptfile
APT_CACHE_DIR="$RELEASE_DIR/tmp/apt/cache/$PACKAGE_NAME"
APT_STATE_DIR="$RELEASE_DIR/tmp/apt/state"
BLOBS_DIR=$RELEASE_DIR/blobs/apt/$PACKAGE_NAME

function error() {
  echo " !     $*" >&2
  exit 1
}

function topic() {
  echo "-----> $*"
}

function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

topic "Environment information"
echo $0                | indent
uname -a               | indent
pwd                    | indent

# Invoke apt-get to ensure it exists
if [[ "$(which apt-get)X" == "X" ]]; then
    error "Cannot find apt-get executable. Run this script within a Debian/Ubuntu environment."
fi
which apt-get          | indent

echo $APTFILE          | indent
if [[ ! -f $APTFILE ]]; then
    error "Missing source file $APTFILE"
fi

mkdir -p "$APT_CACHE_DIR/archives/partial"
mkdir -p "$APT_STATE_DIR/lists/partial"
mkdir -p $BLOBS_DIR

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=$APT_CACHE_DIR -o dir::state=$APT_STATE_DIR"

topic "Updating apt caches"
apt-get $APT_OPTIONS update | indent

for PACKAGE in $(cat $APTFILE); do
  topic "Fetching .debs for $PACKAGE"
  apt-get $APT_OPTIONS -y -d install $PACKAGE | indent
done

topic "Copying .debs to blobs"
cp -a $APT_CACHE_DIR/archives/*.deb $BLOBS_DIR/
