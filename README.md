# rescript-swr
Nearly low-cost ReScript bindings to [SWR](https://github.com/vercel/swr).
Supports version ^1.0.0.

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

## API
### `Swr.swrConfiguration<'key, 'data, 'error>`
```rescript
@optional dedupingInterval: int,
@optional errorRetryInterval: int,
@optional errorRetryCount: int,
@optional fallbackData: 'data,
@optional fallback: Js.Json.t,
@optional fetcher: fetcher<'key, 'data>,
@optional focusThrottleInterval: int,
@optional loadingTimeout: int,
@optional refreshInterval: int,
@optional refreshWhenHidden: bool,
@optional refreshWhenOffline: bool,
@optional revalidateOnFocus: bool,
@optional revalidateOnMount: bool,
@optional revalidateOnReconnect: bool,
@optional revalidateIfStale: bool,
@optional shouldRetryOnError: bool,
@optional suspense: bool,
@optional use: array<middleware<'key, 'data, 'error, swrConfiguration<'key, 'data, 'error>>>,
@optional isPaused: unit => bool,
@optional isOnline: unit => bool,
@optional isVisible: unit => bool,
@optional onDiscarded: string => unit,
@optional onLoadingSlow: (string, swrConfiguration<'key, 'data, 'error>) => unit,
@optional onSuccess: ('data, string, swrConfiguration<'key, 'data, 'error>) => unit,
@optional onError: ('error, string, swrConfiguration<'key, 'data, 'error>) => unit,
@optional
onErrorRetry: (
  'error,
  string,
  swrConfiguration<'key, 'data, 'error>,
  revalidateType,
  revalidatorOptions,
) => unit,
@optional compare: (option<'data>, option<'data>) => bool,
```

### `Swr.fetcher`
```rescript
type fetcher1<'arg, 'data> = 'arg => Js.Promise.t<'data>
type fetcher2<'arg1, 'arg2, 'data> = ('arg1, 'arg2) => Js.Promise.t<'data>
```

### `Swr.useSWR`
```rescript
useSWR: (
  'key,
  fetcher1<'key, 'data>,
) => responseInterface<'data, 'error>

useSWR_config: (
  'key,
  fetcher1<'key, 'data>,
  swrConfiguration<string, 'data, 'error>,
) => responseInterface<'data, 'error>

// Look into the source code for more overloads,
// or create them yourself as required
```

## Credits
Originally forked from https://github.com/roddyyaga/bs-swr

## Addendum
### The above examples rewritten in ML syntax
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