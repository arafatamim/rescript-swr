# SwrCommon

## mutatorCallback
```rescript
type mutatorCallback<'data> = option<'data> => Js.Promise.t<'data>
```

## keyedMutator
```rescript
type keyedMutator<'data> = (
  . option<mutatorCallback<'data>>,
  option<bool>,
) => Js.Promise.t<option<'data>>
```

## fetcher
```rescript
type fetcher<'arg, 'data> = array<'arg> => Js.Promise.t<'data>
```

## fetcher1
```rescript
type fetcher1<'arg, 'data> = 'arg => Js.Promise.t<'data>
```

## swrHook
```rescript
type swrHook<'key, 'data, 'error, 'config, 'response> = (
  . 'key,
  fetcher<'key, 'data>,
  'config,
) => 'response
```

## middleware
```rescript
type middleware<'key, 'data, 'error, 'config, 'response> = (
  swrHook<'key, 'data, 'error, 'config, 'response>,
  . 'key,
  fetcher<'key, 'data>,
  'config,
) => 'response
```

## revalidatorOptions
```rescript
type revalidatorOptions = {retryCount: option<int>, dedupe: option<bool>}
```

## revalidateType
```rescript
type revalidateType = (. revalidatorOptions) => Js.Promise.t<option<bool>>
```

# Swr

## swrResponse
```rescript
type swrResponse<'data, 'error> = {
  data: option<'data>,
  error: 'error,
  mutate: keyedMutator<'data>,
  isValidating: bool,
}
```

## swrConfiguration
```rescript
@deriving(abstract)
type rec swrConfiguration<'key, 'data, 'error> = {
  @optional dedupingInterval: int,
  @optional errorRetryInterval: int,
  @optional errorRetryCount: int,
  @optional fallbackData: 'data,
  @optional fallback: Js.Json.t,
  @optional fetcher: fetcher1<'key, 'data>,
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
  @optional
  use: array<
    middleware<
      'key,
      'data,
      'error,
      swrConfiguration<'key, 'data, 'error>,
      swrResponse<'data, 'error>,
    >,
  >,
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
}
```

## useSWR
```rescript
let useSWR: ('arg, fetcher1<'arg, 'data>) => swrResponse<'data, 'error>
```

## useSWR_config
```rescript
let useSWR_config: (
  'arg,
  fetcher1<'arg, 'data>,
  swrConfiguration<'arg, 'data, 'error>,
) => swrResponse<'data, 'error>
```

# Swr.SwrConfigProvider

## make
```rescript
@react.component
let make: (
  ~value: swrConfiguration<'key, 'data, 'error>,
  ~children: React.element,
) => React.element
```

# Swr.SwrConfiguration

## mutate_key
```rescript
let mutate_key: (swrConfiguration<'key, 'data, 'error>, 'key) => unit
```

## mutate
```rescript
let mutate: (swrConfiguration<'key, 'data, 'error>, 'key, 'data, bool) => unit
```

## useSWRConfig
```rescript
let useSWRConfig: unit => swrConfiguration<'key, 'data, 'error>
```

# SwrInfinite

## swrInfiniteResponse
```rescript
type swrInfiniteResponse<'data, 'error> = {
  data: option<array<'data>>,
  error: 'error,
  mutate: keyedMutator<array<'data>>,
  isValidating: bool,
  size: int,
  setSize: (. int => int) => Js.Promise.t<option<array<'data>>>,
}
```

## swrInfiniteConfiguration
```rescript
@deriving(abstract)
type rec swrInfiniteConfiguration<'key, 'data, 'error> = {
  @optional dedupingInterval: int,
  @optional errorRetryInterval: int,
  @optional errorRetryCount: int,
  @optional fallbackData: array<'data>,
  @optional fallback: Js.Json.t,
  @optional fetcher: fetcher1<'key, 'data>,
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
  @optional
  use: array<
    middleware<
      'key,
      array<'data>,
      'error,
      swrInfiniteConfiguration<'key, array<'data>, 'error>,
      swrInfiniteResponse<array<'data>, 'error>,
    >,
  >,
  @optional isPaused: unit => bool,
  @optional isOnline: unit => bool,
  @optional isVisible: unit => bool,
  @optional onDiscarded: string => unit,
  @optional onLoadingSlow: (string, swrInfiniteConfiguration<'key, array<'data>, 'error>) => unit,
  @optional
  onSuccess: (array<'data>, string, swrInfiniteConfiguration<'key, array<'data>, 'error>) => unit,
  @optional onError: ('error, string, swrInfiniteConfiguration<'key, array<'data>, 'error>) => unit,
  @optional
  onErrorRetry: (
    'error,
    string,
    swrInfiniteConfiguration<'key, array<'data>, 'error>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  @optional compare: (option<array<'data>>, option<array<'data>>) => bool,
  /* hook-specific options */
  @optional initialSize: int,
  @optional revalidateAll: bool,
  @optional persistSize: bool,
  @optional revalidateFirstPage: bool,
}
```

## keyLoader
```rescript
type keyLoader<'key, 'data> = (int, Js.nullable<array<'data>>) => 'key
```

## useSWRInfinite
```rescript
let useSWRInfinite: (
  keyLoader<'arg, 'data>,
  fetcher1<'arg, 'data>,
) => swrInfiniteResponse<'data, 'error>
```

## useSWRInfinite_config
```rescript
let useSWRInfinite_config: (
  keyLoader<'arg, 'data>,
  fetcher1<'arg, 'data>,
  swrInfiniteConfiguration<'key, 'data, 'error>,
) => swrInfiniteResponse<'data, 'error>
```
