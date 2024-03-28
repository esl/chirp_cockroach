import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client/core'
import { createApolloProvider } from '@vue/apollo-option'
import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'
import { Socket as PhoenixSocket } from 'phoenix'

const phoenixSocket = () =>
  new PhoenixSocket('ws://localhost:4000/socket', {
    params: () => {
      if (localStorage.getItem('access_token')) {
        return { authorization: localStorage.getItem('access_token') }
      } else {
        return {}
      }
    }
  })

const absintheSocket = () => AbsintheSocket.create(phoenixSocket())

// Create an Apollo link from the AbsintheSocket instance.
const link = () => createAbsintheSocketLink(absintheSocket())

// Apollo also requires you to provide a cache implementation
// for caching query results. The InMemoryCache is suitable
// for most use cases.
const cache = new InMemoryCache()

export const apolloClient = new ApolloClient({
  link: link(),
  cache
})

export const resetApolloConnection = () => {
  apolloClient.setLink(link())
}

export const apolloProvider = createApolloProvider({
  defaultClient: apolloClient
})
