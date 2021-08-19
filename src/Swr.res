module Options = SwrOptions
module Raw = SwrRaw

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

let useSWR = (~config=?, x, f) =>
  switch config {
  | None => Raw.useSWR1([x], f) |> wrap_raw_response_intf
  | Some(config) =>
    let raw_config = Options.to_configInterface(config)
    Raw.useSWR1_config([x], f, raw_config) |> wrap_raw_response_intf
  }

let useSWR_string = (x, f) => Raw.useSWR_string(x, f) |> wrap_raw_response_intf

let mutate = (~f=?, key) =>
  switch f {
  | Some(f) => Raw.mutate2_one_item_array_fetcher([key], f)
  | None => Raw.mutate1_one_item_array([key])
  }
