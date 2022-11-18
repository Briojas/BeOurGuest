module.exports = {
  abi: [
    {
      inputs: [
        {
          internalType: "uint256",
          name: "score_reset_interval_sec",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "retry_submitting_interval_sec",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "retry_scoring_interval_sec",
          type: "uint256",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "id",
          type: "bytes32",
        },
      ],
      name: "ChainlinkCancelled",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "id",
          type: "bytes32",
        },
      ],
      name: "ChainlinkFulfilled",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "id",
          type: "bytes32",
        },
      ],
      name: "ChainlinkRequested",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "from",
          type: "address",
        },
        {
          indexed: true,
          internalType: "address",
          name: "to",
          type: "address",
        },
      ],
      name: "OwnershipTransferRequested",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "from",
          type: "address",
        },
        {
          indexed: true,
          internalType: "address",
          name: "to",
          type: "address",
        },
      ],
      name: "OwnershipTransferred",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "player",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "ticket",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "bool",
          name: "executed",
          type: "bool",
        },
      ],
      name: "executed_ticket",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "player",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "ticket",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "score",
          type: "uint256",
        },
      ],
      name: "scored_ticket",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "player",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "ticket",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "ticket_key",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "string",
          name: "script_cid",
          type: "string",
        },
      ],
      name: "submission_ticket",
      type: "event",
    },
    {
      inputs: [],
      name: "acceptOwnership",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "activity",
      outputs: [
        {
          components: [
            {
              internalType: "uint256",
              name: "num_tickets",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "curr_ticket",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "curr_ticket_key",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "next_submission_key",
              type: "uint256",
            },
          ],
          internalType: "struct Tickets",
          name: "tickets",
          type: "tuple",
        },
        {
          internalType: "enum States",
          name: "state",
          type: "uint8",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "checkData",
          type: "bytes",
        },
      ],
      name: "checkUpkeep",
      outputs: [
        {
          internalType: "bool",
          name: "upkeepNeeded",
          type: "bool",
        },
        {
          internalType: "bytes",
          name: "performData",
          type: "bytes",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "debug_reset",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_requestId",
          type: "bytes32",
        },
        {
          internalType: "bool",
          name: "status",
          type: "bool",
        },
      ],
      name: "fulfill_execution_request",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_requestId",
          type: "bytes32",
        },
        {
          internalType: "uint256",
          name: "score",
          type: "uint256",
        },
      ],
      name: "fulfill_score",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "high_score",
      outputs: [
        {
          internalType: "uint256",
          name: "reset_interval",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "score",
          type: "uint256",
        },
        {
          internalType: "address payable",
          name: "leader",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "script_cid_1",
          type: "bytes",
        },
        {
          internalType: "bytes",
          name: "script_cid_2",
          type: "bytes",
        },
      ],
      name: "join_queue",
      outputs: [
        {
          internalType: "uint256",
          name: "ticket",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "ticket_key",
          type: "uint256",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "max_retry_attempts",
      outputs: [
        {
          internalType: "uint16",
          name: "",
          type: "uint16",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "owner",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "performData",
          type: "bytes",
        },
      ],
      name: "performUpkeep",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "retry_attempts",
      outputs: [
        {
          internalType: "uint16",
          name: "",
          type: "uint16",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "ticket_key",
          type: "uint256",
        },
      ],
      name: "submission_data",
      outputs: [
        {
          internalType: "address",
          name: "player",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "ticket",
          type: "uint256",
        },
        {
          internalType: "string",
          name: "script_cid",
          type: "string",
        },
        {
          internalType: "bool",
          name: "executed",
          type: "bool",
        },
        {
          internalType: "uint256",
          name: "score",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "to",
          type: "address",
        },
      ],
      name: "transferOwnership",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "withdraw_eth",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "withdraw_link",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
};
