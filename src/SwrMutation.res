type fetcherOpts<'arg> = {arg: 'arg}
type fetcher<'key, 'arg, 'data> = ('key, fetcherOpts<'arg>) => Js.Promise.t<'data>

@deriving(abstract)
type rec swrMutationConfig<'key, 'data> = {
  @optional fetcher: SwrCommon.fetcher<'key, 'data>,
  @optional onError: (. exn, 'key, swrMutationConfig<'key, 'data>) => unit,
  @optional onSuccess: (. 'data, 'key, swrMutationConfig<'key, 'data>) => unit,
  @optional revalidate: bool,
  @optional populateCache: (. Obj.t, 'data) => 'data,
  @optional optimisticData: 'data => 'data,
  @optional rollbackOnError: bool,
}

type swrMutationResponse<'key, 'arg, 'data> = {
  data: 'data,
  error: exn,
  isMutating: bool,
  reset: unit => unit,
  trigger: (. 'arg, swrMutationConfig<'key, 'data>) => Js.Promise.t<'data>,
}

@val @module("swr/mutation")
external useSWRMutation: (
  'key,
  fetcher<'key, 'arg, 'data>,
  swrMutationConfig<'key, 'data>,
) => swrMutationResponse<'key, 'arg, 'data> = "default"

