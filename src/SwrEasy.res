type error = {message: string}

let makeError: string => error = message => {message: message}

type deferred<'data> =
  Initial | Pending | Refresh(result<'data, error>) | Replete(result<'data, error>) | Invalid

type mutatorData<'data> =
  | Refresh
  | Overwrite(option<'data> => option<'data>)
  | OverwriteAsync(option<'data> => option<promise<'data>>)
  | Clear

type scopedMutatorKey<'key> = Key('key) | Filter('key => bool)

type scopedMutatorType<'key, 'data> = (scopedMutatorKey<'key>, mutatorData<'data>)

type keyedMutator<'data> = (
  mutatorData<'data>,
  ~revalidate: bool=?,
  ~populateCache: (Obj.t, 'data) => 'data=?,
  ~optimisticData: 'data => 'data=?,
  ~rollbackOnError: Obj.t => bool=?,
  ~throwOnError: bool=?,
) => option<promise<'data>>

type swrResponse<'data> = {
  result: deferred<'data>,
  mutate: keyedMutator<'data>,
}

let useSWR = (
  key: 'key,
  fetcher: SwrCommon.fetcher<'key, 'data>,
  ~config: option<SwrCommon.swrConfiguration<'key, 'data>>=?,
): swrResponse<'data> => {
  let swr = switch config {
  | None => Swr.useSWR(key, fetcher)
  | Some(config) => Swr.useSWR_config(key, fetcher, config)
  }

  let result = switch swr {
  | {data: None, error: None, isValidating: false, isLoading: false} => Initial
  | {data: None, error: None, isValidating: _, isLoading: true} => Pending
  | {data: Some(data), error: None, isValidating: true, isLoading: _} => Refresh(Ok(data))
  | {data: _, error: Some(err), isValidating: true, isLoading: _} =>
    switch err->Exn.message {
    | None => "Unknown JS Error!"
    | Some(err) => err
    }
    ->makeError
    ->Error
    ->Refresh
  | {data: Some(data), error: None, isValidating: false, isLoading: false} => Replete(Ok(data))
  | {data: None, error: Some(err), isValidating: false, isLoading: false} =>
    switch err->Exn.message {
    | None => "Unknown JS Error!"
    | Some(err) => err
    }
    ->makeError
    ->Error
    ->Replete
  | {data: _, error: _, isValidating: _, isLoading: _} => Invalid
  }

  let mutate = (
    mutationType: mutatorData<'data>,
    ~revalidate: option<bool>=?,
    ~populateCache: option<(Obj.t, 'data) => 'data>=?,
    ~optimisticData: option<'data => 'data>=?,
    ~rollbackOnError: option<Obj.t => bool>=?,
    ~throwOnError: option<bool>=?,
  ) => {
    // this function exists solely to address a quirk in SWR (and by extension JS)
    // where mutations do not work if configuration properties are explicitly set to undefined.
    let makeOpts = (obj: {..}) => {
      switch revalidate {
      | Some(val) => obj->Object.set("revalidate", val)
      | _ => ()
      }
      switch populateCache {
      | Some(val) => obj->Object.set("populateCache", val)
      | _ => ()
      }
      switch optimisticData {
      | Some(val) => obj->Object.set("optimisticData", val)
      | _ => ()
      }
      switch rollbackOnError {
      | Some(val) => obj->Object.set("rollbackOnError", val)
      | _ => ()
      }
      switch throwOnError {
      | Some(val) => obj->Object.set("throwOnError", val)
      | _ => ()
      }
      obj
    }

    let opts = makeOpts(Object.make())->Obj.magic // fooling the type system into accepting the opts object

    switch mutationType {
    | Refresh => swr.mutate(Obj.magic(), opts)
    | Overwrite(cb) => swr.mutate(Obj.magic(cb), opts)
    | OverwriteAsync(cb) => swr.mutate(cb, opts)
    | Clear => swr.mutate(_ => None, opts)
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
    ~throwOnError=?,
  ) => {
    open SwrCommon

    let opts = {
      ?revalidate,
      ?populateCache,
      ?optimisticData,
      ?rollbackOnError,
      ?throwOnError,
    }

    config->mutateWithOpts_async(
      switch key {
      | Key(key) => #Key(key)
      | Filter(fn) => #Filter(fn)
      },
      switch data {
      | Refresh => Obj.magic()
      | Overwrite(fn) =>
        x => {
          switch fn(x) {
          | None => None
          | Some(x) => Obj.magic(x)
          }
        }
      | OverwriteAsync(fn) => fn
      | Clear => {
          Js.log("clear")
          _ => None
        }
      },
      Some(opts),
    )
  }
}
