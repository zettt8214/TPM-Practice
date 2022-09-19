#!/bin/sh
tpm2_startauthsession --policy-session -S session.dat -T mssim:host=localhost,port=2321

tpm2_policycommandcode -S session.dat -L dpolicy.dat TPM2_CC_Duplicate -T mssim:host=localhost,port=2321

tpm2_loadexternal -C o -u new_parent.pub -c new_parent.ctx -T mssim:host=localhost,port=2321

tpm2_flushcontext -t -T mssim:host=localhost,port=2321

tpm2_duplicate -C new_parent.ctx -c key.ctx -G null -p "session:session.dat" -r dup.dpriv -s dup.seed -T mssim:host=localhost,port=2321

cp dup.* ../serverB