#!/usr/bin/python3
from brownie import BeOurPest, config, network, web3
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    bop_contract = BeOurPest[-1]
    key = 0
    #bog_contract.address = 0x714c52208323D9Cd676f7529108833AbA1Da8455
    script_cid = 'bafybeiguqxkjrp23hstv7gnyxvjaj3g65uamjj46orho7mxcjbrskjuo5u'
    #     'bafybeidgztg2wqzqhvohs675mj3ahhgaiugjbq4ftb2xvensfdrhus3sga',
    #     'bafybeidglme5rxmmlzsrtv6t6r5lbqkhaqox645x54v3qvznjjnechlfq4',
    #     'bafybeibdsi6vuh6a7fewk3yd2usazfc5ot3zerkc5sqn5qtq2jb3vaoi6i',
    #     'bafybeidrjoe7dk433llirtlhbqj3zct3a7ke76l7f7ic33emtgqxwhfs7q',
    #     'bafybeiababpqybx4plyriq6c54cxo62a3httlcq5gr73bbwwf7v6h2dhnq',
    #     'bafybeig2ow23jyppvcx5e6xh6bz6jnyvmlhb53up7dsyjvl3cqq6snwlna',
    #     'bafybeia726nvawbg2m2laaeohlq5txihpyzk6z5und3mnmbuqotstu5yli'

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