import Link from "next/link";
// import classes from "./MainNavigation.module.css";

import { Web3Provider } from "@ethersproject/providers";
import { useWeb3React, Web3ReactProvider } from "@web3-react/core";
import { InjectedConnector } from "@web3-react/injected-connector";
import { useState, useEffect } from "react";

export const injected = new InjectedConnector();

// const getLibrary = (provider) => {
//   return new Web3Provider(provider);
// };

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
    <header>
      <div className="">
        <Link href="/"> BeOurPest </Link>
      </div>
      <nav className="">
        <i>
          <Link href="/watch"> Watch |</Link>
        </i>
        <i>
          <Link href="/engage"> Engage |</Link>
        </i>
        <i>
          <Link href="/host"> Host |</Link>
        </i>
        <i>
          <Link href="/about"> About |</Link>
        </i>
        {hasMetamask ? (
          active ? (
            <i> Wallet: {account} </i>
          ) : (
            <button onClick={() => connect()}> Connect Wallet </button>
          )
        ) : (
          <Link href="https://metamask.io/"> Install Metamask </Link>
        )}
      </nav>
    </header>
  );
}

export default NavBar;
