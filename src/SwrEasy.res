type error = {message: string}

let makeError: string => error = message => {message: message}

type deferred<'data> =
  Initial | Pending | Refresh(result<'data, error>) | Replete(result<'data, error>) | Invalid

type mutatorData<'data> =
  | Refresh
  | Overwrite(option<'data> => option<'data>)
  | OverwriteAsync(option<'data> => option<Js.Promise.t<'data>>)
  | Clear

type scopedMutatorKey<'key> = Key('key) | Filter('key => bool)

type scopedMutatorType<'key, 'data> = (scopedMutatorKey<'key>, mutatorData<'data>)

type keyedMutator<'data> = (
  mutatorData<'data>,
  ~revalidate: bool=?,
  ~populateCache: (Obj.t, 'data) => 'data=?,
  ~optimisticData: 'data => 'data=?,
  ~rollbackOnError: Obj.t => bool=?,
  unit,
) => option<Js.Promise.t<'data>>

type swrResponse<'data> = {
  result: deferred<'data>,
  mutate: keyedMutator<'data>,
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
  | {data: _, error: Some(err), isValidating: true, isLoading: _} =>
    switch err->Js.Exn.message {
    | None => "Unknown JS Error!"
    | Some(err) => err
    }
    ->makeError
    ->Error
    ->Refresh
  | {data: Some(data), error: None, isValidating: false, isLoading: false} => Replete(Ok(data))
  | {data: None, error: Some(err), isValidating: false, isLoading: false} =>
    switch err->Js.Exn.message {
    | None => "Unknown JS Error!"
    | Some(err) => err
    }
    ->makeError
    ->Error
    ->Replete
  | {data: _, error: _, isValidating: _, isLoading: _} => Invalid
  }

  let mutate = (
    type': mutatorData<'data>,
    ~revalidate: option<bool>=?,
    ~populateCache: option<(Obj.t, 'data) => 'data>=?,
    ~optimisticData: option<'data => 'data>=?,
    ~rollbackOnError: option<Obj.t => bool>=?,
    (),
  ) => {
    open SwrCommon

    let opts = {
      ?revalidate,
      ?populateCache,
      ?optimisticData,
      ?rollbackOnError,
    }

    switch type' {
    | Refresh => swr.mutate(. Obj.magic, Some(opts))
    | Overwrite(cb) => swr.mutate(. Obj.magic(cb), Some(opts))
    | OverwriteAsync(cb) => swr.mutate(. cb, Some(opts))
    | Clear => swr.mutate(. _ => None, Some(opts))
    }
  }

  {
    result,
    mutate,
  }
}

module SwrConfiguration = {
  include Swr.SwrConfiguration

  let mutate = (
    config,
    key,
    data,
    ~revalidate=?,
    ~populateCache=?,
    ~optimisticData=?,
    ~rollbackOnError=?,
    (),
  ) => {
    open SwrCommon

    let opts = {
      ?revalidate,
      ?populateCache,
      ?optimisticData,
      ?rollbackOnError,
    }

    config->mutateWithOpts_async(
      switch key {
      | Key(key) => #Key(key)
      | Filter(fn) => #Filter(fn)
      },
      switch data {
      | Refresh => Obj.magic
      | Overwrite(fn) =>
        x => {
          switch fn(x) {
          | None => None
          | Some(x) => Obj.magic(x)
          }
        }
      | OverwriteAsync(fn) => fn
      | Clear => _ => None
      },
      Some(opts),
    )
  }
}
