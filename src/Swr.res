open SwrCommon

type swrResponse<'data> = {
  data: option<'data>,
  error: option<exn>,
  mutate: keyedMutator<'data>,
  isValidating: bool,
  isLoading: bool
}

@deriving(abstract)
type rec swrConfiguration<'key, 'data> = {
  /* Global options */
  @optional dedupingInterval: int,
  @optional errorRetryInterval: int,
  @optional errorRetryCount: int,
  @optional fallbackData: 'data,
  @optional fallback: Obj.t,
  @optional fetcher: fetcher<'key, 'data>,
  @optional focusThrottleInterval: int,
  @optional keepPreviousData: bool,
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

type cacheState<'data> = {
  data: option<'data>,
  error: option<exn>,
  isLoading: bool,
  isValidating: bool,
}

type rec cache<'data> = {
  get: (. string) => Js.Nullable.t<cacheState<'data>>,
  set: (. string, cacheState<'data>) => unit,
  delete: (. string) => bool,
}

@val @module("swr")
external useSWR: ('arg, fetcher<'arg, 'data>) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR_config: (
  'arg,
  fetcher<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
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
  external mutate_key: (swrConfiguration<'key, 'data>, 'key) => Js.Promise.t<Obj.t> = "mutate"

  @send
  @ocaml.doc(`[mutate_key_data: (config, key, data)] broadcasts a revalidation message globally to other SWR hooks and replacing with latest data`)
  external mutate_key_data: (swrConfiguration<'key, 'data>, 'key, 'data) => Js.Promise.t<Obj.t> = "mutate"

  @send
  @ocaml.doc(`[mutate: (config, key, data, mutatorOptions)] is used to update local data programmatically, while revalidating and finally replacing it with the latest data.`)
  external mutate: (swrConfiguration<'key, 'data>, 'key, 'data, mutatorOptions<'data>) => Js.Promise.t<Obj.t> =
    "mutate"

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
  fetcher<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

module Infinite = SwrInfinite
module Common = SwrCommon
