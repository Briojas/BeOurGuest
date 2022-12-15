#!/usr/bin/python3
from brownie import BeOurPest, config, network, web3
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    bop_contract = BeOurPest[-1]
    key = 0
    
    script_cid = 'bafybeifs5yosgtlg6zupie7daldhff6ceczksb4ugs5lbddsajzwjtfd6u'

    cid_bytes = split_cid(script_cid)
    print(cid_bytes)
    
        #gas analyses
    # print(web3.eth.gasPrice)
    # last_block = web3.eth.getBlock("latest")
    # gas_limit = last_block.gasLimit / (len(last_block.transactions) if last_block.transactions else 1)
    # print(gas_limit)
    # print(mocked.functions.join_queue(cid_bytes[0], cid_bytes[1]).estimateGas({"from": account.address}))
    # print(mocked.functions.checkUpkeep(b'').estimateGas({"from": account.address}))
    # print(mocked.functions.performUpkeep(b'').estimateGas({"from": account.address}))

    upkeep = bop_contract.checkUpkeep.call(b'',{"from": account})
    print('Needs Upkeep? ' + str(upkeep[0]))
    if(upkeep[0]):
        performUpkeep = bop_contract.performUpkeep.call(b'',{"from": account})
    
    ticket = bop_contract.join_queue(cid_bytes[0], cid_bytes[1], {"from": account})
    print(ticket)
    print (bop_contract.activity())
    print (bop_contract.submission_data(key))

    

def split_cid(cid_string):
    split_cid_bytes = [
        bytes(cid_string[0:31], 'UTF-8'),
        bytes(cid_string[31:], 'UTF-8')
    ]
    return split_cid_bytes