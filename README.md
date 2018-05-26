# hashicorp-installer
A short POSIX compliant shell script to install hashicorp packages

## Install Requirements
You need to have following tools in place:
* jq
* curl
* unzip

Curl and unzip should be already installed on MacOS and Debian/Ubuntu.

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
