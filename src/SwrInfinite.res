open SwrCommon

type keyLoader<'key, 'data> = (int, Js.nullable<array<'data>>) => 'key

type swrInfiniteResponse<'data> = {
  data: option<array<'data>>,
  error: option<exn>,
  mutate: keyedMutator<array<'data>>,
  isValidating: bool,
  size: int,
  setSize: (. int => int) => Js.Promise.t<option<array<'data>>>,
}

@deriving(abstract)
type rec swrInfiniteConfiguration<'key, 'data> = {
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
      swrInfiniteConfiguration<'key, array<'data>>,
      swrInfiniteResponse<array<'data>>,
    >,
  >,
  @optional isPaused: unit => bool,
  @optional isOnline: unit => bool,
  @optional isVisible: unit => bool,
  @optional onDiscarded: string => unit,
  @optional onLoadingSlow: (string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  @optional
  onSuccess: (array<'data>, string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  @optional onError: (exn, string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  @optional
  onErrorRetry: (
    exn,
    string,
    swrInfiniteConfiguration<'key, array<'data>>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  @optional compare: (option<array<'data>>, option<array<'data>>) => bool,
  /* infinite hook-specific options */
  @optional initialSize: int,
  @optional revalidateAll: bool,
  @optional persistSize: bool,
  @optional revalidateFirstPage: bool,
}

@val @module("swr/infinite")
external useSWRInfinite: (
  keyLoader<'arg, 'data>,
  fetcher1<'arg, 'data>,
) => swrInfiniteResponse<'data> = "default"

@val @module("swr/infinite")
external useSWRInfinite_config: (
  keyLoader<'arg, 'data>,
  fetcher1<'arg, 'data>,
  swrInfiniteConfiguration<'key, 'data>,
) => swrInfiniteResponse<'data> = "default"

@ocaml.doc(`[setConfigProperty] is used to unsafely set a configuration property.`) @set_index
external setConfigProperty: (swrInfiniteConfiguration<'key, 'data>, string, 'val) => unit = ""
