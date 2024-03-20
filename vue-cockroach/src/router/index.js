import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import TimelineView from '../views/TimelineView.vue'

import LoginView from '../views/auth/LoginView.vue'
import RegisterView from '../views/auth/RegisterView.vue'

import { useAuthStore } from '../stores/auth'

const redirectToHomeOnLoggedIn = (to, from, next) => {
  if (useAuthStore().loggedIn) next({ name: "home" });
  else next();
};

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/timeline',
      name: 'timeline',
      component: TimelineView,
      meta: { requireAuth: true }
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue')
    },
    {
      path: '/auth',
      beforeEnter: redirectToHomeOnLoggedIn,
      children: [
        {path: 'login', name: 'login', component: LoginView},
        {path: 'register', name: 'register', component: RegisterView}
      ]
    },
  ]
})

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()
  console.log(auth.loggedIn)
  if (to.meta.requireAuth && !useAuthStore().loggedIn)
    next({ name: "login" });
  else next();
});


export default router
