module.exports = {
    client: {
      service: {
        name: 'vue-cockroach',
        url: 'http://localhost:4000/api/graphql',
      },
      // Files processed by the extension
      includes: [
        'src/**/*.vue',
        'src/**/*.js',
      ],
    },
  }