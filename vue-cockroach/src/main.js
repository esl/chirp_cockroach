import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

import { apolloProvider } from './apollo'

const app = createApp(App)

app.use(createPinia())
app.use(apolloProvider)
app.use(router)

app.mount('#app')
