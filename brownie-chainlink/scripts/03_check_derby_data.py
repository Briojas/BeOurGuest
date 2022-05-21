#!/usr/bin/python3
from brownie import DaDerpyDerby, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    derby_contract = DaDerpyDerby[-1]
    #derby_contract.address = 0x539cBD70eaab57D1C3ae0D61FBD9AC742e7Ba953 #latest valid contract address
    ticket = 1 #update with ticket number of submission
    status, score = derby_contract.check_ticket(ticket, {"from": account})
    curr_leader = derby_contract.high_score.leader
    curr_high_score = derby_contract.high_score.score
    print("status:" + str(status))
    print("score:" + str(score))
    print("leader:" + str(curr_leader))
    print("high score:" + str(curr_high_score))