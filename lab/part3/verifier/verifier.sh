#!/bin/bash

#Bank location
bank_location="$PWD/../bank"

# Attestation Data
GOLDEN_PCR_SELECTION="sha256:0,1,2"
GOLDEN_PCR="74e9e8829fdeca7671e0a459a6bfd79bd506fe064e0a58583b1dd83644ecd968"


wait_loop() {
    counter=1
    until [ $counter -gt $1 ]
    do
       test -f $2
       if [ $? == 0 ];then
          event_file_found=1
          break
       else
          echo -ne "Waiting $1 seconds: $counter"'\r'
       fi
       ((counter++))
       sleep 1
    done
}

LOG_ERROR() {
    errorstring=$1
    echo -e "\033[31mFAIL: \e[97m${errorstring}\e[0m"
}

LOG_INFO() {
    messagestring=$1
    echo -e "\033[93mPASS: \e[97m${messagestring}\e[0m"
}


system_software_state_validation() {

   #send the request and nonce for attestation
   rm -f attestation_quote.dat attestation_quote.signature pcr.bin
   echo "pcr-selection: $GOLDEN_PCR_SELECTION" > pcrlist.txt
   NONCE=`dd if=/dev/urandom bs=1 count=32 status=none | xxd -p -c32`
   echo "nonce: $NONCE" >> pcrlist.txt
   cp pcrlist.txt $bank_location/.
   rm -f pcrlist.txt

   software_status_string="Attestation data receipt from Bank"
   max_wait=60
   wait_loop $max_wait attestation_quote.dat
   if [ $event_file_found == 0 ];then
      LOG_ERROR "$software_status_string"
      return 1
   fi
   LOG_INFO "$software_status_string"
   event_file_found=0

   software_status_string="Attestation signature receipt from Bank"
   max_wait=60
   wait_loop $max_wait attestation_quote.signature
   if [ $event_file_found == 0 ];then
      LOG_ERROR "$software_status_string"
      return 1
   fi
   LOG_INFO "$software_status_string"
   event_file_found=0

   software_status_string="Attestation quote signature validation"
   tpm2_flushcontext -t
   tpm2_checkquote --public akpub.pem --qualification "$NONCE" \
   --message attestation_quote.dat --signature attestation_quote.signature \
   --pcr pcr.bin -Q
   retval=$?
   rm -f attestation_quote.signature
   if [ $retval == 1 ];then
      LOG_ERROR "$software_status_string"
      return 1
   fi
   LOG_INFO "$software_status_string"

   software_status_string="Verification of PCR from quote against golden reference"
   testpcr=`tpm2_print -t TPMS_ATTEST attestation_quote.dat | \
   grep pcrDigest | awk '{print $2}'`
   rm -f attestation_quote.dat
   if [ "$testpcr" == "$GOLDEN_PCR" ];then
      LOG_INFO "$software_status_string"
   else
      LOG_ERROR "$software_status_string"
      echo -e "      \e[97mDevice-PCR: $testpcr\e[0m"
      echo -e "      \e[97mGolden-PCR: $GOLDEN_PCR\e[0m"
      return 1
   fi

   return 0
}

# Check the device software state by getting a device quote
request_device_service_status_string="Device system software validation."
system_software_state_validation
if [ $? == 1 ];then
    LOG_ERROR "$request_device_service_status_string"
fi
LOG_INFO "$request_device_service_status_string"