module Options: {
  type t = SwrOptions.t = {
    errorRetryInterval: option<int>,
    errorRetryCount: option<int>,
    loadingTimeout: option<int>,
    focusThrottleInterval: option<int>,
    dedupingInterval: option<int>,
    refreshInterval: option<int>,
    refreshWhenHidden: option<bool>,
    refreshWhenOffline: option<bool>,
    revalidateOnFocus: option<bool>,
    revalidateOnMount: option<bool>,
    revalidateOnReconnect: option<bool>,
    shouldRetryOnError: option<bool>,
    suspense: option<bool>,
  }

  let make: (
    ~suspense: bool=?,
    ~revalidateOnFocus: bool=?,
    ~revalidateOnReconnect: bool=?,
    ~revalidateOnMount: bool=?,
    ~refreshInterval: int=?,
    ~refreshWhenHidden: bool=?,
    ~refreshWhenOffline: bool=?,
    ~shouldRetryOnError: bool=?,
    ~dedupingInterval: int=?,
    ~focusThrottleInterval: int=?,
    ~loadingTimeout: int=?,
    ~errorRetryInterval: int=?,
    ~errorRetryCount: int=?,
    unit,
  ) => t

  let default: t

  let to_configInterface: (
    ~initialData: 'a=?,
    ~onLoadingSlow: ('b, SwrRaw.configInterface<'b, 'a>) => unit=?,
    ~onSuccess: ('a, 'b, SwrRaw.configInterface<'b, 'a>) => unit=?,
    ~onError: (Js.Promise.error, 'b, SwrRaw.configInterface<'b, 'a>) => unit=?,
    ~onErrorRetry: (
      Js.Promise.error,
      'b,
      SwrRaw.configInterface<'b, 'a>,
      SwrRaw.revalidateType,
      SwrRaw.revalidateOptionInterface,
    ) => unit=?,
    ~compare: (option<'a>, option<'a>) => bool=?,
    t,
  ) => SwrRaw.configInterface<'b, 'a>
}

type bound_mutate<'data> = (
  ~data: 'data=?,
  ~shouldRevalidate: bool=?,
  unit,
) => Js.Promise.t<option<'data>>

type responseInterface<'data> = {
  data: option<'data>,
  error: Js.Promise.error,
  revalidate: unit => Js.Promise.t<bool>,
  mutate: bound_mutate<'data>,
  isValidating: bool,
}

let useSWR: (~config: Options.t=?, 'key, 'key => Js.Promise.t<'data>) => responseInterface<'data>

let useSWR_string: (string, string => Js.Promise.t<'data>) => responseInterface<'data>

let mutate: (~f: 'key => Js.Promise.t<'data>=?, 'key) => Js.Promise.t<option<'data>>
