// Examples in this file have been adapted
// from https://swr.vercel.app/docs/error-handling
open Swr
open Fetch

type state<'a> = Idle | Loading | Resolved('a)

@react.component
let make = (~url) => {
  let {data, error} = useSWR_config(
    url,
    fetcher,
    swrConfiguration(~onErrorRetry=(error, key, _config, revalidate, {retryCount}) => {
      switch error {
      | FetchError(_info, status) if status == 400 => ()
      | _ =>
        switch key {
        | "/api/user" => ()
        | _ =>
          switch retryCount {
          | Some(val) if val >= 10 => ()
          | _ =>
            Js.Global.setTimeout(
              () => revalidate(. {retryCount: retryCount, dedupe: None})->ignore,
              5000,
            )->ignore
          }
        }
      }
    }, ()),
  )
  let state = switch (data, error) {
    | (None, None) => Loading
    | (Some(data), None) => Resolved(Ok(data))
    | (None, Some(err)) => Resolved(Error(err))
    | (_, _) => Idle
  }

  <div>
  {switch state {
    | Loading => "Loading..."
    | Resolved(Ok(data)) => "Got data: " ++ data
    | Resolved(Error(error)) => switch (error) {
      | FetchError(message, _status) => "Error while fetching: " ++ message
      | Js.Exn.Error(err) => "Error: " ++ Js.Exn.message(err)->Belt.Option.getWithDefault("Unknown exception!")
      | _ => "Unknown error encountered!"
    }
    | Idle => "Not doing anything!"
  }->React.string}
  </div>
}
