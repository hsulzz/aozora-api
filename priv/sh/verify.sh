#!/bin/bash

if [ "$#" -gt 1 -o "$#" -eq 0 ]; then
    echo "Usage: $0 <mix_env>"
    exit 1
fi

# 需要验证的函数
to_verify_list=(
    "Aozora.Endpoint.Token.TokenRegistry.refresh"
    "Aozora.Endpoint.Token.TokenRegistry.get"
    "Aozora.Endpoint.Account.get"
    "Aozora.Endpoint.Account.Transaction.get"
    "Aozora.Endpoint.Debit.AuthorizedTransaction.get"
    "Aozora.Endpoint.Debit.ClearedTransaction.get")

# 启动
 ./_build/$1/rel/aozora/bin/aozora daemon 
sleep 10
# 循环调用
for endpoint in "${to_verify_list[@]}"; do
    ./_build/$1/rel/aozora/bin/aozora rpc "$endpoint |> dbg"
    sleep 1
done

# 停止
./_build/$1/rel/aozora/bin/aozora stop
