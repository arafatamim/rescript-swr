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
    {
      onErrorRetry: (error, key, _config, revalidate, opts) => {
        Js.log(error)
        switch key {
        | "/api/user" => ()
        | _ => Js.Global.setTimeout(() => revalidate(. opts)->ignore, 5000)->ignore
        }
      },
    },
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
    | Resolved(Error(error)) =>
      "Error: " ++ Js.Exn.message(error)->Belt.Option.getWithDefault("Unknown exception!")
    | Idle => "Not doing anything!"
    }->React.string}
  </div>
}
