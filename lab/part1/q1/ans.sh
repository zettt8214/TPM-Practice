#!/bin/sh
echo "Before extend:"
tpm2_pcrread sha256:10
SHA256DATA=`sha256sum dummy.txt | awk '{print $1}'`
echo $SHA256DATA
tpm2_pcrextend 10:sha256=$SHA256DATA
echo "After extend":
tpm2_pcrread sha256:10