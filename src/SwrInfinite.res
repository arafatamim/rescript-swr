open SwrCommon

type keyLoader<'key, 'any> = (int, option<'any>) => option<'key>

type swrInfiniteResponse<'data> = {
  data: option<array<'data>>,
  error: option<Js.Exn.t>,
  mutate: keyedMutator<array<'data>>,
  isLoading: bool,
  isValidating: bool,
  size: int,
  setSize: (. int => int) => Js.Promise.t<option<array<'data>>>,
}

type rec swrInfiniteConfiguration<'key, 'data> = {
  dedupingInterval?: int,
  errorRetryInterval?: int,
  errorRetryCount?: int,
  fallbackData?: array<'data>,
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
  use?: array<
    middleware<
      'key,
      array<'data>,
      swrInfiniteConfiguration<'key, array<'data>>,
      swrInfiniteResponse<array<'data>>,
    >,
  >,
  isPaused?: unit => bool,
  isOnline?: unit => bool,
  isVisible?: unit => bool,
  onDiscarded?: string => unit,
  onLoadingSlow?: (string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  onSuccess?: (array<'data>, string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  onError?: (Js.Exn.t, string, swrInfiniteConfiguration<'key, array<'data>>) => unit,
  onErrorRetry?: (
    Js.Exn.t,
    string,
    swrInfiniteConfiguration<'key, array<'data>>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  compare?: (option<array<'data>>, option<array<'data>>) => bool,
  /* infinite hook-specific options */
  initialSize?: int,
  revalidateAll?: bool,
  persistSize?: bool,
  revalidateFirstPage?: bool,
}

@val @module("swr/infinite")
external useSWRInfinite: (
  keyLoader<'arg, 'any>,
  fetcher<'arg, 'data>,
) => swrInfiniteResponse<'data> = "default"

@val @module("swr/infinite")
external useSWRInfinite_config: (
  keyLoader<'arg, 'any>,
  fetcher<'arg, 'data>,
  swrInfiniteConfiguration<'key, 'data>,
) => swrInfiniteResponse<'data> = "default"

@ocaml.doc(`[setConfigProperty] is used to unsafely set a configuration property.`) @set_index
external setConfigProperty: (swrInfiniteConfiguration<'key, 'data>, string, 'val) => unit = ""
