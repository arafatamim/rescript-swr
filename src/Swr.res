open SwrCommon

type swrResponse<'data> = {
  data: option<'data>,
  error: option<exn>,
  mutate: keyedMutator<'data>,
  isValidating: bool,
}

@deriving(abstract)
type rec swrConfiguration<'key, 'data> = {
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
  use: array<middleware<'key, 'data, swrConfiguration<'key, 'data>, swrResponse<'data>>>,
  @optional isPaused: unit => bool,
  @optional isOnline: unit => bool,
  @optional isVisible: unit => bool,
  @optional onDiscarded: string => unit,
  @optional onLoadingSlow: (string, swrConfiguration<'key, 'data>) => unit,
  @optional onSuccess: ('data, string, swrConfiguration<'key, 'data>) => unit,
  @optional onError: (exn, string, swrConfiguration<'key, 'data>) => unit,
  @optional
  onErrorRetry: (
    exn,
    string,
    swrConfiguration<'key, 'data>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  @optional compare: (option<'data>, option<'data>) => bool,
}

type cache<'data> = {
  get: (. string) => Js.Nullable.t<'data>,
  set: (. string, 'data) => unit,
  delete: (. string) => unit,
}

@val @module("swr")
external useSWR: ('arg, fetcher1<'arg, 'data>) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR_config: (
  'arg,
  fetcher1<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR_string: (string, fetcher1<string, 'data>) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR_string_config: (
  string,
  fetcher1<string, 'data>,
  swrConfiguration<string, 'data>,
) => swrResponse<'data> = "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1: (array<'arg>, fetcher1<'arg, 'data>) => swrResponse<'data> = "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1_config: (
  array<'arg>,
  fetcher1<'arg, 'data>,
  swrConfiguration<array<'arg>, 'data>,
) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR2: (('arg1, 'arg2), fetcher2<'arg1, 'arg2, 'data>) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR2_config: (
  ('arg1, 'arg2),
  fetcher2<'arg1, 'arg2, 'data>,
  swrConfiguration<('arg1, 'arg2), 'data>,
) => swrResponse<'data> = "default"

module SwrConfigProvider = {
  @module("swr") @react.component
  external make: (
    ~value: swrConfiguration<'key, 'data>,
    ~children: React.element,
  ) => React.element = "SWRConfig"

  @ocaml.doc("[setCacheProvider] sets the ``provider`` property on configuration object") @set
  external setCacheProvider: (swrConfiguration<'key, 'data>, cache<'data> => cache<'data>) => unit =
    "provider"
}

module SwrConfiguration = {
  @send
  @ocaml.doc(`[mutate_key: (config, key)] broadcasts a revalidation message globally to other SWR hooks`)
  external mutate_key: (swrConfiguration<'key, 'data>, 'key) => unit = "mutate"

  @send
  @ocaml.doc(`[mutate: (config, key, data, shouldRevalidate)] is used to update local data programmatically, while revalidating and finally replacing it with the latest data.`)
  external mutate: (swrConfiguration<'key, 'data>, 'key, 'data, bool) => unit = "mutate"

  @get
  external cache: swrConfiguration<'key, 'data> => cache<'data> = "cache"

  @module("swr")
  @ocaml.doc(`[useSWRConfig] returns the global configuration, as well as mutate and cache options.`)
  external useSWRConfig: unit => swrConfiguration<'key, 'data> = "useSWRConfig"
}

@ocaml.doc(`[setConfigProperty] is used to unsafely set a configuration property.`) @set_index
external setConfigProperty: (swrConfiguration<'key, 'data>, string, 'val) => unit = ""

@ocaml.doc(`[getConfigProperty] is used to unsafely get a configuration property.`) @get_index
external getConfigProperty: (swrConfiguration<'key, 'data>, string) => 'val = ""

@module("swr/immutable")
external useSWRImmutable: (
  'arg,
  fetcher1<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

module Infinite = SwrInfinite
module Common = SwrCommon
