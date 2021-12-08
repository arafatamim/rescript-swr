exception FetchError(string, int)

let fetcher = (url) => {
  Js.Promise.make((~resolve, ~reject)=>{
    if (url === "") {
      reject(. FetchError("Url is empty!", 400))
    }
    else {
      resolve(. "Got data!")
    }
  })
}
