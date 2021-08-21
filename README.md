# rescript-swr
ReScript bindings to [SWR](https://github.com/vercel/swr).

## Installation
Run
```
npm install rescript-swr swr
```
and add `rescript-swr` to `bsconfig.json`.

## Example
```rescript
@react.component
let make = () => {
  let config = Swr.Options.make(~dedupingInterval=6000, ());

  let {data} = Swr.useSWR(
    key,
    (key) => fetchData(key),
    // callback functions are passed as separate
    // parameters instead of in the
    // config parameter
    ~onLoadingSlow=(_, _) => setLoadingSlow(_ => true),
    ~config=config
  );

  switch (data) {
  | Some(data) => render(data)
  | None => render_loading()
  };
};
```
### Global configuration
```rescript
<Swr.SwrConfig
  initialData={someData}
  config={Swr.Options.make(
    ~shouldRetryOnError=true,
    ~errorRetryCount=2,
    ~loadingTimeout=3000,
    (),
  )}
  <Child />
</Swr.SwrConfig>
```

## API
### `Swr.Options.t`
```rescript
errorRetryInterval: option<int>,
errorRetryCount: option<int>,
loadingTimeout: option<int>,
focusThrottleInterval: option<int>,
dedupingInterval: option<int>,
refreshInterval: option<int>,
refreshWhenHidden: option<bool>,
refreshWhenOffline: option<bool>,
revalidateOnFocus: option<bool>,
revalidateOnMount: option<bool>,
revalidateOnReconnect: option<bool>,
revalidateWhenStale: option<bool>,
shouldRetryOnError: option<bool>,
suspense: option<bool>,
```

### `Swr.useSwr`
```rescript
(
  ~config: Swr.Options.t=?,
  ~initialData: 'data=?,
  ~isOnline: unit => bool=?,
  ~isPaused: unit => bool=?,
  ~isVisible: unit => bool=?,
  ~onLoadingSlow: (
    array<'key>,
    Swr_Raw.configInterface<array<'key>, 'data>,
  ) => unit=?,
  ~onSuccess: (
    'data,
    array<'key>,
    Swr_Raw.configInterface<array<'key>, 'data>,
  ) => unit=?,
  ~onError: (
    Js.Promise.error,
    array<'key>,
    Swr_Raw.configInterface<array<'key>, 'data>,
  ) => unit=?,
  ~onErrorRetry: (
    Js.Promise.error,
    array<'key>,
    Swr_Raw.configInterface<array<'key>, 'data>,
    Swr_Raw.revalidateType,
    Swr_Raw.revalidateOptionInterface,
  ) => unit=?,
  ~compare: (option<'data>, option<'data>) => bool=?,
  'key,
  'key => Js.Promise.t<'data>,
) => responseInterface<'data>

```

## Credits
Originally forked from https://github.com/roddyyaga/bs-swr
