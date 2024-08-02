type response = {fact: string}

@val
external fetch: string => promise<{"json": unit => promise<response>}> = "fetch"

let sleeper = (ms, x) => Promise.make((resolve, _) => setTimeout(_ => resolve(x), ms)->ignore)

let fetcher = key => {
  fetch("https://catfact.ninja" ++ key)
  ->Promise.then(res => res["json"]())
  ->Promise.thenResolve(res => res.fact)
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
        <button onClick={_ => mutate(Refresh)->ignore}> {"New"->string} </button>
        <button onClick={_ => mutate(Clear, ~revalidate=false)->ignore}> {"Clear"->string} </button>
        <button
          onClick={_ =>
            mutate(
              Overwrite(
                Option.map(_, data => data->String.replaceAllRegExp(%re("/cat/gi"), "🐱")),
              ),
              ~revalidate=false,
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
          <button onClick={_ => mutate(Refresh)->ignore}> {"Load"->string} </button>
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
| Some(domNode) => {
    open ReactDOM.Client
    createRoot(domNode)->Root.render(<App />)
  }
| None => "Mount root missing!"->Console.error
}
