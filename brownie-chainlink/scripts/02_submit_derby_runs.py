#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    derby_contract = DaDerpyDerby[-1]
    #derby_contract.address = 0xA4ce654aEe82615e24A65B2613FAA29124916fDb #latest valid contract address
    script_cids = [
        'bafybeifuwwpnax3l6u3ymhuywqpqj2bsaswbcacfnjbn3fjbtloq7m7buy',
        'bafybeigkweundbmw7sykcdkavtry62cmyhtqxqqge42oish3aga65ulpua',
        'bafybeictce47tbuyb76iwxqtlbatmlkch6j5qzlexakz736f3egy56tn5q',
        'bafybeibvtjeu2ymjfbewxkxyab6fjkwdpmvzfjllzryj4havbvfqpv4kde',
        'bafybeias5qyksjzjhw55ry6ikwr464vwplzmpotrgsoipdw5dvaoacswty',
        'bafybeihiarb2z7b4akdupbstkjupe4kwfcx4snb4zvgtqjlwo2pzn72boe',
        'bafybeieqql7cmc4ajn44niuiryy2pct2xc7k3tmohbkc4jbziam4crccmy',
        'bafybeigx5tjpy6dzhz2525vfibkfcfk4jtni2oubq3konbpwtlnz4junmq'
    ]
    for cid in script_cids:
        tx = fund_with_link(
            derby_contract.address, amount=config["networks"][network.show_active()]["fee"]
        )
        tx.wait(1)
        cid_bytes = split_cid(cid)
        ticket = derby_contract.join_queue(cid_bytes[0], cid_bytes[1], {"from": account})
        print (ticket)

def split_cid(cid_string):
    split_cid_bytes = [
        bytes(cid_string[0:31], 'UTF-8'),
        bytes(cid_string[31:], 'UTF-8')
    ]
    return split_cid_bytes