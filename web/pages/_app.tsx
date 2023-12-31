

import '@/styles/globals.css'

import React, { FC, useMemo } from "react";


import { WalletProvider } from "@demox-labs/aleo-wallet-adapter-react";
import { WalletModalProvider } from "@demox-labs/aleo-wallet-adapter-reactui";
import { LeoWalletAdapter } from "@demox-labs/aleo-wallet-adapter-leo";
import {
  DecryptPermission,
  WalletAdapterNetwork,
} from "@demox-labs/aleo-wallet-adapter-base";
import Layout  from '../components/layout/Layout'

// Default styles that can be overridden by your app
require("@demox-labs/aleo-wallet-adapter-reactui/styles.css");



export default function App({ Component, pageProps }: AppProps) {


//export const Wallet: FC = ({ Component, pageProps }: AppProps) => {
  const wallets = useMemo(
    () => [
      new LeoWalletAdapter({
        appName: "Guaded Feedback Aleo App",
      }),
    ],
    []
  );

  return (
    <WalletProvider
      wallets={wallets}
      decryptPermission={DecryptPermission.UponRequest}
      network={WalletAdapterNetwork.Localnet}
      autoConnect
    >
      <WalletModalProvider>
      <Layout>
  <Component {...pageProps} />
  
  </Layout>
      </WalletModalProvider>
    </WalletProvider>
  );
};


/*


import '@/styles/globals.css'
import type { AppProps } from 'next/app'
import Layout  from '../components/layout/Layout'

export default function App({ Component, pageProps }: AppProps) {
  return (
<Layout>
  <Component {...pageProps} />
  
  </Layout>
  )
}

*/