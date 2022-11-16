import React from "react";

function WatchPage() {
  return (
    <div>
      <h3>Livestream:</h3>
      <iframe
        width="560"
        height="315"
        src="https://www.youtube.com/embed/21X5lGlDOfg"
        title="YouTube video player"
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>
    </div>
  );
}

export default WatchPage;
