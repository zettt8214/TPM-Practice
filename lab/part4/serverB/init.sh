#!/bin/sh
tpm2_flushcontext -t  -T mssim:host=localhost,port=2323
tpm2_createprimary -C o -g sha256 -G rsa -c primary.ctx -Q -T mssim:host=localhost,port=2323

tpm2_create  -C primary.ctx -g sha256 -G rsa -r new_parent.prv  -u new_parent.pub -a "restricted|sensitivedataorigin|decrypt|userwithauth" -Q -T mssim:host=localhost,port=2323

cp new_parent.pub ../serverA