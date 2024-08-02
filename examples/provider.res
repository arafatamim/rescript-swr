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

let setupCache = map => {
  {
    get: key => {
      map->Map.get(key)->Option.map(data => {data})
    },
    set: (key, value) => {
      switch value.data {
      | Some(data) => map->Map.set(key, {data: data})
      | _ => ()
      }
    },
    delete: key => {
      map->Map.delete(key)->ignore
    },
    keys: () => {
      map->Map.keys
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
  let cache = localStorage->getItem("app-cache")->Option.getOr("[]")->parseArray
  let map = Map.fromArray(cache)

  // Before unloading the app, we write back all the data into `localStorage`.
  addEventListener("beforeunload", () => {
    let appCache = stringifyArray(map->Map.entries->Array.fromIterator)
    localStorage->setItem("app-cache", appCache)
  })

  setupCache(map)
}

module LocalStorageProvider = {
  @react.component
  let make = () => {
    <SwrConfigProvider
      value={config => {
        dedupingInterval: ?config.dedupingInterval->Option.map(v => v * 5),
        revalidateOnFocus: false,
        suspense: true,
        provider: localStorageProvider(),
      }}>
      <div />
    </SwrConfigProvider>
  }
}
