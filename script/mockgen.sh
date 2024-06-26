#!/usr/bin/env bash

# mockgen will generates mock interface
# for your changes from master branch into mock directory
# Example :
#   /pkg/order.go
#
#   your mock will generated to
#
#   /mocks/mock_pkg/order_mock.go
#
# Mock usage refer to https://github.com/golang/mock

# Get current branch name
curBranch=$(git rev-parse --abbrev-ref HEAD)

# Install mockgen (if it hasn't been installed yet)
mockgen_version=$($(go env GOPATH)/bin/mockgen -version)
if [[ ${mockgen_version} == "" ]]; then
    go get -u github.com/golang/mock/...
    go install github.com/golang/mock/mockgen
fi

# Get changed files
files=$(find .)

for file in $files;
do
    if [[ ${file} == *".go" ]]; then
        dir=$(dirname "${file}")
        filename=$(basename "${file}")
        base="${filename%.*}"
        dest="${dir}/mock/mock_${base}.go"

        if [[ ! -f ${file} && -f ${dest} ]]; then
            rm ${dest}
            git add ${dest}
            continue
        fi

        if [[ -f ${file} && $(cat ${file} | grep -i ".* interface {" | wc -l) -ne 0 ]]; then
            $(go env GOPATH)/bin/mockgen -source=${file} -destination=${dest}
            git add ${dest}
            echo -e "${dest} is generated"
        fi
    fi
done
