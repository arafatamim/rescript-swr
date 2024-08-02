type fetcher<'arg, 'data> = 'arg => promise<'data>
type fetcher_sync<'arg, 'data> = 'arg => 'data

type swrHook<'key, 'data, 'config, 'response> = ('key, fetcher<'key, 'data>, 'config) => 'response

type middleware<'key, 'data, 'config, 'response> = swrHook<'key, 'data, 'config, 'response> => (
  'key,
  fetcher<'key, 'data>,
  'config,
) => 'response

type revalidatorOptions = {retryCount?: int, dedupe?: bool}

type revalidateType = revalidatorOptions => promise<option<bool>>

type mutatorCallback<'data> = option<'data> => option<promise<'data>>

type mutatorOptions<'data> = {
  revalidate?: bool,
  populateCache?: (Obj.t, 'data) => 'data,
  optimisticData?: 'data => 'data,
  rollbackOnError?: Obj.t => bool,
  throwOnError?: bool,
}

type keyedMutator<'data> = (
  mutatorCallback<'data>,
  option<mutatorOptions<'data>>,
) => option<promise<'data>>

type swrResponse<'data> = {
  data: option<'data>,
  error: option<Exn.t>,
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
  onError?: (Exn.t, string, swrConfiguration<'key, 'data>) => unit,
  onErrorRetry?: (
    Exn.t,
    string,
    swrConfiguration<'key, 'data>,
    revalidateType,
    revalidatorOptions,
  ) => unit,
  compare?: (option<'data>, option<'data>) => bool,
}

