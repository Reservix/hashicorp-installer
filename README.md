# hashicorp-installer
A short POSIX compliant shell script to install hashicorp packages

## Install Requirements
You need to have following tools in place:
* awk
* jq
* curl
* unzip

Awk, Curl and Unzip should be already installed on MacOS and Debian/Ubuntu.

### Debian / Ubuntu
```sh
$ apt install jq
```

### MacOS
```sh
brew install jq
```

## Use Installer

```sh
$ ./hashicrop-installer.sh terraform

$ ./hashicrop-installer.sh packer
```
