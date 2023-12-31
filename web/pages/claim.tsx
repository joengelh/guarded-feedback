import Image from "next/image";
import { Inter } from "next/font/google";
import {
  bigIntToString,
  parseNonStandardJSON,
  generateBadge,
  removeType,
} from "../utils/utils";
import { endpoint_api, headers } from "../constants/constants";
import React, { useState, useEffect, useRef, Fragment } from "react";
import { Dialog, Transition } from "@headlessui/react";
import { ExclamationTriangleIcon } from "@heroicons/react/24/outline";
const inter = Inter({ subsets: ["latin"] });
import { Switch } from "@headlessui/react";

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

import { useWallet } from "@demox-labs/aleo-wallet-adapter-react";

import {
  Transaction,
  WalletAdapterNetwork,
  WalletNotConnectedError,
} from "@demox-labs/aleo-wallet-adapter-base";

export default function Claim() {
  const [open, setOpen] = useState(false);
  const [enabled, setEnabled] = useState(false);

  const cancelButtonRef = useRef(null);
  const [reports, setReports] = useState(null);
  let [transactionId, setTransactionId] = useState<string | undefined>();
  let [status, setStatus] = useState<string | undefined>();
  const getTransactionStatus = async (txId: string) => {
    const status = await transactionStatus(txId);
    if (status == "Finalized") {
      setOpen(false);
    }
    setStatus(status);
  };

  useEffect(() => {
    let intervalId: NodeJS.Timeout | undefined;

    if (transactionId) {
      intervalId = setInterval(() => {
        getTransactionStatus(transactionId!);
      }, 1000);
    }

    return () => {
      if (intervalId) {
        clearInterval(intervalId);
      }
    };
  }, [transactionId]);

  useEffect(() => {
    async function getLoader() {
      const { ripples } = await import("ldrs");
      ripples.register();
    }
    getLoader();
  }, []);

  useEffect(() => {
    async function fetchData() {
      const response = await fetch(
        endpoint_api +
          process.env.NEXT_PUBLIC_PROGRAM_NAME +
          "/mapping/counter/0u8"
      );
      let mappingCounter = await response.text();
      mappingCounter = parseInt(
        mappingCounter.replace(/"/g, "").replace("u128", "")
      ); // Remove double quotes for the counter query
      let reportsData = [];

      for (let i = 1; i <= mappingCounter; i++) {
        const reportEndpoint =
          endpoint_api +
          process.env.NEXT_PUBLIC_PROGRAM_NAME +
          `/mapping/reports/${i}u128`;
        const reportData = await fetch(reportEndpoint, {
          headers,
          method: "GET",
        }).then((response) => {
          if (!response.ok) {
            throw new Error(`Network response for report ${i} was not ok`);
          }
          return response.json(); // Parse the JSON data here
        });
        reportsData.push(parseNonStandardJSON(reportData));
      }
      setReports(reportsData);
    }
    fetchData();
  }, []);

  //const { publicKey, requestTransaction, requestRecords } = useWallet();
  const {
    publicKey,
    requestTransaction,
    requestRecords,
    transactionStatus,
    wallet,
  } = useWallet();

  const onClaim = async (content, reward) => {
    if (!publicKey) throw new WalletNotConnectedError();

    const inputs = [content, reward];


    const fee = 271_596; // This will fail if fee is not set high enough
    const aleoTransaction = Transaction.createTransaction(
      publicKey,
      WalletAdapterNetwork.Testnet,
      process.env.NEXT_PUBLIC_PROGRAM_NAME,
      "claim",
      inputs,
      fee,
      process.env.NEXT_PUBLIC_PRIVATE_FEE
    );

    try {
      if (requestTransaction) {
        // Returns a transaction Id, that can be used to check the status. Note this is not the on-chain transaction id
        const txId = await requestTransaction(aleoTransaction);
        setTransactionId(txId);

        console.log("TX", txId);
      }
    } catch (e: any) {
      console.log(aleoTransaction, "Transaction Failed");
    }
  };

  return (
    <div className="bg-gray-800">
      <div className="bg-white py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0 lg:max-w-none">
            <h1 className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Claim your rewards
            </h1>
            <div className="mt-10 grid max-w-xl grid-cols-1 gap-8 text-base leading-7 text-gray-700 lg:max-w-none lg:grid-cols-2">
              <div>
                <p>
                  In this pivotal function reserved for those who have submitted feedback and recieved a comment on it.
                  Here, product owners engage directly with community members, 
                  making them shareholdes instead of stakeholders.
                </p>
                <p className="mt-8">
                  Instead of processing large payments using traditional, slow or in many parts
                  of the world simply unaccessible means of payment, here cryptocurrency and the ease of
                  transacting with them are leveraged.
                  Uncertainty prevails in conventional setups,
                  leaving users in the dark about the financial incentives offered by the product owners.
                  Guarded Feedback revolutionizes this experience,
                  making it public wich feedback has recieved and claimed a micropayment, without
                  risking the submitters pricacy.
                </p>
              </div>
              <div>
                <p>
                  Submitters' privacy is paramount, and thus, their identities are protected by not being stored on-chain.
                </p>
                <p className="mt-8">
                  To ensure fairness, users are required to claim their rewards independently. 
                  This step enables contributors to receive their well-deserved recognition while preserving their privacy. 
                  By seamlessly integrating blockchain technology, Guarded Feedback ensures a secure, 
                  transparent, and rewarding experience for all participants.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Insert table */}
        <div className="mt-8 flow-root max-w-7xl mx-auto ">
          {transactionId && (
            <div className="text-black flex mr-4">
              {status != "Finalized" && (
                <div className="mt-0.5 mr-2">
                  <l-ripples color="black" size="30"></l-ripples>
                </div>
              )}{" "}
              <div className="mt-1">
                Tx status: <span className="pulsate"> {status}</span>
              </div>
            </div>
          )}

          <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div className="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
              <table className="min-w-full divide-y divide-gray-300">
                <thead>
                  <tr>
                    <th
                      scope="col"
                      className="whitespace-nowrap py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-black sm:pl-0">
                      Counter
                    </th>
                    <th
                      scope="col"
                      className="whitespace-nowrap px-2 py-3.5 text-left text-sm font-semibold text-black">
                      Content
                    </th>
                    <th
                      scope="col"
                      className="whitespace-nowrap px-2 py-3.5 text-left text-sm font-semibold text-black">
                      Comment
                    </th>
                    <th
                      scope="col"
                      className="whitespace-nowrap px-2 py-3.5 text-left text-sm font-semibold text-black">
                      Rewards
                    </th>
                    <th
                      scope="col"
                      className="whitespace-nowrap px-2 py-3.5 text-left text-sm font-semibold text-black">
                      Solved
                    </th>
                    <th
                      scope="col"
                      className="whitespace-nowrap px-2 py-3.5 text-left text-sm font-semibold text-black">
                      Claimed
                    </th>

                    <th
                      scope="col"
                      className="relative whitespace-nowrap py-3.5 pl-3 pr-4 sm:pr-0">
                      <span className="sr-only">Edit</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {reports ? (
                    reports.map((item) => (
                      <tr key={item.counter}>
                        <td className="whitespace-nowrap py-2 pl-4 pr-3 text-sm text-gray-500 sm:pl-0">
                          {removeType(item.counter)}
                        </td>
                        <td className="whitespace-nowrap px-2 py-2 text-sm font-medium text-gray-900">
                          {bigIntToString(BigInt(item.content.slice(0, -5)))}
                        </td>
                        <td className="whitespace-nowrap px-2 py-2 text-sm text-gray-900">
                          {bigIntToString(BigInt(item.comment.slice(0, -5)))}
                        </td>
                        <td className="whitespace-nowrap px-2 py-2 text-sm text-gray-500">
                          {removeType(item.rewards)}
                        </td>
                        <td className="whitespace-nowrap px-2 py-2 text-sm text-gray-500">
                          {generateBadge(item.solved)}
                        </td>
                        <td className="whitespace-nowrap px-2 py-2 text-sm text-gray-500">
                          {generateBadge(item.claimed.toString())}
                        </td>
                        <td className="relative whitespace-nowrap py-2 pl-3 pr-4 text-right text-sm font-medium sm:pr-0">
                          <a
                            href="#"
                            onClick={() => onClaim(item.content, item.rewards)}
                            className="rounded-md bg-black px-2.5 py-1.5 text-sm font-thin text-sm text-white shadow-sm hover:bg-black/20">
                            CLAIM
                            <span className="sr-only">, {item.counter}</span>
                          </a>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr className="p-8">
                      <td colSpan={6}>
                        <div className="flex mx-auto p-8 text-center align-center w-full content-center	">
                          <div className="mt-0.5 pr-2">
                            <l-ripples color="black" size="20"></l-ripples>
                          </div>
                          LOADING
                        </div>
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <main
        className={`flex flex-col items-center justify-between p-24 ${inter.className}`}>
        <Transition.Root show={open} as={Fragment}>
          <form>
            <Dialog
              as="div"
              className="relative z-10"
              initialFocus={cancelButtonRef}
              onClose={setOpen}>
              <Transition.Child
                as={Fragment}
                enter="ease-out duration-300"
                enterFrom="opacity-0"
                enterTo="opacity-100"
                leave="ease-in duration-200"
                leaveFrom="opacity-100"
                leaveTo="opacity-0">
                <div className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
              </Transition.Child>

              <div className="fixed inset-0 z-10 overflow-y-auto">
                <div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                  <Transition.Child
                    as={Fragment}
                    enter="ease-out duration-300"
                    enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    enterTo="opacity-100 translate-y-0 sm:scale-100"
                    leave="ease-in duration-200"
                    leaveFrom="opacity-100 translate-y-0 sm:scale-100"
                    leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95">
                    <Dialog.Panel className="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                      <div className="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
                        <div className="w-full bg-white">
                          <div className="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                            <ExclamationTriangleIcon
                              className="h-6 w-6 text-red-600"
                              aria-hidden="true"
                            />
                          </div>
                          <div className="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                            <Dialog.Title
                              as="h3"
                              className="text-base font-semibold leading-6 text-gray-900">
                              Respond to Feedback
                            </Dialog.Title>
                            <div className="mt-2">
                              <div className="col-span-full">
                                <label
                                  htmlFor="about"
                                  className="block text-sm font-medium leading-6 text-gray-900">
                                  Enter your Comment
                                </label>
                                <div className="mt-2">
                                  <textarea
                                    id="about"
                                    name="about"
                                    rows={3}
                                    className="block w-full rounded-md border-0 bg-white/5 py-1.5 text-white shadow-sm ring-1 ring-inset ring-gray/10 focus:ring-2 focus:ring-inset focus:ring-indigo-500 sm:text-sm sm:leading-6 text-gray-900"
                                    defaultValue={""}
                                    placeholder="enter your comment"
                                  />
                                </div>
                              </div>
                            </div>

                            <div className="col-span-full">
                              <div className="relative">
                                <label
                                  htmlFor="name"
                                  className="absolute -top-2 left-2 inline-block bg-white px-1 text-xs font-medium text-gray-900">
                                  Reward
                                </label>
                                <input
                                  type="text"
                                  name="name"
                                  id="name"
                                  className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                                  placeholder="100"
                                />
                              </div>
                            </div>
                          </div>

                          <Switch
                            checked={enabled}
                            onChange={setEnabled}
                            className={classNames(
                              enabled ? "bg-indigo-600" : "bg-gray-200",
                              "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2"
                            )}>
                            <span className="sr-only">Use setting</span>
                            <span
                              className={classNames(
                                enabled ? "translate-x-5" : "translate-x-0",
                                "pointer-events-none relative inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
                              )}>
                              <span
                                className={classNames(
                                  enabled
                                    ? "opacity-0 duration-100 ease-out"
                                    : "opacity-100 duration-200 ease-in",
                                  "absolute inset-0 flex h-full w-full items-center justify-center transition-opacity"
                                )}
                                aria-hidden="true">
                                <svg
                                  className="h-3 w-3 text-gray-400"
                                  fill="none"
                                  viewBox="0 0 12 12">
                                  <path
                                    d="M4 8l2-2m0 0l2-2M6 6L4 4m2 2l2 2"
                                    stroke="currentColor"
                                    strokeWidth={2}
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                  />
                                </svg>
                              </span>
                              <span
                                className={classNames(
                                  enabled
                                    ? "opacity-100 duration-200 ease-in"
                                    : "opacity-0 duration-100 ease-out",
                                  "absolute inset-0 flex h-full w-full items-center justify-center transition-opacity"
                                )}
                                aria-hidden="true">
                                <svg
                                  className="h-3 w-3 text-indigo-600"
                                  fill="currentColor"
                                  viewBox="0 0 12 12">
                                  <path d="M3.707 5.293a1 1 0 00-1.414 1.414l1.414-1.414zM5 8l-.707.707a1 1 0 001.414 0L5 8zm4.707-3.293a1 1 0 00-1.414-1.414l1.414 1.414zm-7.414 2l2 2 1.414-1.414-2-2-1.414 1.414zm3.414 2l4-4-1.414-1.414-4 4 1.414 1.414z" />
                                </svg>
                              </span>
                            </span>
                          </Switch>
                        </div>
                      </div>
                      <div className="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                        <button
                          type="button"
                          className="inline-flex w-full justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:ml-3 sm:w-auto"
                          onClick={() => onRespond()}>
                          Respond
                        </button>
                        <button
                          type="button"
                          className="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
                          onClick={() => setOpen(false)}
                          ref={cancelButtonRef}>
                          Cancel
                        </button>
                      </div>
                    </Dialog.Panel>
                  </Transition.Child>
                </div>
              </div>
            </Dialog>
          </form>
        </Transition.Root>
      </main>
    </div>
  );
}
