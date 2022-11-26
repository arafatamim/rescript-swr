type fetcherOpts<'arg> = {arg: 'arg}
type fetcher<'key, 'arg, 'data> = ('key, fetcherOpts<'arg>) => Js.Promise.t<'data>

type rec swrMutationConfig<'key, 'data> = {
  fetcher?: SwrCommon.fetcher<'key, 'data>,
  onError?: (Js.Exn.t, 'key, swrMutationConfig<'key, 'data>) => unit,
  onSuccess?: ('data, 'key, swrMutationConfig<'key, 'data>) => unit,
  revalidate?: bool,
  populateCache?: (. Obj.t, 'data) => 'data,
  optimisticData?: 'data => 'data,
  rollbackOnError?: Obj.t => bool,
  throwOnError?: bool,
}

type swrMutationResponse<'key, 'arg, 'data> = {
  data: 'data,
  error: Js.Exn.t,
  isMutating: bool,
  reset: unit => unit,
  trigger: ('arg, ~config: swrMutationConfig<'key, 'data>=?, unit) => Js.Promise.t<'data>,
}

@val @module("swr/mutation")
external useSWRMutation: (
  'key,
  fetcher<'key, 'arg, 'data>,
  ~config: swrMutationConfig<'key, 'data>=?,
  unit,
) => swrMutationResponse<'key, 'arg, 'data> = "default"
