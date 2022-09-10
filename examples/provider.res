open Swr

/* bindings */
// JSON.parse
@scope("JSON") @val
external parseArray: string => array<'t> = "parse"
// JSON.stringify
@scope("JSON") @val
external stringifyArray: array<'t> => string = "stringify"
// window.addEventListener
@val @scope("window")
external addEventListener: (string, 'event => unit) => unit = "addEventListener"

let wrapDataIntoCacheState = data => {
  data: Some(data),
  error: None,
  isLoading: false,
  isValidating: false,
}

let setupCache = map => {
  open Belt

  {
    get: (. key) => {
      wrapDataIntoCacheState(
        map->HashMap.String.get(key)->Option.getWithDefault(""),
      )->Js.Nullable.return
    },
    set: (. key, value) => {
      map->HashMap.String.set(key, value.data->Option.getWithDefault(""))
    },
    delete: (. key) => {
      map->HashMap.String.remove(key)
      true
    },
  }
}

/*
  Example stolen from
  https://swr.vercel.app/docs/advanced/cache#localstorage-based-persistent-cache
*/
let localStorageProvider: unit => cache<string> = () => {
  open Dom.Storage2

  // When initializing, we restore the data from `localStorage` into a map.
  let cache = localStorage->getItem("app-cache")->Belt.Option.getWithDefault("[]")->parseArray
  let map = Belt.HashMap.String.fromArray(cache)

  // Before unloading the app, we write back all the data into `localStorage`.
  addEventListener("beforeunload", () => {
    let appCache = stringifyArray(map->Belt.HashMap.String.toArray)
    localStorage->setItem("app-cache", appCache)
  })

  setupCache(map)
}

module LocalStorageProvider = {
  @react.component
  let make = () => {
    let config = {revalidateOnFocus: false}
    config->SwrConfigProvider.setCacheProvider(_cache => localStorageProvider())
    <SwrConfigProvider value={config => {...config, suspense: true}}>
      <div />
    </SwrConfigProvider>
  }
}
