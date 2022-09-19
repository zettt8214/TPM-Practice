#!/bin/sh
tpm2_flushcontext -t
tpm2_createprimary -c primary.ctx -C e -Q

tpm2_create -C primary.ctx -G aes128 -u key.pub -r key.priv -Q

tpm2_flushcontext -t
tpm2_load -C primary.ctx -u key.pub -r key.priv -c key.ctx -Q

echo "my secret" > secret.dat
tpm2_flushcontext -t

echo "Encrypt file.."
tpm2_encryptdecrypt -c key.ctx -o secret.enc secret.dat 

echo "Decrypt file.."
tpm2_encryptdecrypt -d -c key.ctx -o secret.dec secret.enc 

cat secret.dec 