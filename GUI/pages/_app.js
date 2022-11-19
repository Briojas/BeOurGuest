import "../styles/globals.css";
import "@fontsource/roboto/300.css";
import "@fontsource/roboto/400.css";
import "@fontsource/roboto/500.css";
import "@fontsource/roboto/700.css";

import Layout from "../components/Layout";
import { Web3ReactProvider } from "@web3-react/core";
import { Web3Provider } from "@ethersproject/providers";
import { Fragment } from "react";
import Head from "next/head";

const getLibrary = (provider) => {
  return new Web3Provider(provider);
};

function MyApp({ Component, pageProps }) {
  return (
    <Fragment>
      <Head>
        <meta name="viewport" content="initial-scale=1, width=device-width" />
        <meta charSet="utf-8" />
        <link
          rel="stylesheet"
          href="https://unpkg.com/spectre.css/dist/spectre.min.css"
        />
        <link
          rel="stylesheet"
          href="https://unpkg.com/spectre.css/dist/spectre-exp.min.css"
        />
        <link
          rel="stylesheet"
          href="https://unpkg.com/spectre.css/dist/spectre-icons.min.css"
        />
        <script src="https://cdn.jsdelivr.net/npm/@json-editor/json-editor@latest/dist/jsoneditor.min.js"></script>
        <script src="https://player.twitch.tv/js/embed/v1.js"></script>
        <script>
          JSONEditor.defaults.theme = 'spectre'; JSONEditor.defaults.iconlib =
          'spectre';
        </script>
      </Head>
      <Web3ReactProvider getLibrary={getLibrary}>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </Web3ReactProvider>
    </Fragment>
  );
}

export default MyApp;
