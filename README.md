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

  let {data} = Swr.useSWR(~config, "key", _ => load_data());

  switch (data) {
  | Some(data) => render(data)
  | None => render_loading()
  };
};
```

## Credits
Originally forked from https://github.com/roddyyaga/bs-swr
