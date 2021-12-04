# rescript-swr
Low-cost ReScript bindings to [SWR](https://github.com/vercel/swr).
Supports version ^1.0.0. Also includes bindings for `useSWRInfinite`.

## Installation
Run
```
npm install rescript-swr swr
```
then update the `bs-dependencies` key in your `bsconfig.json` file to include "`rescript-swr`".

## Examples
```rescript
@react.component
let make = () => {
  let config = Swr.swrConfiguration(
    ~refreshInterval=10000,
    ~loadingTimeout=3000,
    ~fallbackData={cats: 0, dogs: 0, hamsters: 0},
    ~onLoadingSlow=(_, _) => {
      Js.log("This is taking too long")
    },
    ~onErrorRetry=(_error, _key, _config, revalidate, {retryCount}) => {
      // Retry after 5 seconds.
      Js.Global.setTimeout(
        () => revalidate(. {retryCount: retryCount, dedupe: None})->ignore,
        5000,
      )->ignore
    },
    ~use=[
      // logger middleware
      (useSWRNext, . key, fetcher, config) => {
        let extendedFetcher = args => {
          Js.log2("SWR Request: ", key)
          fetcher(args)
        }
        useSWRNext(. key, extendedFetcher, config)
      },
    ],
    (),
  ),

  let {data, error} = Swr.useSWR_string_config(
    "/api/user1/pets",
    fetcher,
    config
  );

  switch (data) {
  | Some(data) => render(data)
  | None => render_loading()
  };
};
```
### Provide global configuration
```rescript
<Swr.SwrConfigProvider
  value={Swr.swrConfiguration(
    ~fallback=Swr.makeFallback({
      "/api/user1/pets": {
        "dogs": 2,
        "cats": 3,
        "hamsters": 1,
      },
      "/api/user2/pets": {
        "dogs": 1,
        "cats": 2,
        "hamsters": 0,
      },
    }),
    (),
  )}>
  <children />
</Swr.SwrConfigProvider>
```
### Obtain global configuration
```rescript
open Swr

// return all global configurations
let globalConfig = SwrConfiguration.useSWRConfig()
// access configuration property using auto-generated getter
let refreshInterval = globalConfig->Swr.refreshIntervalGet
Js.log(refreshInterval)

// broadcast a revalidation message globally to other SWR hooks
globalConfig->SwrConfiguration.mutate_key("/api/user1/pets")

// update the local data immediately, but disable the revalidation
globalConfig->SwrConfiguration.mutate("/api/user1/pets", {dogs: 2, hamsters: 5, cats: 10}, false)
```

## Documentation
See [DOCUMENTATION.md](https://github.com/arafatamim/rescript-swr/blob/main/DOCUMENTATION.md).

## Credits
Originally forked from https://github.com/roddyyaga/bs-swr.

## License
MIT Licensed. See [LICENSE](https://github.com/arafatamim/rescript-swr/blob/main/LICENSE) file.

## Addendum
### The above examples written in ML syntax
```ml
let config : (string, pets, Js.Promise.error) swrConfiguration =
  swrConfiguration ~refreshInterval:10000 ~loadingTimeout:3000
    ~fallbackData:{ cats = 0; dogs = 0; hamsters = 0 }
    ~onLoadingSlow:(fun _ _ -> Js.log "Taking too long")
    ~onErrorRetry:(fun _err _key _conf revalidate { retryCount } ->
      Js.Global.setTimeout
        (fun _ -> (revalidate { retryCount; dedupe = None } [@bs]) |> ignore)
        5000
      |> ignore)
    ~use:
      [|
        (fun useSWRNext ->
          fun [@bs] key fetcher config ->
           let extendedFetcher args =
             Js.log2 "SWR Request: " key;
             fetcher args
           in
           (useSWRNext key extendedFetcher config [@bs]));
      |]
    ()

let { data } =
  useSWR_config "/api/user1/pets"
    (fun _key -> Js.Promise.resolve { cats = 2; dogs = 4; hamsters = 2 })
    config

(************)

let globalConfig : (string, pets, Js.Promise.error) swrConfiguration =
  SwrConfiguration.useSWRConfig ()
let refreshInterval = globalConfig |. refreshIntervalGet;;
Js.log refreshInterval;;

(************)

globalConfig |. SwrConfiguration.mutate_key "/api/user1/pets";;
globalConfig
|. SwrConfiguration.mutate "/api/user1/pets"
     { dogs = 2; hamsters = 5; cats = 10 }
     false
```
