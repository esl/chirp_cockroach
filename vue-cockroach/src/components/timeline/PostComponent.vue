<script>
import { ref } from 'vue'

import gql from 'graphql-tag'

const UPDATE_POST = gql`
  mutation updatePost($id: ID!, $body: String!) {
    updatePost(id: $id, body: $body) {
      id
    }
  }
`

const DELETE_POST = gql`
  mutation deletePost($id: ID!) {
    deletePost(id: $id) {
      id
    }
  }
`

export default {
    props: ['id', 'body', 'author', 'likesCount', 'repostsCount'],
  data: () => {
    return {
        editing: false,
        newBody: ''
    }
  },
  methods: {
    toggleEditing() {
        if(this.editing) {
            this.editing = false;
        } else {
            this.newBody = this.body;
            this.editing = true;
        }
    },
    savePost() {
        console.log({id: this.id, body: this.newBody})
        this.$apollo
            .mutate({
                mutation: UPDATE_POST,
                variables: {id: this.id, body: this.newBody}
            }).then((_data) => {
                this.editing = false;
            })
    },
    deletePost() {
        this.$apollo
            .mutate({
                mutation: DELETE_POST,
                variables: {id: this.id}
            })
    }
  }
}
</script>

<template>
    <div class="post">
        <h3>@{{ author.nickname }}</h3>
        
        <input v-if="editing" type="text" required v-model="newBody" />
        <p v-if="!editing">{{ body }}</p>
        <div class="reactions">{{ likesCount }} likes and {{ repostsCount }} reposts</div>
        <button v-on:click="toggleEditing()">Edit</button>
        <button v-on:click="savePost()" v-if="editing">Save</button>
        <button v-on:click="deletePost()">Delete</button>
    </div>
</template>

<style>
.post {
    border: 1px solid grey;
    border-radius: 5px;
    background: darkslategray;
    padding: 5px;
    margin: 5px;

    h3 {
        font-weight: bold;
    }
    
    p {
        border-top: 1px solid grey;
    }

    .reactions {
        text-align: right;
    }
}
</style>