#!/bin/sh

tpm2_startauthsession --policy-session -S session.dat -T mssim:host=localhost,port=2323

tpm2_policycommandcode -S session.dat -L dpolicy.dat TPM2_CC_Duplicate  -T mssim:host=localhost,port=2323

tpm2_flushcontext --transient-object -T mssim:host=localhost,port=2323

tpm2_load -C primary.ctx -u new_parent.pub -r new_parent.prv -c new_parent.ctx -T mssim:host=localhost,port=2323

tpm2_import -C new_parent.ctx -u dup.pub -i dup.dpriv -r dup.prv -s dup.seed -L dpolicy.dat -T mssim:host=localhost,port=2323

tpm2_flushcontext --transient-object  -T mssim:host=localhost,port=2323

tpm2_load -C new_parent.ctx -u dup.pub -r dup.prv -c dup.ctx -T mssim:host=localhost,port=2323