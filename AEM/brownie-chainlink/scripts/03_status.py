#!/usr/bin/python3
from brownie import BeOurPest, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()

    bop_contract = BeOurPest[-1]
    print('Latest BeOurPest address: ' + bop_contract.address)

    upkeep = bop_contract.checkUpkeep.call(b'',{"from": account})
    print('Needs Upkeep? ' + str(upkeep[0]))
    print('')
    
    queue = bop_contract.activity()
    print('----Ticket Stats----')
    print('number of tickets: ' + str(queue[0][0]))
    print('current ticket: ' + str(queue[0][1]))
    ticket_key = str(queue[0][2])
    print('current ticket key: ' + ticket_key)
    print('')
    
    script = bop_contract.submission_data.call(ticket_key, {"from": account})
    print('----Current Script----')
    print('script owner: ' + script[0])
    print('script being processed: ' + script[2])
    print('sent for processing? - ' + str(script[3]))
    print('')

    print('----Next Script----')
    next_ticket_key = str(queue[0][3])
    print('next ticket: ' + next_ticket_key)
    next_script = bop_contract.submission_data.call(ticket_key, {"from": account})
    print('script owner: ' + next_script[0])
    print('script to be processed: ' + next_script[2])
    print('')

    print('----Queue State----')
    states = ['READY', 'EXECUTING', 'EXECUTED', 'COLLECTING', 'COLLECTED']
    print(states[queue[1]])

