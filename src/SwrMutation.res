type fetcherOpts<'arg> = {arg: 'arg}
type fetcher<'key, 'arg, 'data> = ('key, fetcherOpts<'arg>) => promise<'data>

type rec swrMutationConfig<'key, 'arg, 'data> = {
  fetcher?: fetcher<'key, 'arg, 'data>,
  onError?: (Exn.t, 'key, swrMutationConfig<'key, 'arg, 'data>) => unit,
  onSuccess?: ('data, 'key, swrMutationConfig<'key, 'arg, 'data>) => unit,
  revalidate?: bool,
  populateCache?: (Obj.t, 'data) => 'data,
  optimisticData?: 'data => 'data,
  rollbackOnError?: Obj.t => bool,
  throwOnError?: bool,
}

type swrMutationResponse<'key, 'arg, 'data> = {
  data: 'data,
  error: Exn.t,
  isMutating: bool,
  reset: unit => unit,
  trigger: ('arg, ~config: swrMutationConfig<'key, 'arg, 'data>=?) => promise<'data>,
}

@val @module("swr/mutation")
external useSWRMutation: (
  'key,
  fetcher<'key, 'arg, 'data>,
  ~config: swrMutationConfig<'key, 'arg, 'data>=?,
) => swrMutationResponse<'key, 'arg, 'data> = "default"
