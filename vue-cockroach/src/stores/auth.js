import { defineStore } from 'pinia'
import gql from 'graphql-tag'
import { apolloClient, resetApolloConnection } from './../apollo'

const LOGIN = gql`
  mutation login($email: String!, $password: String!) {
    login(email: $email, password: $password)
  }
`

const LOGOUT = gql`
  mutation logout($token: String!) {
    logout(token: $token)
  }
`

const REGISTER = gql`
  mutation register($email: String!, $password: String!, $nickname: String!) {
    register(email: $email, password: $password, nickname: $nickname) {
      id
      nickname
      email
    }
  }
`

export const useAuthStore = defineStore('auth', {
  state: () => {
    return {
      loggedIn: !!localStorage.getItem('access_token')
    }
  },
  actions: {
    async signInUser(email, password) {
      const { login } = (
        await apolloClient.mutate({
          mutation: LOGIN,
          variables: { email: email, password: password }
        })
      ).data

      if (!login) return

      const token = `Bearer ${login}`

      localStorage.setItem('access_token', token)
      resetApolloConnection()

      this.loggedIn = true
      await apolloClient.resetStore()
    },

    register(nickname, email, password) {
      return apolloClient.mutate({
        mutation: REGISTER,
        variables: { nickname: nickname, email: email, password: password }
      })
    },

    async signOut() {
      const { logout } = (
        await apolloClient.mutate({
          mutation: LOGOUT,
          variables: { token: localStorage.getItem('access_token') }
        })
      ).data

      if (logout) {
        localStorage.removeItem('access_token')
        this.loggedIn = false
        resetApolloConnection()

        await apolloClient.resetStore()
      }
    }
  }
})
