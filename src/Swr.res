open SwrCommon

type cacheState<'data> = {
  data?: 'data,
  error?: Exn.t,
  isLoading?: bool,
  isValidating?: bool,
}

type cache<'data> = {
  keys: unit => Iterator.t<string>,
  get: string => option<cacheState<'data>>,
  set: (string, cacheState<'data>) => unit,
  delete: string => unit,
}

type globalConfig<'key, 'data> = {
  provider?: cache<'data>,
  ...swrConfiguration<'key, 'data>,
}

@val @module("swr")
external useSWR: ('arg, fetcher<'arg, 'data>) => swrResponse<'data> = "default"

@val @module("swr")
external useSWR_config: (
  'arg,
  fetcher<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

module SwrConfigProvider = {
  @module("swr") @react.component
  external make: (
    ~value: globalConfig<'key, 'data> => globalConfig<'key, 'data>,
    ~children: React.element,
  ) => React.element = "SWRConfig"

  @module("swr") @scope("SWRConfig")
  external getDefaultValue: swrConfiguration<'key, 'data> = "defaultValue"
}

module SwrConfiguration = {
  /** `[mutateKey: (config, key)]` broadcasts a revalidation message globally to other SWR hooks */
  @send
  external mutateKey: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
  ) => promise<'data> = "mutate"

  /** `[mutateKeyWithData: (config, key, data)]` broadcasts a revalidation message globally to other SWR hooks and replacing with latest data */
  @send
  external mutateKeyWithData: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<promise<'data>>,
  ) => promise<'data> = "mutate"

  /** `[mutateWithOpts: (config, key, data, mutatorOptions)]` is used to update local data programmatically, while revalidating and finally replacing it with the latest data. */
  @send
  external mutateWithOpts: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<'data>,
    option<mutatorOptions<'data>>,
  ) => promise<'data> = "mutate"

  /** `[mutateWithOpts_async: (config, key, data, mutatorOptions)]` is the same as mutateWithOpts, except the data callback returns a promise */
  @send
  external mutateWithOpts_async: (
    swrConfiguration<'key, 'data>,
    @unwrap [#Key('key) | #Filter('key => bool)],
    option<'data> => option<promise<'data>>,
    option<mutatorOptions<'data>>,
  ) => promise<'data> = "mutate"

  @get
  external getCache: swrConfiguration<'key, 'data> => cache<'data> = "cache"

  /** `[useSWRConfig]` returns the global configuration, as well as mutate and cache options. */
  @module("swr")
  external useSWRConfig: unit => swrConfiguration<'key, 'data> = "useSWRConfig"
}

/** `[unsafeSetProperty]` is used to unsafely set a configuration property. */
@set_index
@raises(Exn.t)
external unsafeSetProperty: (swrConfiguration<'key, 'data>, string, 'val) => unit = ""

/** `[unsafeGetProperty]` is used to unsafely retrieve a configuration property. */
@get_index
@raises(Exn.t)
external unsafeGetProperty: (swrConfiguration<'key, 'data>, string) => 'val = ""

@module("swr")
external preload: (string, fetcher<'arg, 'data>) => 'a = "preload"

@module("swr") @val
external mutate_key: 'key => unit = "mutate"

@module("swr") @val
external mutate: ('key, 'data, option<mutatorOptions<'data>>) => unit = "mutate"

@module("swr/immutable")
external useSWRImmutable: (
  'arg,
  fetcher<'arg, 'data>,
  swrConfiguration<'arg, 'data>,
) => swrResponse<'data> = "default"

module Infinite = SwrInfinite
module Common = SwrCommon
