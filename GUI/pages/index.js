import { Fragment } from "react";
import Head from "next/head";

import Container from "@mui/material/Container";
import Typography from "@mui/material/Typography";
import Box from "@mui/material/Box";

function HomePage(props) {
  return (
    <Fragment>
      <Head>
        <title>Be Our Pest</title>
        <meta name="description" content="" />
      </Head>
      <Container maxWidth="sm">
        <Box sx={{ my: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom>
            Welcome!
          </Typography>
          <p>
            This is a platform for securely interacting with hardware
            environments.
          </p>
          {/* <Copyright /> */}
        </Box>
      </Container>
    </Fragment>
  );
}

////// hosting on Fleek, so won't use dynamic pre-rendering
// export async function getServerSideProps(context) {
//   const req = context.req; //request
//   const res = context.res; //response
//   //fetch data from an API

//   return {
//     props: {
//       meetups: DUMMY_DATA,
//     },
//   };
// }

//for static pre-rendering, only ran when project is compiled for production
export async function getStaticProps() {
  //fetch data from API or database

  //TODO: pull data from contracts
  return {
    props: {},
    revalidate: 60, //re-fetches data every 60 seconds (but also fetches when built)
  };
}

export default HomePage;
