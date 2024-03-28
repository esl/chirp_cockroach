<template>
  <div>
    <h4>Register</h4>
    <form v-on:submit.prevent="register()">
      <label>Email</label>
      <input type="text" required v-model="email" />
      <label>Nickname</label>
      <input type="text" required v-model="nickname" />
      <label>Password</label>
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
      nickname: '',
      email: '',
      password: '',
      error: ``
    }
  },
  methods: {
    async register() {
      this.error = ''
      this.authStore
        .register(this.nickname, this.email, this.password)
        .then((_data) => {
          this.$router.push({ name: 'Login' })
        })
        .catch((error) => {
          this.error = error.message
        })
    }
  }
}
</script>
