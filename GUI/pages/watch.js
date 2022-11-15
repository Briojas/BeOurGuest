import React from "react";
import { Fragment } from "react";
import YouTube from "react-youtube";

import { Livestream } from "../components/Livestream";

function WatchPage() {
  return (
    <div>
      <h3>Livestream:</h3>
      <iframe
        width="560"
        height="315"
        src="https://www.youtube.com/embed/21X5lGlDOfg"
        title="YouTube video player"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>
      {/* <Livestream video={"21X5lGlDOfg"} width={"560"} height={"315"} /> */}
    </div>
  );
}

// export async function getStaticProps() {}

export default WatchPage;
