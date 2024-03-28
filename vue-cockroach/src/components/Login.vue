<template>
  <div v-if="authStore.isFetchingUser">Spinner</div>
  <div v-else>
    <h4>Login</h4>
    {{ authStore.accessToken }}
    <form v-on:submit.prevent="signIn">
      <input type="text" required v-model="login" />
      <input type="password" required v-model="password" />
      <button type="submit">Sign in</button>
    </form>
    <p v-if="error">{{ error }}</p>
  </div>
</template>

<script>
import { useAuthStore } from '../stores/auth'
import { mapStores } from 'pinia'

export default {
  computed: {
    ...mapStores(useAuthStore)
  },
  data: () => {
    return {
      login: '',
      password: '',
      error: ``
    }
  },
  methods: {
    async signIn() {
      this.error = ''
      this.authStore
        .signInUser(this.login, this.password)
        .then(() => this.$router.push({ name: 'timeline' }))
        .catch((error) => {
          this.error = error.message
        })
    }
  }
}
</script>
