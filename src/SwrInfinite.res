open Common

type keyLoader<'key, 'data> = (int, Js.nullable<array<'data>>) => 'key

type swrInfiniteResponse<'data, 'error> = {
  data: option<array<'data>>,
  error: 'error,
  mutate: keyedMutator<array<'data>>,
  isValidating: bool,
  size: int,
  setSize: (. int => int) => Js.Promise.t<option<array<'data>>>,
}

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
) => swrInfiniteResponse<'data, 'error> = "default"

@val @module("swr/infinite")
external useSWRInfinite_config: (
  keyLoader<'arg, 'data>,
  fetcher1<'arg, 'data>,
  swrInfiniteConfiguration<'key, 'data, 'error>,
) => swrInfiniteResponse<'data, 'error> = "default"
