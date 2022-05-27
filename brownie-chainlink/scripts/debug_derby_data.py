#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    derby_contract = DaDerpyDerby[-1]
    # derby_contract.address = 0x20cD20e38c98E8D7bD8BD5bd1A82af746DCA2Ada #latest valid contract address
    print(derby_contract.submission_data(1))
    print(derby_contract.game())
    upkeep = derby_contract.checkUpkeep.call(b'',{"from": account})
    print(upkeep)
    if upkeep:
        derby_contract.performUpkeep(b'',{"from": account})
    