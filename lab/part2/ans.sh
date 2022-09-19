#!/bin/bash

#Get key and vi by tpm2_getrandom and the use them to encrypt the file by openssl
echo "Cretae a AES key and encrypt the file..."
AESKEY=`tpm2_getrandom 16 --hex`
AESIV=`tpm2_getrandom 16 --hex`
echo "key: $AESKEY" > aes.key
echo "iv: $AESIV" >> aes.key
echo "secret" > secret.dat
openssl enc -e -aes-128-cbc -in secret.dat -out encrypt.data -K $AESKEY -iv $AESIV

echo "Seal the key.."
#Seal the key and vi with policy
tpm2_startauthsession -S session.ctx
tpm2_policysecret -S session.ctx -c o -L secret.policy -Q
tpm2_flushcontext session.ctx
rm session.ctx 
tpm2_flushcontext -t
tpm2_createprimary -Q -C o -g sha256 -G rsa -c prim.ctx

tpm2_create -Q -g sha256 -u sealing_key.pub -r sealing_key.priv -i aes.key -C prim.ctx -L secret.policy
rm aes.key
tpm2_flushcontext -t
tpm2_load -C prim.ctx -u sealing_key.pub -r sealing_key.priv -c sealing_key.ctx -Q

echo "-----------------------------------------"
echo "Decrypt file:"
#Unseal the object to get the key and vi
tpm2_startauthsession --policy-session -S session.ctx
tpm2_policysecret -S session.ctx -c o -L secret.policy -Q

tpm2_unseal -p "session:session.ctx" -c sealing_key.ctx > unseal.dat
tpm2_flushcontext session.ctx
rm session.ctx 
tpm2_flushcontext -t

UNSEALKEY=`grep key unseal.dat | awk '{print $2}'`
UNSEALIV=`grep iv unseal.dat | awk '{print $2}'`

#Use key and vi to decrypt the encrypted file
openssl aes-128-cbc -d -in encrypt.data -out secret.dec -K $UNSEALKEY -iv $UNSEALIV
cat secret.dat