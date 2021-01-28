<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Home</router-link>
      <router-link to="/nft">NFT</router-link>
      <router-link to="/about">Over</router-link>
    </div>
    <router-view/>
  </div>
</template>

<style lang="scss">
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;

  a {
    padding: 0 10px;
    color: #333;
    font-weight: bold;
    text-decoration: none;
    transition: color 0.3s ease-out;

    &.router-link-exact-active {
      text-decoration: underline;
    }

    &:hover {
      color: #5695f4;
    }
  }
}
</style>
