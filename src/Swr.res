open SwrCommon

type swrResponse<'data> = {
  data: option<'data>,
  error: option<Js.Exn.t>,
  mutate: keyedMutator<'data>,
  isValidating: bool,
  isLoading: bool,
}

type rec swrConfiguration<'key, 'data> = {
  /* Global options */
  dedupingInterval?: int,
  errorRetryInterval?: int,
  errorRetryCount?: int,
  fallbackData?: 'data,
  fallback?: Obj.t,
  fetcher?: fetcher<'key, 'data>,
  focusThrottleInterval?: int,
  keepPreviousData?: bool,
  loadingTimeout?: int,
  refreshInterval?: int,
  refreshWhenHidden?: bool,
  refreshWhenOffline?: bool,
  revalidateOnFocus?: bool,
  revalidateOnMount?: bool,
  revalidateOnReconnect?: bool,
  revalidateIfStale?: bool,
  shouldRetryOnError?: bool,
  suspense?: bool,
  use?: array<middleware<'key, 'data, swrConfiguration<'key, 'data>, swrResponse<'data>>>,
  isPaused?: unit => bool,
  isOnline?: unit => bool,
  isVisible?: unit => bool,
  onDiscarded?: string => unit,
  onLoadingSlow?: (string, swrConfiguration<'key, 'data>) => unit,
  onSuccess?: ('data, string, swrConfiguration<'key, 'data>) => unit,
  onError?: (Js.Exn.t, string, swrConfiguration<'key, 'data>) => unit,
  onErrorRetry?: (
    Js.Exn.t,
    string,
    swrConfiguration<'key, 'data>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  compare?: (option<'data>, option<'data>) => bool,
}

type cacheState<'data> = {
  data: option<'data>,
  error: option<Js.Exn.t>,
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
    ~value: swrConfiguration<'key, 'data> => swrConfiguration<'key, 'data>,
    ~children: React.element,
  ) => React.element = "SWRConfig"

  @ocaml.doc("[setCacheProvider] sets the ``provider`` property on configuration object") @set
  external setCacheProvider: (swrConfiguration<'key, 'data>, cache<'data> => cache<'data>) => unit =
    "provider"

  @module("swr") @scope("SWRConfig")
  external getDefaultValue: swrConfiguration<'key, 'data> = "defaultValue"
}

module SwrConfiguration = {
  @send
  @ocaml.doc(`[mutateKey: (config, key)] broadcasts a revalidation message globally to other SWR hooks`)
  external mutateKey: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
  ) => Js.Promise.t<'data> = "mutate"

  @send
  @ocaml.doc(`[mutateKeyWithData: (config, key, data)] broadcasts a revalidation message globally to other SWR hooks and replacing with latest data`)
  external mutateKeyWithData: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<Js.Promise.t<'data>>,
  ) => Js.Promise.t<'data> = "mutate"

  @send
  @ocaml.doc(`[mutateWithOpts: (config, key, data, mutatorOptions)] is used to update local data programmatically, while revalidating and finally replacing it with the latest data.`)
  external mutateWithOpts: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<'data>,
    option<mutatorOptions<'data>>,
  ) => Js.Promise.t<'data> = "mutate"

  @send
  @ocaml.doc(`[mutateWithOpts_async: (config, key, data, mutatorOptions)] is the same as mutateWithOpts, except the data callback returns a Js.Promise.t`)
  external mutateWithOpts_async: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<Js.Promise.t<'data>>,
    option<mutatorOptions<'data>>,
  ) => Js.Promise.t<'data> = "mutate"

  @get
  external getCache: swrConfiguration<'key, 'data> => cache<'data> = "cache"

  @module("swr")
  @ocaml.doc(`[useSWRConfig] returns the global configuration, as well as mutate and cache options.`)
  external useSWRConfig: unit => swrConfiguration<'key, 'data> = "useSWRConfig"
}

@ocaml.doc(`[unsafeSetProperty] is used to unsafely set a configuration property.`) @set_index @raises(Js.Exn.t)
external unsafeSetProperty: (swrConfiguration<'key, 'data>, string, 'val) => unit = ""

@ocaml.doc(`[unsafeGetProperty] is used to unsafely retrieve a configuration property.`) @get_index @raises(Js.Exn.t)
external unsafeGetProperty: (swrConfiguration<'key, 'data>, string) => 'val = ""

@module("swr")
external preload: (string, fetcher<'arg, 'data>) => 'a = "preload"

@module("swr") @val
external mutate_key: 'key => unit = "mutate"

@module("swr") @val
external mutate: ('key, 'data, option<mutatorOptions<'data>>) => unit = "mutate"

@module("swr/immutable")
external useSWRImmutable: (
  'arg,
  fetcher<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

module Infinite = SwrInfinite
module Common = SwrCommon
