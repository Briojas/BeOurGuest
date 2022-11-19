import React from "react";

import Typography from "@mui/material/Typography";

function WatchPage() {
  return (
    <div>
      <Typography variant="h5" component="h1" gutterBottom>
        Hardware Environment Livestream
      </Typography>
      <iframe
        src="https://player.twitch.tv/?channel=whoalookout&parent=www.beourpest.com"
        frameborder="0"
        allowFullScreen={true}
        scrolling="no"
        height="378"
        width="620"
      ></iframe>
    </div>
  );
}

export default WatchPage;
