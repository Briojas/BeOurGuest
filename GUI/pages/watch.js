import React from "react";

import Typography from "@mui/material/Typography";

function WatchPage() {
  return (
    <div>
      <Typography variant="h5" component="h1" gutterBottom>
        Hardware Environment Livestream
      </Typography>
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
