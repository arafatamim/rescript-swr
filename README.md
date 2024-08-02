# rescript-swr
[![npm](https://img.shields.io/npm/v/rescript-swr)](https://www.npmjs.com/package/rescript-swr)
![npm](https://img.shields.io/npm/dm/rescript-swr?color=blue)

Low-overhead [ReScript](https://rescript-lang.org) bindings to [SWR](https://github.com/vercel/swr).
Supports version >=2.0.0 & <=3.0.0. Compatible with ReScript v11 and onwards.

Includes experimental module `SwrEasy` that has a layer of abstraction
designed for a smoother developer experience, with the tradeoff being a slightly higher runtime cost.

## Installation
Run
```
npm install rescript-swr swr
```
then update the `bs-dependencies` key in your `rescript.json` file to include "`rescript-swr`".

## Examples
```rescript
@react.component
let make = () => {
  let config = {
    refreshInterval: 10000,
    loadingTimeout: 3000,
    fallbackData: {cats: 0, dogs: 0, hamsters: 0},
    onLoadingSlow: (_, _) => {
      Console.log("This is taking too long")
    },
    onErrorRetry: (_error, _key, _config, revalidate, {?retryCount}) => {
      // Retry after 5 seconds.
      setTimeout(
        () => revalidate({?retryCount})->ignore,
        5000,
      )->ignore
    },
    use: [
      // logger middleware
      (useSWRNext) => (key, fetcher, config) => {
        let extendedFetcher = args => {
          Console.log2("SWR Request: ", key)
          fetcher(args)
        }
        useSWRNext(key, extendedFetcher, config)
      },
    ],
  }

  let {data, error} = Swr.useSWR_config(
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
  value={config => {
    fallback: Obj.magic({
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
    })
   }}>
  <children />
</Swr.SwrConfigProvider>
```
### Obtain global configuration
```rescript
open Swr

// return all global configurations
let globalConfig = SwrConfiguration.useSWRConfig()
// access configuration property using auto-generated getter
let refreshInterval = globalConfig.refreshInterval
Js.log(refreshInterval)

// broadcast a revalidation message globally to other SWR hooks
globalConfig->SwrConfiguration.mutateKey(#Key("/api/user1/pets"))

// update the local data immediately, but disable the revalidation
globalConfig->SwrConfiguration.mutateWithOpts(#Key("/api/user1/pets"), _ => Js.Promise.resolve({dogs: 2, hamsters: 5, cats: 10})->Some, { revalidate: false })
```

## Documentation
See [DOCUMENTATION.md](https://github.com/arafatamim/rescript-swr/blob/main/DOCUMENTATION.md).

## Credits
Originally forked from https://github.com/roddyyaga/bs-swr.

## License
MIT Licensed. See [LICENSE](https://github.com/arafatamim/rescript-swr/blob/main/LICENSE) file.

