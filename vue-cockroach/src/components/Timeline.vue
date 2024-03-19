<script setup>

import { usePostsStore } from '../stores/posts'

const store = usePostsStore();

</script>

<template>
    <h2>Timeline</h2>

    <ul>
        <li v-for="post in store.posts">
            {{ post.body }}
        </li>
    </ul>
</template>