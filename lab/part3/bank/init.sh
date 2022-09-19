 #/bin/bash


 #Use a random hash extend the  specified PCRs which will be  placeholder measurements in attestation. 
 pcr0=`echo -n "measurement0" | openssl dgst -sha256 -binary | xxd -p -c 32` #PCR0: Code of BIOS
 pcr1=`echo -n "measurement1" | openssl dgst -sha256 -binary | xxd -p -c 32` #PCR1: Host Platform Configuration
 pcr2=`echo -n "measurement2" | openssl dgst -sha256 -binary | xxd -p -c 32` #PCR2: Option ROM Code

 tpm2_pcrextend 0:sha256=$pcr0
 tpm2_pcrextend 1:sha256=$pcr1
 tpm2_pcrextend 2:sha256=$pcr2

 #Create EK and AK in bank, then sharing the AK to verifier
 tpm2_createek -c ek.ctx -G rsa -u ekpub.pem -f pem -Q
 tpm2_createak -C ek.ctx -c ak.ctx -G rsa -s rsassa -g sha256 -u akpub.pem -f pem -n ak.name -Q
 cp ./akpub.pem ../verifier/