import { Fragment } from "react";
import Head from "next/head";

import Container from "@mui/material/Container";
import Typography from "@mui/material/Typography";
import Box from "@mui/material/Box";

function HostPage() {
  return (
    <Fragment>
      <Head>
        <title>Host</title>
        <meta name="description" content="" />
      </Head>
      <Container maxWidth="sm">
        <Box sx={{ my: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom>
            Become a Host
          </Typography>
          <p>Page in work.</p>
          {/* <p>Would you like to host your own hardware environment?</p> */}
          {/* <Copyright /> */}
        </Box>
      </Container>
    </Fragment>
  );
}

export default HostPage;
