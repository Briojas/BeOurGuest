#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    derby_contract = DaDerpyDerby[-1]
    #derby_contract.address = 0x15DE0ed00019e41B458Ff0a39015fEE14F6675D0 #latest valid contract address
    ticket = 1 #update with ticket number of submission
    # status, score = derby_contract.check_ticket(ticket, {"from": account})
    high_score = derby_contract.high_score()
    game_queue = derby_contract.game()
    # print("status:" + str(status))
    # print("score:" + str(score))
    print(high_score)
    print(game_queue)