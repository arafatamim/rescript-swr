type bound_mutate<'data> = (option<'data>, option<bool>) => Js.Promise.t<option<'data>>

type responseInterface<'data> = {
  data: option<'data>,
  error: Js.Promise.error,
  revalidate: unit => Js.Promise.t<bool>,
  mutate: bound_mutate<'data>,
  isValidating: bool,
}

type revalidateOptionInterface = {retryCount: option<int>, dedupe: option<bool>}

type revalidateType = revalidateOptionInterface => Js.Promise.t<bool>

// @val @module("fast-deep-equal/es6") external fast_deep_equal: ('a, 'a) => bool = "default"

@deriving(abstract)
type rec configInterface<'key, 'data> = {
  /* Global options */
  @optional errorRetryInterval: int,
  @optional errorRetryCount: int,
  @optional loadingTimeout: int,
  @optional focusThrottleInterval: int,
  @optional dedupingInterval: int,
  @optional refreshInterval: int,
  @optional refreshWhenHidden: bool,
  @optional refreshWhenOffline: bool,
  @optional revalidateOnFocus: bool,
  @optional revalidateOnMount: bool,
  @optional revalidateOnReconnect: bool,
  @optional shouldRetryOnError: bool,
  @optional suspense: bool,
  @optional initialData: 'data,
  @optional onLoadingSlow: ('key, configInterface<'key, 'data>) => unit,
  @optional onSuccess: ('data, 'key, configInterface<'key, 'data>) => unit,
  @optional onError: (Js.Promise.error, 'key, configInterface<'key, 'data>) => unit,
  @optional
  onErrorRetry: (
    Js.Promise.error,
    'key,
    configInterface<'key, 'data>,
    revalidateType,
    revalidateOptionInterface,
  ) => unit,
  @optional compare: (option<'data>, option<'data>) => bool,
}

@val @module("swr")
external useSWR_string: (string, string => Js.Promise.t<'data>) => responseInterface<'data> =
  "default"

@val @module("swr")
external useSWR_string_config: (
  string,
  string => Js.Promise.t<'data>,
  configInterface<string, 'data>,
) => responseInterface<'data> = "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1: (array<'param>, 'param => Js.Promise.t<'data>) => responseInterface<'data> =
  "default"

/* array must be of length 1 */
@val @module("swr")
external useSWR1_config: (
  array<'param>,
  'param => Js.Promise.t<'data>,
  configInterface<array<'param>, 'data>,
) => responseInterface<'data> = "default"

@val @module("swr")
external useSWR2: (('a, 'b), ('a, 'b) => Js.Promise.t<'data>) => responseInterface<'data> =
  "default"

@val @module("swr")
external useSWR2_config: (
  ('a, 'b),
  ('a, 'b) => Js.Promise.t<'data>,
  configInterface<('a, 'b), 'data>,
) => responseInterface<'data> = "default"

@val @module("swr")
external mutate1_one_item_array: array<'param> => Js.Promise.t<option<'data>> = "mutate"

@val @module("swr")
external mutate2_one_item_array_fetcher: (
  array<'param>,
  'param => Js.Promise.t<'data>,
) => Js.Promise.t<option<'data>> = "mutate"

@val @module("swr")
external mutate2_shouldRevalidate: ('key, bool) => Js.Promise.t<option<'data>> = "mutate"

module SwrConfigRaw = {
  @module("swr") @react.component
  external make: (~value: configInterface<'key, 'data>, ~children: React.element) => React.element =
    "SWRConfig"
}
