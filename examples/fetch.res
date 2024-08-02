exception FetchError(string, int)

let fetcher = (url) => {
  Promise.make((resolve, reject)=>{
    if (url === "") {
      reject(FetchError("Url is empty!", 400))
    }
    else {
      resolve("Got data!")
    }
  })
}
