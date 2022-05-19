/*
Examples adapted from https://swr.vercel.app/docs/middleware
*/

open Swr

let logger = (useSWRNext, . key, fetcher, config) => {
  let extendedFetcher = args => {
    Js.log2("SWR Request: ", key)
    fetcher(args)
  }
  useSWRNext(. key, extendedFetcher, config)
}

let config = swrConfiguration(~use=[logger], ())
let swr = useSWR_config("key", Fetch.fetcher, config)
Js.log(swr.data)
