import Link from "next/link";
// import classes from "./MainNavigation.module.css";

import { useWeb3React } from "@web3-react/core";
import { InjectedConnector } from "@web3-react/injected-connector";
import { useState, useEffect } from "react";

export const injected = new InjectedConnector();

function MainNavigation() {
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
    <header className="">
      <div className="">
        <Link href="/">Be Our Pest</Link>
      </div>
      <nav>
        <ul>
          <li>
            <Link href="/watch">Watch</Link>
          </li>
          <li>
            <Link href="/play">Play</Link>
          </li>
          <li>
            <Link href="/host">Host</Link>
          </li>
          <li>
            <Link href="/about">About</Link>
          </li>
        </ul>
        {hasMetamask ? (
          active ? (
            "Connected! "
          ) : (
            <button onClick={() => connect()}>Connect</button>
          )
        ) : (
          "Please install metamask"
        )}

        {/* {active ? <button onClick={() => execute()}>Execute</button> : ""} */}
      </nav>
    </header>
  );
}

export default MainNavigation;
