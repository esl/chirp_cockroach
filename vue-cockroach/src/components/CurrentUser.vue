<script>
import gql from 'graphql-tag'
import { useAuthStore } from '../stores/auth'
import { mapStores } from 'pinia'

const CURRENT_USER = gql`
  query currentUser {
    currentUser {
      id
      nickname
      email
    }
  }
`

export default {
  apollo: {
    currentUser: CURRENT_USER
  },
  computed: {
    ...mapStores(useAuthStore)
  },
  methods: {
    signOut() {
      this.authStore.signOut().then(() => this.$router.push({ name: 'login' }))
    }
  }
}
</script>

<template>
  <a v-if="currentUser">
    {{ currentUser.nickname }}
  </a>
  <a v-if="authStore.loggedIn" v-on:click="signOut()">Logout</a>
  <RouterLink v-if="!authStore.loggedIn" to="/auth/login">Login</RouterLink>
  <RouterLink v-if="!authStore.loggedIn" to="/auth/register">Register</RouterLink>
</template>
