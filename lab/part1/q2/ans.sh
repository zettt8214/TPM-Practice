#!/bin/sh
tpm2_flushcontext -t
tpm2_createprimary -C e -c primary.ctx -p password -Q

tpm2_create -G rsa -u sign.pub -r sign.priv -C primary.ctx -c sign.ctx -P password -Q

echo "data" > message.dat
tpm2_flushcontext -t

echo "Signing.."
tpm2_sign -c sign.ctx -g sha256 -o sig.rssa message.dat -Q

echo "Verifying Signature.."
tpm2_verifysignature -c sign.ctx -g sha256 -s sig.rssa -m message.dat