// TODO review required
type swrSubscription<'key, 'data> = ('key, (exn, 'data) => unit) => unit

type swrSubscriptionResponse<'data> = {data: 'data, error: exn}

@val @module("swr/subscription")
external useSWRSubscription: (
  'key,
  swrSubscription<'key, 'data>,
  Swr.swrConfiguration<'key,'data>,
) => swrSubscriptionResponse<'data> = "default"
