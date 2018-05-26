#!/bin/sh

# variables
arch="amd64"
install_prefix="${HOME}/bin"

# version lower
ver_lt() {
	test "${1}" = "$(printf "%s\\n%s" "${1}" "${2}" \
		| sort -V \
		| head -n1)"
}

# version equal
ver_eq() {
	test "${1}" = "${2}" \
		&& return 1

	ver_lt "${1}" "${2}"
}

# check for jq
command -v jq > /dev/null 2>&1 \
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
package="${1}"

# get version list
package_version_list=$(curl -s https://releases.hashicorp.com/index.json \
	| jq "{${package}}" \
	| grep -E "linux.*${arch}") \
	|| {
		echo "There is no package \"${package}\""
		exit 1
	}

# get latest version
package_version=$(echo "${package_version_list}" \
	| grep -E filename \
	| awk -F'"' '{print $4}' \
	| cut -d'_' -f2 \
	| sort --version-sort -r \
	| head -1)

# get package url of latest version
package_url=$(echo "${package_version_list}" \
	| grep -E "url.*${package_version}" \
	| awk -F'"' '{print $4}')

# check version difference
command -v "${package}" > /dev/null 2>&1 \
	&& {
		package_version_installed=$("${package}" --version \
			| head -n 1 \
			| cut -d' ' -f2 \
			| sed "s/v//")

		ver_eq "${package_version_installed}" "${package_version}" \
			|| {
				echo "No update available. Latest version is ${package}-${package_version}"
				exit 0
			}
	}


# set install path
package_install_path="${install_prefix}/${package}-${package_version}"

# Create and change into directory
mkdir -p "${package_install_path}" \
	|| {
		echo "Failed to create ${package_install_path}"
		exit 1
	}

# download and unzip package
curl -s -o "${package}.zip" "${package_url}"
unzip -q "${package}.zip" -d "${package_install_path}"

# set symlink
ln -snf "${package_install_path}/${package}" "${HOME}/bin/${package}"

# exit gracefully
echo "Successfully installed ${package}-${package_version}"
exit 0
