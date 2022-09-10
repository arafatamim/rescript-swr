type fetcher<'arg, 'data> = 'arg => Js.Promise.t<'data>
type fetcher_sync<'arg, 'data> = 'arg => 'data

type swrHook<'key, 'data, 'config, 'response> = (. 'key, fetcher<'key, 'data>, 'config) => 'response

type middleware<'key, 'data, 'config, 'response> = (
  swrHook<'key, 'data, 'config, 'response>,
  . 'key,
  fetcher<'key, 'data>,
  'config,
) => 'response

type revalidatorOptions = {retryCount?: int, dedupe?: bool}

type revalidateType = (. revalidatorOptions) => Js.Promise.t<option<bool>>

type mutatorCallback<'data> = option<'data> => option<Js.Promise.t<'data>>

type mutatorOptions<'data> = {
  revalidate?: bool,
  populateCache?: (Obj.t, 'data) => 'data,
  optimisticData?: 'data => 'data,
  rollbackOnError?: bool,
}

type keyedMutator<'data> = (
  . mutatorCallback<'data>,
  option<mutatorOptions<'data>>,
) => option<Js.Promise.t<'data>>
