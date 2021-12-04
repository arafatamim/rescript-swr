open Common

type swrResponse<'data, 'error> = {
  data: option<'data>,
  error: 'error,
  mutate: keyedMutator<'data>,
  isValidating: bool,
}

@deriving(abstract)
type rec swrConfiguration<'key, 'data, 'error> = {
  /* Global options */
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

@val @module("swr")
external useSWR: ('arg, fetcher1<'arg, 'data>) => swrResponse<'data, 'error> = "default"

@val @module("swr")
external useSWR_config: (
  'arg,
  fetcher1<'arg, 'data>,
  swrConfiguration<'arg, 'data, 'error>,
) => swrResponse<'data, 'error> = "default"

@val @module("swr")
external useSWR_string: (string, fetcher1<string, 'data>) => swrResponse<'data, 'error> = "default"

@val @module("swr")
external useSWR_string_config: (
  string,
  fetcher1<string, 'data>,
  swrConfiguration<string, 'data, 'error>,
) => swrResponse<'data, 'error> = "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1: (array<'arg>, fetcher1<'arg, 'data>) => swrResponse<'data, 'error> = "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1_config: (
  array<'arg>,
  fetcher1<'arg, 'data>,
  swrConfiguration<array<'arg>, 'data, 'error>,
) => swrResponse<'data, 'error> = "default"

@val @module("swr")
external useSWR2: (('arg1, 'arg2), fetcher2<'arg1, 'arg2, 'data>) => swrResponse<'data, 'error> =
  "default"

@val @module("swr")
external useSWR2_config: (
  ('arg1, 'arg2),
  fetcher2<'arg1, 'arg2, 'data>,
  swrConfiguration<('arg1, 'arg2), 'data, 'error>,
) => swrResponse<'data, 'error> = "default"

@val @module("swr")
external mutate1_one_item_array: array<'arg> => Js.Promise.t<option<'data>> = "mutate"

@val @module("swr")
external mutate2_one_item_array_fetcher: (
  array<'arg>,
  fetcher1<'arg, 'data>,
) => Js.Promise.t<option<'data>> = "mutate"

module SwrConfigProvider = {
  @module("swr") @react.component
  external make: (
    ~value: swrConfiguration<'key, 'data, 'error>,
    ~children: React.element,
  ) => React.element = "SWRConfig"
}

module SwrConfiguration = {
  @send
  @ocaml.doc(`[mutate_key: (config, key)] broadcasts a revalidation message globally to other SWR hooks`)
  external mutate_key: (swrConfiguration<'key, 'data, 'error>, 'key) => unit = "mutate"

  @send
  @ocaml.doc(`[mutate: (config, key, data, shouldRevalidate)] is used to update local data programmatically, while revalidating and finally replacing it with the latest data.`)
  external mutate: (swrConfiguration<'key, 'data, 'error>, 'key, 'data, bool) => unit = "mutate"

  @module("swr")
  @ocaml.doc(`[useSWRConfig] returns the global configuration, as well as mutate and cache`)
  external useSWRConfig: unit => swrConfiguration<'key, 'data, 'error> = "useSWRConfig"
}

@ocaml.doc(`[makeFallback] is used to create an object to provide global fallback data`)
external makeFallback: {..} => Js.Json.t = "%identity"
