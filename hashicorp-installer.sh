#!/bin/sh

# variables
arch="amd64"
install_prefix="${HOME}/bin"

# version lower
ver_lt() {
	test "${1}" = "$(echo -e "${1}\n${2}" \
		| sort -V \
		| head -n1)"
}

# version equal
ver_eq() {
	test "${1}" = "${2}" \
		&& return 1 \
		|| ver_lt "${1}" "${2}"
}

# check for jq
which jq 2>&1 > /dev/null \
	|| {
		echo "Please install jq!"
		exit 1
	}

# check parameter
test "${#}" -eq 0  \
	&& {
		echo "You need to specify a hashicorp package!"
		exit 1
	}

# get parameter
PACKAGE="${1}"

# get version list
package_version_list=$(curl -s https://releases.hashicorp.com/index.json \
	| jq "{${PACKAGE}}" \
	| egrep "linux.*${arch}") \
	|| {
		echo "There is no package \"${PACKAGE}\""
		exit 1
	}

# get latest version
package_version=$(echo "${package_version_list}" \
	| egrep filename \
	| awk -F'"' '{print $4}' \
	| cut -d'_' -f2 \
	| sort --version-sort -r \
	| head -1)

# get package url of latest version
package_url=$(echo "${package_version_list}" \
	| egrep "url.*${package_version}" \
	| awk -F'"' '{print $4}')

# check version difference
which "${PACKAGE}" 2>&1 > /dev/null \
	&& {
		installed_package_version=$("${PACKAGE}" --version \
			| head -n 1 \
			| cut -d' ' -f2 \
			| sed "s/v//")

		ver_eq "${installed_package_version}" "${package_version}" \
			|| {
				echo "No update available. Latest version is ${PACKAGE}-${package_version}"
				exit 0
			}
	}


# set install path
package_install_path="${install_prefix}/${PACKAGE}-${package_version}/"

# Create and change into directory
mkdir -p "${package_install_path}" \
	|| {
		echo "Failed to create ${package_install_path}"
		exit 1
	}

# download and unzip package
curl -s -o "${PACKAGE}.zip" "${package_url}"
unzip -q "${PACKAGE}.zip" -d "${package_install_path}"

# set symlink
ln -snf "${package_install_path}/${PACKAGE}" "${HOME}/bin/${PACKAGE}"

# exit gracefully
echo "Successfully installed ${PACKAGE}-${package_version}"
exit 0
