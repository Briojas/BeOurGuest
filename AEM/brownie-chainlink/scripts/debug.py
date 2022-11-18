#!/usr/bin/python3
from brownie import BeOurPest, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    print(account.address)
    print(account.balance())

    bop_contract = BeOurPest[-1]
    print(bop_contract.address)
    
    # for num_sub in range(9):
    #     print(bop_contract.submission_data(num_sub))
    print(bop_contract.activity())
    upkeep = bop_contract.checkUpkeep.call(b'',{"from": account})
    print(upkeep[0])
    # if upkeep[0]:
    #     print('performing upkeep')
    #     bop_contract.performUpkeep(b'',{"from": account})