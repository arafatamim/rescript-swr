/*
Examples adapted from https://swr.vercel.app/docs/middleware
*/

open Swr

let logger = useSWRNext => (key, fetcher, config) => {
  let extendedFetcher = args => {
    Console.log2("SWR Request: ", key)
    fetcher(args)
  }
  useSWRNext(key, extendedFetcher, config)
}

let swr = useSWR_config(
  "key",
  Fetch.fetcher,
  {
    use: [logger],
  },
)
Console.log(swr.data)
