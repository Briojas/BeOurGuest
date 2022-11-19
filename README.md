### BeOurPest

_Chainlink Fall 22 Hackathon Submission_

- Full Disclosure: This submission is an addendum to my [Spring 22 Hackathon Submission](https://github.com/Briojas/BeOurPest/blob/main/Docs/2022%20Chainlink%20Spring%20Hackathon.md)

# Key Features

- Web3 Frontend allows users to create and submit scripts to control remote hardware-enabled environments

## Inspiration

I have had a passion for embedded systems since college, and have a desire to meld this with my new found interest in the decentralized web. Sergey has been the biggest inspiration in his pursuit for a world powered by truth. He speaks often of the need for more reliable data sources, and enabling hardware to share data on-chain his how I see myself contributing to this need.

## What it does

This project was supposed to showcase a user's perspective on interacting with a remote environment from a Web3 site, but I was just not able to overcome the integration nightmare that was this undertaking.

In an ideal situation:

1. The user navigates to the [BeOurPest](https://beourpest.com/) website, and connects their metamask wallet.
2. Watches events occuring on the "Watch" tab.
3. Engages with events on the "Engage" tab using the json tool and signing the transaction to send it to the BeOurPest contract for processing.
4. And, signs up to become a host on the "Host" tab by setting up their own environment locally.

## How we built it

NextJS and the Web3-React library

## Challenges we ran into

This was really an integration nightmare. Migrating from Kovan to Goerli was a larger challenge than I anticiapated. The time consumed from testing connections between the interfaces is what doomed me in the end I think.

Interfaces tested:

- Web3 UI to Smart Contract
- Web3 UI to IPFS
- Smart Contract monitoring upkeep on Chainlink Automation
- Smart Contract to Node jobs
- Node jobs communicating to external adapter bridge
- Bridge pulling IPFS
- Bridge connecting to hardware through MQTT Broker (pub-sub protocol)

## Accomplishments that we're proud of

I progressed my frontend development skills further than I thought, and maintained running my own Chainlink node and external adapter through the Kovan-Goerli migration.

## What we learned

- React/NextJS
- Web3.js
- Chainlink Automation
- Fleek IPFS Hosting and Storage

## What's next for BeOurPest

- A more defined GUI that actually works
- Enabling a user to become a host
- Developing a dedicated hardware environment kit for less experienced people who would like to host
