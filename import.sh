#!/bin/bash

hostname="$(hostname -i)"
tar_file=$1
bkp_name="bkp-$$"

if [ -z "${tar_file}" ]; then
    echo "Usage import.sh [tar file]"
    exit 1
fi

keyspace=$(basename "${tar_file}" ".tar.gz")

mkdir -p "${bkp_name}"

tar -xvzf "${tar_file}" -C "${bkp_name}"

echo "Drop keyspace ${keyspace}"
cqlsh "${hostname}" -e "drop keyspace \"${keyspace}\";"

echo "Create empty keyspace: ${keyspace}"
cat "${bkp_name}/${keyspace}.sql" | cqlsh "${hostname}"

for dir in "${bkp_name}/${keyspace}/"*; do
    sstableloader -d "${hostname}" "${dir}"
done
