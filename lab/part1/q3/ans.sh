#!/bin/sh
tpm2_flushcontext -t
tpm2_createprimary -c primary.ctx -C e -Q

tpm2_create -C primary.ctx -G rsa -u srk.pub -r srk.priv -a 'fixedtpm|fixedparent|sensitivedataorigin|userwithauth|restricted|decrypt' -p 9854 -Q

tpm2_flushcontext -t
tpm2_load -C primary.ctx -u srk.pub -r srk.priv -c srk.ctx -Q

tpm2_evictcontrol -C o -c srk.ctx -o srk.handle

echo "data" > data
for((i=0;i<=9999;i++));  
do   
tpm2_flushcontext -t
tpm2_sign -c srk.handle -g sha256 -o sig.rssa data -p $i
done  