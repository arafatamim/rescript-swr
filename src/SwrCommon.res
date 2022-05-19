type fetcher<'arg, 'data> = 'arg => Js.Promise.t<'data>
type fetcher_sync<'arg, 'data> = 'arg => 'data

type swrHook<'key, 'data, 'config, 'response> = (. 'key, fetcher<'key, 'data>, 'config) => 'response

type middleware<'key, 'data, 'config, 'response> = (
  swrHook<'key, 'data, 'config, 'response>,
  . 'key,
  fetcher<'key, 'data>,
  'config,
) => 'response

type revalidatorOptions = {retryCount: option<int>, dedupe: option<bool>}

type revalidateType = (. revalidatorOptions) => Js.Promise.t<option<bool>>

type mutatorCallback<'data> = option<'data> => Js.Promise.t<'data>

@deriving(abstract)
type mutatorOptions<'data> = {
  @optional revalidate: bool,
  @optional populateCache: (Obj.t, 'data) => 'data,
  @optional optimisticData: 'data => 'data,
  @optional rollbackOnError: bool,
}

type keyedMutator<'data> = (
  . option<mutatorCallback<'data>>,
  option<mutatorOptions<'data>>,
) => Js.Promise.t<option<'data>>

@module("swr") @val
external mutate_key: 'key => unit = "mutate"

@module("swr") @val
external mutate: ('key, 'data, option<mutatorOptions<'data>>) => unit = "mutate"
