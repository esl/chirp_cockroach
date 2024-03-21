import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client/core'
import { createApolloProvider } from '@vue/apollo-option'
import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'
import { Socket as PhoenixSocket } from 'phoenix'
import Cookies from 'js-cookie'

const phoenixSocket = new PhoenixSocket('ws://localhost:4000/socket', {
  params: () => {
    if (Cookies.get('token')) {
      return { token: Cookies.get('token') }
    } else {
      return {}
    }
  }
})

const absintheSocket = AbsintheSocket.create(phoenixSocket)
// Create an Apollo link from the AbsintheSocket instance.
const link = createAbsintheSocketLink(absintheSocket)

// Apollo also requires you to provide a cache implementation
// for caching query results. The InMemoryCache is suitable
// for most use cases.
const cache = new InMemoryCache()

export const apolloClient = new ApolloClient({
  link: link,
  cache
})

export const apolloProvider = createApolloProvider({
  defaultClient: apolloClient
})
