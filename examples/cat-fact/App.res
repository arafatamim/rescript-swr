type response = {fact: string}

@val
external fetch: string => Js.Promise.t<{"json": (. unit) => Js.Promise.t<response>}> = "fetch"

let sleeper = (ms, x) =>
  Js.Promise.make((~resolve, ~reject as _) => Js.Global.setTimeout(_ => resolve(. x), ms)->ignore)

let fetcher = key => {
  fetch("https://catfact.ninja" ++ key)
  |> Js.Promise.then_(res => res["json"](.))
  /* |> Js.Promise.then_(data => Js.Promise.resolve(data.fact)) */
  |> Js.Promise.then_(data => sleeper(5000, data.fact))
}

let renderData = data => ("Cat fact: " ++ data)->React.string
let renderError = (err: SwrEasy.error) => <p> {("Error: " ++ err.message)->React.string} </p>

module App = {
  @react.component
  let make = () => {
    open React
    open SwrEasy

    let {result, mutate} = useSWR("/fact", fetcher)

    let btns =
      <>
        <button onClick={_ => mutate(Refresh, ())->ignore}> {"New"->string} </button>
        <button onClick={_ => mutate(Clear, ~revalidate=false, ())->ignore}>
          {"Clear"->string}
        </button>
        <button
          onClick={_ =>
            mutate(
              Overwrite(
                Belt.Option.map(_, data => data->Js.String2.replaceByRe(%re("/cat/gi"), "🐱")),
              ),
              ~revalidate=false,
              (),
            )->ignore}>
          {"🐱-ify"->string}
        </button>
      </>

    let render = switch result {
    | Pending => <p> {"Loading..."->string} </p>
    | Refresh(Ok(data)) =>
      <>
        <p> {renderData(data)} </p>
        <p> {"Revalidating..."->string} </p>
      </>
    | Refresh(Error(err)) =>
      <>
        <p> {renderError(err)} </p>
        <p> {"Validating..."->string} </p>
      </>
    | Replete(Ok(data)) =>
      <>
        <p> {renderData(data)} </p>
        <p> {btns} </p>
      </>
    | Replete(Error(err)) =>
      <>
        <p> {renderError(err)} </p>
        <p> {btns} </p>
      </>
    | _ =>
      <>
        <p> {"Cat fact not loaded"->string} </p>
        <p>
          <button onClick={_ => mutate(Refresh, ())->ignore}> {"Load"->string} </button>
        </p>
      </>
    }

    <div>
      {render}
      <p>
        {"Click on "->string}
        <a href="https://codesandbox.io/s/cat-fact-swr-test-hcknr4"> {"this"->string} </a>
        {" link to see the JavaScript equivalent of this code."->string}
      </p>
    </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<App />, root)
| None => "Mount root missing!"->Js.Console.error
}
