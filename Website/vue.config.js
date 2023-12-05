const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  css: {
    loaderOptions: {
      sass: {
        additionalData: `@import "@/styles/global.scss";` // Opcional: Importe seus arquivos SCSS globais aqui
      }
    }
  }
})
