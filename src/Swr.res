module Options = Swr_Options
module Raw = Swr_Raw

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

let wrap_raw_response_intf = x =>
  switch x {
  | {Raw.data: data, error, revalidate, mutate, isValidating} =>
    let wrapped_mutate = (~data=?, ~shouldRevalidate=?, ()) => mutate(data, shouldRevalidate)

    {
      data: data,
      error: error,
      revalidate: revalidate,
      isValidating: isValidating,
      mutate: wrapped_mutate,
    }
  }

let useSWR = (
  ~config=?,
  ~initialData=?,
  ~onLoadingSlow=?,
  ~onSuccess=?,
  ~onError=?,
  ~onErrorRetry=?,
  ~compare=?,
  x,
  f,
) =>
  switch config {
  | None => Raw.useSWR1([x], f)->wrap_raw_response_intf
  | Some(config) =>
    let raw_config = Options.to_configInterface(
      config,
      ~initialData?,
      ~onLoadingSlow?,
      ~onSuccess?,
      ~onError?,
      ~onErrorRetry?,
      ~compare?,
    )
    Raw.useSWR1_config([x], f, raw_config)->wrap_raw_response_intf
  }

let mutate = (~f=?, key) =>
  switch f {
  | Some(f) => Raw.mutate2_one_item_array_fetcher([key], f)
  | None => Raw.mutate1_one_item_array([key])
  }

module SwrConfig = {
  @react.component
  let make = (
    ~initialData=?,
    ~onLoadingSlow=?,
    ~onSuccess=?,
    ~onError=?,
    ~onErrorRetry=?,
    ~compare=?,
    ~config: Swr_Options.t,
    ~children: React.element,
  ) =>
    <Swr_Raw.SwrConfigRaw
      value={Swr_Options.to_configInterface(
        ~initialData?,
        ~onLoadingSlow?,
        ~onSuccess?,
        ~onError?,
        ~onErrorRetry?,
        ~compare?,
        config,
      )}>
      {children}
    </Swr_Raw.SwrConfigRaw>
}
