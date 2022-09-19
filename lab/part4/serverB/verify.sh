#Use asymmetric private key to verify the signature 
tpm2_verifysignature -c dup.ctx -g sha256 -s sign.raw -m encrypt.data -T mssim:host=localhost,port=2323

#Decrypt the aes key, and then use aes key to decrypt the encrypted data.
tpm2_flushcontext --transient-object  -T mssim:host=localhost,port=2323
tpm2_rsadecrypt -c dup.ctx -o aes.key aes.encrypted -T mssim:host=localhost,port=2323

KEY=`grep key aes.key | awk '{print $2}'`
IV=`grep iv aes.key | awk '{print $2}'`

openssl aes-128-cbc -d -in encrypt.data -out data -K $KEY -iv $IV
cat data 