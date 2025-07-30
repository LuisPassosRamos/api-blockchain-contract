@echo off
"C:\Program Files\Geth\geth.exe" --goerli --http --http.addr 127.0.0.1 --http.port 8545 --http.api eth,net,web3,personal --ws --ws.api eth,net,web3,personal
pause
