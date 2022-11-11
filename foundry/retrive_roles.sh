#!/usr/local/bin/bash
export ETH_RPC_URL=https://rpc.ankr.com/eth

declare -A tokens abi
tokens["HBCH"]="0xaAC679720204aAA68B6C5000AA87D789a3cA0Aa5"
tokens["HBSV"]="0x14007c545e6664C8370F27fa6B99DC830e6510a6"
tokens["HDOT"]="0x9ffc3bCDe7B68C46a6dC34f0718009925c1867cB"
tokens["HFIL"]="0x9AFb950948c2370975fb91a441F36FDC02737cD4"
tokens["HLTC"]="0x2c000c0093dE75a8fA2FccD3d97b314e20b431C3"
tokens["HXTZ"]="0x4A10307E221781570E4B7E409EB315F11E8D0385"
tokens["HBTC"]="0x0316EB71485b0Ab14103307bf65a021042c6d380"
echo ${#tokens[@]}

abi='getAdminAddresses(string)returns(address[] memory)'

for key in ${!tokens[*]};do
    echo $key
    echo ${tokens[$key]}
    owners=$(cast  call ${tokens[$key]}  "$abi" 'owner')
    echo "$owners"
    operators=$(cast  call ${tokens[$key]}  "$abi" 'operator')
    echo "$operators"
done
