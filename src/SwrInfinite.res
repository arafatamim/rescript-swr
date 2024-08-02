open SwrCommon

type keyLoader<'key, 'any> = (int, option<'any>) => option<'key>

type swrInfiniteResponse<'data> = {
  ...swrResponse<'data>,
  size: int,
  setSize: (int => int) => promise<option<array<'data>>>,
}

type swrInfiniteConfiguration<'key, 'data> = {
  ...swrConfiguration<'key, 'data>,
  /* infinite hook-specific options */
  initialSize?: int,
  revalidateAll?: bool,
  persistSize?: bool,
  revalidateFirstPage?: bool,
}

@val @module("swr/infinite")
external useSWRInfinite: (
  keyLoader<'arg, 'any>,
  fetcher<'arg, 'data>,
) => swrInfiniteResponse<'data> = "default"

@val @module("swr/infinite")
external useSWRInfinite_config: (
  keyLoader<'arg, 'any>,
  fetcher<'arg, 'data>,
  swrInfiniteConfiguration<'key, 'data>,
) => swrInfiniteResponse<'data> = "default"

@ocaml.doc(`[setConfigProperty] is used to unsafely set a configuration property.`) @set_index
external setConfigProperty: (swrInfiniteConfiguration<'key, 'data>, string, 'val) => unit = ""
