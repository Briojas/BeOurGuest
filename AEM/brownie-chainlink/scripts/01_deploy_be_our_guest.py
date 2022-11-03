#!/usr/bin/python3
from brownie import BeOurGuest, config, network
from scripts.helpful_scripts import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    fund_with_link,
    get_account
)

def deploy_be_our_guest():
    day_in_seconds = 24 * 60 * 60
    account = get_account()
    bog = BeOurGuest.deploy(
        day_in_seconds, #high score reset interval
        60,             #retry submission interval
        60,             #retry collecting score interval
        {"from": account}
    )
    block_confirmations=6
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        block_confirmations=1
    bog.tx.wait(block_confirmations)
    print(f"BeOurGuest deployed to {bog.address}")
    tx = fund_with_link(
            bog.address, amount=config["networks"][network.show_active()]["fee"]
        )
    tx.wait(1)
    return bog


def main():
    deploy_be_our_guest()
