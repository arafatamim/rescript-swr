type deferred<'data> =
  Initial | Pending | Refresh(result<'data, exn>) | Replete(result<'data, exn>) | Invalid

type mutator<'data> = (
  ~data: SwrCommon.mutatorCallback<'data>=?,
  ~opts: SwrCommon.mutatorOptions<'data>=?,
  unit,
) => Js.Promise.t<option<'data>>

type swrResponse<'data> = {
  result: deferred<'data>,
  mutate: mutator<'data>,
}

let useSWR = (
  ~config: option<Swr.swrConfiguration<'key, 'data>>=?,
  key: 'key,
  fetcher: SwrCommon.fetcher<'key, 'data>,
) => {
  let swr = switch config {
  | None => Swr.useSWR(key, fetcher)
  | Some(config) => Swr.useSWR_config(key, fetcher, config)
  }

  let result = switch swr {
  | {data: None, error: None, isValidating: false, isLoading: false} => Initial
  | {data: None, error: None, isValidating: _, isLoading: true} => Pending
  | {data: Some(data), error: None, isValidating: true, isLoading: _} => Refresh(Ok(data))
  | {data: _, error: Some(err), isValidating: true, isLoading: _} => Refresh(Error(err))
  | {data: Some(data), error: None, isValidating: false, isLoading: false} => Replete(Ok(data))
  | {data: None, error: Some(error), isValidating: false, isLoading: false} => Replete(Error(error))
  | {data: _, error: _, isValidating: _, isLoading: _} => Invalid
  }

  let mutate = (
    ~data: option<SwrCommon.mutatorCallback<'data>>=?,
    ~opts: option<SwrCommon.mutatorOptions<'data>>=?,
    (),
  ) => {
    switch (data, opts) {
    | (Some(data), None) => swr.mutate(. Some(data), None)
    | (None, Some(opts)) => swr.mutate(. None, Some(opts))
    | (Some(data), Some(opts)) => swr.mutate(. Some(data), Some(opts))
    | (None, None) => swr.mutate(. Some(data => Obj.magic(data)), None)
    }
  }

  {
    result: result,
    mutate: mutate,
  }
}
