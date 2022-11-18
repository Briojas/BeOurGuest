#!/usr/bin/python3
from brownie import BeOurPest, config, network, web3
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    bop_contract = BeOurPest[-1]
    key = 0
    #bog_contract.address = 0x631739cBc62F6ef67C910046F6e45B742F9f6952
    script_cids = [
        'bafybeiguqxkjrp23hstv7gnyxvjaj3g65uamjj46orho7mxcjbrskjuo5u']
    #     'bafybeidgztg2wqzqhvohs675mj3ahhgaiugjbq4ftb2xvensfdrhus3sga',
    #     'bafybeidglme5rxmmlzsrtv6t6r5lbqkhaqox645x54v3qvznjjnechlfq4',
    #     'bafybeibdsi6vuh6a7fewk3yd2usazfc5ot3zerkc5sqn5qtq2jb3vaoi6i',
    #     'bafybeidrjoe7dk433llirtlhbqj3zct3a7ke76l7f7ic33emtgqxwhfs7q',
    #     'bafybeiababpqybx4plyriq6c54cxo62a3httlcq5gr73bbwwf7v6h2dhnq',
    #     'bafybeig2ow23jyppvcx5e6xh6bz6jnyvmlhb53up7dsyjvl3cqq6snwlna',
    #     'bafybeia726nvawbg2m2laaeohlq5txihpyzk6z5und3mnmbuqotstu5yli'
    # ]
    # for cid in script_cids:
    # for cid in range(5):
        # cid_bytes = split_cid(cid)
    cid_bytes = split_cid(script_cids[0])
    print(cid_bytes)
    
    print(account.address)
    print(bop_contract.address)

    print(web3.eth.gasPrice)
    last_block = web3.eth.getBlock("latest")
    gas_limit = last_block.gasLimit / (len(last_block.transactions) if last_block.transactions else 1)
    print(gas_limit)
    ticket = bop_contract.join_queue(cid_bytes[0], cid_bytes[1], {"from": account})
    print(ticket)
    print (bop_contract.activity())
    print (bop_contract.submission_data(key))
    key = key + 1

    # mocked = web3.eth.contract(
    #        address = bop_contract.address,
    #        abi = bop_contract.abi
    #      )

    # print(mocked.functions.join_queue(cid_bytes[0], cid_bytes[1]).estimateGas({"from": account.address}))
    # print(mocked.functions.checkUpkeep(b'').estimateGas({"from": account.address}))
    # print(mocked.functions.performUpkeep(b'').estimateGas({"from": account.address}))

def split_cid(cid_string):
    split_cid_bytes = [
        bytes(cid_string[0:31], 'UTF-8'),
        bytes(cid_string[31:], 'UTF-8')
    ]
    return split_cid_bytes