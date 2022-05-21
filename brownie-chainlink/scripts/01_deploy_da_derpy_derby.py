#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account
)

def deploy_da_derpy_derby():
    day_in_seconds = 24 * 60 * 60
    account = get_account()
    derby = DaDerpyDerby.deploy(
        day_in_seconds,
        {"from": account},
    )
    block_confirmations=6
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        block_confirmations=1
    derby.tx.wait(block_confirmations)
    print(f"DaDerpyDerby deployed to {derby.address}")
    return derby


def main():
    deploy_da_derpy_derby()
