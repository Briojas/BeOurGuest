import Link from "next/link";
import { useWeb3React } from "@web3-react/core";
import { InjectedConnector } from "@web3-react/injected-connector";
import { useState, useEffect } from "react";

export const injected = new InjectedConnector();

function NavBar() {
  const [hasMetamask, setHasMetamask] = useState(false);

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      setHasMetamask(true);
    }
  });

  const {
    active,
    activate,
    chainId,
    account,
    library: provider,
  } = useWeb3React();

  async function connect() {
    if (typeof window.ethereum !== "undefined") {
      try {
        await activate(injected);
        setHasMetamask(true);
      } catch (e) {
        console.log(e);
      }
    }
  }

  return (
    <div className="fixed top-0 left-0 h-12 w-screen flex flex-row text-lg font-medium bg-gray-800 text-yellow-400 shadow-lg">
      <Link href="/">
        <button className="p-3 font-bold">BeOurPest</button>
      </Link>
      <Link href="/watch">
        <button className="p-3">Watch</button>
      </Link>
      <Link href="/engage">
        <button className="p-3">Engage</button>
      </Link>
      <Link href="/host">
        <button className="p-3">Host</button>
      </Link>
      <Link href="/about">
        <button className="p-3">About</button>
      </Link>
      <div className="p-3">
        {hasMetamask ? (
          active ? (
            <i> Wallet: {account} </i>
          ) : (
            <button onClick={() => connect()}> Connect Wallet </button>
          )
        ) : (
          <Link href="https://metamask.io/"> Install Metamask </Link>
        )}
      </div>
    </div>
  );
}

export default NavBar;
