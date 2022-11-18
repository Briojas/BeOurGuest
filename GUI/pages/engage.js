import ScriptManager from "../components/data-management/ScriptManager";
import { useWeb3React } from "@web3-react/core";
import { abi } from "../constants/abi";

function EngagePage() {
  const { active, chainId, account, library: provider } = useWeb3React();

  function splitCID(cid){
    
    
  }

  async function submitScript(json) {
    if (active) {
      //check metamask is connected
      //build json file and send to api
      const response = await fetch("/api/new-script", {
        method: "POST",
        body: JSON.stringify(json),
      });

      const data = await response.json();

      console.log(data.ipfsHash);

      //submit to contract via metamask
      const signer = provider.getSigner();
      const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
      const contract = new ethers.Contract(contractAddress, abi, signer);
      try {
        await contract.store(42);
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("Please connect/install MetaMask wallet");
    }
  }

  return (
    <div>
      <h1>Engage with a host:</h1>
      <ScriptManager onNewScript={submitScript} />
    </div>
  );
}

export default EngagePage;
