#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    derby_contract = DaDerpyDerby[-1]
    key = 0
    #derby_contract.address = 0xD873d7906c7c58C0e89C347E346504F09FD0E838 #latest valid contract address
    script_cids = [
        'bafybeigtunjreifmfz7czluekabw2fk56q6klir7cj63ts4uykn46kzu4y']
    #     'bafybeidgztg2wqzqhvohs675mj3ahhgaiugjbq4ftb2xvensfdrhus3sga',
    #     'bafybeidglme5rxmmlzsrtv6t6r5lbqkhaqox645x54v3qvznjjnechlfq4',
    #     'bafybeibdsi6vuh6a7fewk3yd2usazfc5ot3zerkc5sqn5qtq2jb3vaoi6i',
    #     'bafybeidrjoe7dk433llirtlhbqj3zct3a7ke76l7f7ic33emtgqxwhfs7q',
    #     'bafybeiababpqybx4plyriq6c54cxo62a3httlcq5gr73bbwwf7v6h2dhnq',
    #     'bafybeig2ow23jyppvcx5e6xh6bz6jnyvmlhb53up7dsyjvl3cqq6snwlna',
    #     'bafybeia726nvawbg2m2laaeohlq5txihpyzk6z5und3mnmbuqotstu5yli'
    # ]
    for cid in script_cids:
        cid_bytes = split_cid(cid)
        ticket = derby_contract.join_queue(cid_bytes[0], cid_bytes[1], {"from": account})
        print (derby_contract.game())
        print (derby_contract.submission_data(key))
        key = key + 1

def split_cid(cid_string):
    split_cid_bytes = [
        bytes(cid_string[0:31], 'UTF-8'),
        bytes(cid_string[31:], 'UTF-8')
    ]
    return split_cid_bytes