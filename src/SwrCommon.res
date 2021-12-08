type fetcher<'arg, 'data> = array<'arg> => Js.Promise.t<'data>
type fetcher_sync<'arg, 'data> = array<'arg> => 'data
type fetcher1<'arg, 'data> = 'arg => Js.Promise.t<'data>
type fetcher_sync1<'arg, 'data> = 'arg => 'data
type fetcher2<'arg1, 'arg2, 'data> = ('arg1, 'arg2) => Js.Promise.t<'data>
type fetcher_sync2<'arg1, 'arg2, 'data> = ('arg1, 'arg2) => 'data
type fetcher3<'arg1, 'arg2, 'arg3, 'data> = ('arg1, 'arg2, 'arg3) => Js.Promise.t<'data>
type fetcher_sync3<'arg1, 'arg2, 'arg3, 'data> = ('arg1, 'arg2, 'arg3) => 'data

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

type keyedMutator<'data> = (
  . option<mutatorCallback<'data>>,
  option<bool>,
) => Js.Promise.t<option<'data>>

@ocaml.doc(`[makeFallback] is used to create an object to provide global fallback data.`)
external makeFallback: {..} => Js.Json.t = "%identity"

@module("swr") @val
external mutate_key: 'key => unit = "mutate"

@module("swr") @val
external mutate: ('key, 'data, bool) => unit = "mutate"
