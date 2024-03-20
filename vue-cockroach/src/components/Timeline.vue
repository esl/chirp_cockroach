<script>
import gql from 'graphql-tag'
import PostComponent from './timeline/PostComponent.vue'

const GET_POSTS = gql`
  query list_posts {
    posts {
      id
      body
      likesCount
      repostsCount
      author {
        nickname
      }
    }
  }
`

const CREATE_POST = gql`
  mutation create_post($body: String!) {
    createPost(body: $body) {
      id
      body
      likesCount
      repostsCount
      author {
        nickname
      }
    }
  }
`

const POST_ADDED = gql`
  subscription postCreated {
    postCreated {
      id
      body
      likesCount
      repostsCount
      author {
        nickname
      }
    }
  }
`

const POST_UPDATED = gql`
  subscription postUpdated {
    postUpdated {
      id
      body
      likesCount
      repostsCount
      author {
        nickname
      }
    }
  }
`

const POST_DELETED = gql`
  subscription postDeleted {
    postDeleted {
      id
    }
  }
`

const addPost = (posts, post) => [post, ...posts]

const updatePost = (posts, updated_post) => {
  return posts.map((post) => (post.id === updated_post.id ? updated_post : post))
}

const deletePost = (posts, deleted_post) => {
  return posts.filter((post) => post.id !== deleted_post.id)
}

export default {
  apollo: {
    posts: {
      query: GET_POSTS,
      subscribeToMore: [
        {
          document: POST_ADDED,
          updateQuery: (previousResults, { subscriptionData }) => {
            return {
              ...previousResults,
              posts: addPost(previousResults.posts, subscriptionData.data.postCreated)
            }
          }
        },
        {
          document: POST_UPDATED,
          updateQuery: (previousResults, { subscriptionData }) => {
            return {
              ...previousResults,
              posts: updatePost(previousResults.posts, subscriptionData.data.postUpdated)
            }
          }
        },
        {
          document: POST_DELETED,
          updateQuery: (previousResults, { subscriptionData }) => {
            return {
              ...previousResults,
              posts: deletePost(previousResults.posts, subscriptionData.data.postDeleted)
            }
          }
        }
      ]
    }
  },
  components: { PostComponent },
  data() {
    return {
      postBody: '',
      posts: []
    }
  },
  methods: {
    createPost() {
      this.$apollo
        .mutate({
          mutation: CREATE_POST,
          variables: { body: this.postBody }
        })
        .then((data) => {
          console.log(data)
          this.postBody = ''
        })
        .catch((error) => {
          console.log(error)
        })
    }
  }
}
</script>

<template>
  <h2>Timeline</h2>

  <form v-on:submit.prevent="createPost">
    <input type="text" required v-model="postBody" />
    <button type="submit">Send</button>
  </form>

  <PostComponent v-for="post in posts" :key="post.id" v-bind="post" />
</template>
