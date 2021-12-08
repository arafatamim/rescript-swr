/*
Examples adapted from https://swr.vercel.app/docs/middleware
*/

open Swr

@scope("Object") @val
external assign: ('a, 'b, 'c) => swrResponse<'data> = "assign"

let logger = (useSWRNext, . key, fetcher, config) => {
  let extendedFetcher = args => {
    Js.log2("SWR Request: ", key)
    fetcher(args)
  }
  useSWRNext(. key, extendedFetcher, config)
}

let config = swrConfiguration(~use=[
  logger,
], ())
let {data} = useSWR_config("key", Fetch.fetcher, config)
Js.log(data)
