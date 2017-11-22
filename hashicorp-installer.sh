#!/bin/bash

# version lower
ver_lt() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

# version equal
ver_eq() {
    [ "$1" = "$2" ] && return 1 || ver_lt $1 $2
}

# check for jq
which jq &> /dev/null || { echo "Please install jq!"; exit 1; }

# check parameter
PACKAGE="$1"
[ -z "$PACKAGE" ] && { echo "You need to specify a package!"; exit 1; }

# get url, installed version and latest version of $PACKAGE
package_url=$(curl https://releases.hashicorp.com/index.json | jq "{$PACKAGE}" | egrep "linux.*amd64" | sort --version-sort -r | head -1 | awk -F[\"] '{print $4}')
package_version=$(curl https://releases.hashicorp.com/index.json | jq "{$PACKAGE}" | egrep "linux.*amd64" | sort --version-sort -r | grep filename | head -1 | awk -F[\"] '{print $4}' | cut -d"_" -f2)
installed_package_version=$("$PACKAGE" --version | head -n 1 | cut -d' ' -f2 | sed "s/v//")

# check the version difference if we have it already
if which "$PACKAGE" &> /dev/null; then
  ver_eq "$installed_package_version" "$package_version" \
    || { echo "No update available."; exit; }
fi

# Create a move into directory.
mkdir -p ~/bin/"$PACKAGE-$package_version" && cd "$_" || { echo "Failed to create and enter ~/bin/$PACKAGE-$package_version"; exit 1; }

# download package
echo "Downloading $package_url."
curl -o "$PACKAGE.zip" "$package_url"

# unzip and install
unzip "$PACKAGE.zip"

# set symlink
ln -snf ~/bin/"$PACKAGE-$package_version/$PACKAGE" ~/bin/"$PACKAGE"
