#!/bin/sh

sverifier_location="$PWD/../verifier"

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

process_device_software_state_validation_request() {

    software_state_string="PCR selection list receipt from Verifier"
    max_wait=60
    wait_loop $max_wait pcrlist.txt
    if [ $event_file_found == 0 ];then
        LOG_ERROR "$software_state_string"
        return 1
    fi
    LOG_INFO "$software_state_string"
    event_file_found=0
    pcr_selection=`grep pcr-selection pcrlist.txt | \
    awk '{print $2}'`
    service_provider_nonce=`grep nonce pcrlist.txt | \
    awk '{print $2}'`
    rm -f pcrlist.txt
    
    tpm2_flushcontext -t
    tpm2_quote --key-context ak.ctx --message attestation_quote.dat \
    --signature attestation_quote.signature \
    --qualification "$service_provider_nonce" \
    --pcr-list "$pcr_selection" \
    --pcr pcr.bin -Q

    cp attestation_quote.dat attestation_quote.signature pcr.bin \
    $sverifier_location/.

    return 0
}

request_service_status_string="Bank state validation"
process_device_software_state_validation_request
if [ $? == 1 ];then
    LOG_ERROR "$request_service_status_string"
    return 1
fi
LOG_INFO "$request_service_status_string"