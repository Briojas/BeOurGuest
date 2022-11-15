import { Fragment } from "react";
import Head from "next/head";

function HomePage(props) {
  return (
    <Fragment>
      <Head>
        <title>Be Our Pest</title>
        <meta name="description" content="" />
      </Head>
      <h1>Madison Is Gorgeous</h1>
      <p>I love her.</p>
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

// //for static pre-rendering, only ran when project is compiled for production
// export async function getStaticProps() {
//   //fetch data from API or database

//   //TODO: pull data from contracts
//   return {
//     props: {},
//     revalidate: 60, //re-fetches data every 60 seconds (but also fetches when built)
//   };
// }

export default HomePage;
