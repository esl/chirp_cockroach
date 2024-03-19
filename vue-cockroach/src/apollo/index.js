import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client/core'
import { createApolloProvider } from '@vue/apollo-option'

// HTTP connection to the API
const httpLink = createHttpLink({
    uri: 'http://localhost:3020/graphql'
})

// Cache implementation
const cache = new InMemoryCache()

export const apolloClient = new ApolloClient({
    link: httpLink,
    cache,
})

export const apolloProvider = createApolloProvider({
    defaultClient: apolloClient,
})