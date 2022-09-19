#!/bin/sh

#Use TPM generate a duplicable asymmetric key
tpm2_flushcontext -t  -T mssim:host=localhost,port=2321
tpm2_createprimary -C o -g sha256 -G rsa -c primary.ctx -T mssim:host=localhost,port=2321 -Q

tpm2_startauthsession -S session.dat -T mssim:host=localhost,port=2321

tpm2_policycommandcode -S session.dat -L dpolicy.dat TPM2_CC_Duplicate -T mssim:host=localhost,port=2321 -Q

tpm2_flushcontext session.dat -T mssim:host=localhost,port=2321

rm session.dat
tpm2_flushcontext -t  -T mssim:host=localhost,port=2321
tpm2_create -C primary.ctx -g sha256 -G rsa -r key.prv -u key.pub  -L dpolicy.dat -a "sensitivedataorigin|userwithauth|decrypt|sign" -Q -T mssim:host=localhost,port=2321

#!/bin/sh
tpm2_flushcontext -t  -T mssim:host=localhost,port=2321
tpm2_load -C primary.ctx -r key.prv -u key.pub -c key.ctx -T mssim:host=localhost,port=2321 -Q
tpm2_readpublic -c key.ctx -o dup.pub -T mssim:host=localhost,port=2321 -Q

#Use TPM generate a symmetric key for openssl
AESKEY=`tpm2_getrandom 16 --hex -T mssim:host=localhost,port=2321`
AESIV=`tpm2_getrandom 16 --hex -T mssim:host=localhost,port=2321`
echo "key: $AESKEY" > aes.key
echo "iv: $AESIV" >> aes.key


#Encrypt data and symmetric key
echo 'important data....' > protect.dat


openssl enc -e -aes-128-cbc -in protect.dat -out encrypt.data -K $AESKEY -iv $AESIV
tpm2_flushcontext -t  -T mssim:host=localhost,port=2321

tpm2_rsaencrypt -c key.ctx  -o aes.encrypted aes.key -T mssim:host=localhost,port=2321 -Q

tpm2_flushcontext -t  -T mssim:host=localhost,port=2321

tpm2_sign -c key.ctx -g sha256 -o sign.raw encrypt.data -T mssim:host=localhost,port=2321 -Q

cp aes.encrypted encrypt.data sign.raw ../serverB/