import ScriptManager from "../components/data-management/ScriptManager";
import { useWeb3React } from "@web3-react/core";
import { ethers } from "ethers";
import { abi } from "../constants/abi";

function EngagePage() {
  const { active, chainId, account, library: provider } = useWeb3React();

  function splitCID(cid) {
    return [
      Buffer.from(cid.slice(0, 31), "utf8"),
      Buffer.from(cid.slice(31), "utf8"),
    ];
  }

  async function submitScript(json) {
    const response = await fetch("/api/new-script", {
      method: "POST",
      body: JSON.stringify(json),
    });

    const data = await response.json();
    console.log(data);
    console.log(data.ipfsHash);

    // if (active) {
    //   //check metamask is connected
    //   //build json file and send to api
    //   console.log(json);
    //   const response = await fetch("/api/new-script", {
    //     method: "POST",
    //     body: JSON.stringify(json),
    //   });

    //   const data = await response.json();
    //   console.log(data);
    //   console.log(data.ipfsHash);

    //   const split_cid = splitCID(data.ipfsHash);

    //   //submit to contract via metamask
    //   const signer = provider.getSigner();
    //   const contractAddress = "0xC33A49b02FD0432148dcF77Ef876a454bA30578a";
    //   const contract = new ethers.Contract(contractAddress, abi, signer);

    //   try {
    //     await contract.join_queue(split_cid[0], split_cid[1]);
    //   } catch (error) {
    //     console.log(error);
    //   }
    // } else {
    //   console.log("Please connect/install MetaMask wallet");
    // }
  }

  return (
    <div>
      <h1>Engage with a host:</h1>
      <ScriptManager onNewScript={submitScript} />
    </div>
  );
}

export default EngagePage;
