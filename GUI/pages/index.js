import Link from "next/link";
import { Fragment } from "react";

function WatchPage() {
  return (
    <Fragment>
      <h1>The Home Page</h1>;
      <ul>
        <li>
          <Link href={"/play"}>Play</Link>
        </li>
        <li>
          <a href="/host">Host</a>
        </li>
      </ul>
    </Fragment>
  );
}

export default WatchPage;
