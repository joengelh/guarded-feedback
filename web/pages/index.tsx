
import Image from "next/image";
import { Inter } from "next/font/google";
import { bigIntToString, parseNonStandardJSON } from "../utils/utils";
import { endpoint_api, headers } from "../constants/constants";
import React, {
  useState,
  useEffect,
 
} from "react";
import { Dialog } from '@headlessui/react'
import { Bars3Icon, XMarkIcon } from '@heroicons/react/24/outline'
import { InboxIcon, TrashIcon, UsersIcon, BugAntIcon, ShieldCheckIcon, CurrencyDollarIcon, AdjustmentsHorizontalIcon, DocumentCheckIcon} from '@heroicons/react/24/outline'




const features = [
  {
    name: 'Submitting a Bug report.',
    description:
      'Users can submit a bug report privately. To protect the corporation from spam, bad user behavior or unusable feedback, the user has to attach a small security deposit to the report.',
    href: '#',
    icon: BugAntIcon,
  },
  {
    name: 'Protective fee.',
    description:
      "In order to save the community from being overrun by spam reports, users have to provide a protective fee when submitting that is returned to the user when deemed so by the community. If it's not returned, it can either be burned or shared between the company and the guardians, creating shareholders all throughout the process.",
    href: '#',
    icon: CurrencyDollarIcon,
  },
  {
    name: 'Guardian community.',
    description:
      'The community can now vote privately on the report being useful or not. If deemed useless or simply false, the security deposit is transferred to the corporation.',
    href: '#',
    icon: ShieldCheckIcon,
  },
  {
    name: 'Adjustment',
    description:
      'The corporation can now adjust their product or service according to the bug report. The submitter is given back the security deposit plus whatever the corporation decided to reward the submitter with off chain, due to KYC & AML. The corporation can decide to publish a statement about the problem.',
    href: '#',
    icon: AdjustmentsHorizontalIcon,
  },
  {
    name: 'Claim.',
    description:
      'The Submitter can now claim back his security deposit and reward payment using a ZK proof, being built from a  hash of the address and content. In this way, the user can stay anonymous all throughout the process while submitting feedback and receiving payment.',
    href: '#',
    icon: DocumentCheckIcon,
  },
]


const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  //fetchAndDisplayData();
  const [reports, setReports] = useState(null);

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

  return (
    <>
     <div className="bg-gray-900">
      

      <div className="relative isolate overflow-hidden pt-14">
        <img
          src="https://images.unsplash.com/photo-1521737604893-d14cc237f11d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2830&q=80&blend=111827&sat=-100&exp=15&blend-mode=multiply"
          alt=""
          className="absolute inset-0 -z-10 h-full w-full object-cover"
        />
        <div
          className="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80"
          aria-hidden="true"
        >
          <div
            className="relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-[#ff80b5] to-[#9089fc] opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]"
            style={{
              clipPath:
                'polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)',
            }}
          />
        </div>
        <div className="mx-auto max-w-2xl py-32 sm:py-48 lg:py-56">

          <div className="text-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
            Earn by giving valuable feedback

            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-300">
            Provide feedback and bug reports on the most relevant new products and services you use and would love to get even better



            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <a
                href="/submit"
                className="rounded-md bg-indigo-500 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-400"
              >
                Get started
              </a>
     
            </div>
          </div>
        </div>
        <div
          className="absolute inset-x-0 top-[calc(100%-13rem)] -z-10 transform-gpu overflow-hidden blur-3xl sm:top-[calc(100%-30rem)]"
          aria-hidden="true"
        >
          <div
            className="relative left-[calc(50%+3rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 bg-gradient-to-tr from-[#ff80b5] to-[#9089fc] opacity-20 sm:left-[calc(50%+36rem)] sm:w-[72.1875rem]"
            style={{
              clipPath:
                'polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)',
            }}
          />
        </div>
      </div>
    </div>


    <div className="bg-gray-900 py-24 sm:py-32">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-2xl lg:mx-0">
          <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">Stay on top of customer support</h2>
          <p className="mt-6 text-lg leading-8 text-gray-300">
            Lorem ipsum dolor sit amet consect adipisicing elit. Possimus magnam voluptatum cupiditate veritatis in
            accusamus quisquam.
          </p>
        </div>
        <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
          <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
            {features.map((feature) => (
              <div key={feature.name} className="flex flex-col">
                <dt className="text-base font-semibold leading-7 text-white">
                  <div className="mb-6 flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-500">
                    <feature.icon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  {feature.name}
                </dt>
                <dd className="mt-1 flex flex-auto flex-col text-base leading-7 text-gray-300">
                  <p className="flex-auto">{feature.description}</p>
    
                </dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </div>



      <main
        className={`flex flex-col items-center justify-between p-24 ${inter.className}`}>
          <div>
        <table>
        <tbody className="divide-y divide-gray-200 bg-white">

          <tr>
            <th className="text-black">Counter</th>
            <th className="text-black">Report ID</th>
            <th className="text-black">Submit Block Height</th>
            <th className="text-black">Content</th>
            <th className="text-black">Comment</th>
            <th className="text-black">Rewards</th>
            <th className="text-black">Solved</th>
            <th className="text-black">Claimed</th>
          </tr>
         
          {reports &&
            reports.map((item) => (
              <tr key={item.counter}>
                <td className="text-black">{item.counter}</td>
                <td width={"250px"}><p className="truncate line-clamp-1 text-black">{item.id}</p></td>
                <td className="text-black">{item.block_height}</td>
                <td className="text-black">{bigIntToString(BigInt(item.content.slice(0, -5)))}</td>
                <td className="text-black">{bigIntToString(BigInt(item.comment.slice(0, -5)))}</td>
                <td className="text-black">{item.rewards}</td>
                <td className="text-black">{item.solved}</td>
                <td className="text-black">{item.claimed.toString()}</td>
              </tr>
            ))}
            </tbody>
        </table>
        </div>
      </main>
    </>
  );
}
