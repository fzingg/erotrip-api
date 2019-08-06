// // Note: You must restart bin/webpack-dev-server for changes to take effect

// const merge = require('webpack-merge')
// const sharedConfig = require('./shared.js')
// const { settings, output } = require('./configuration.js')

// module.exports = merge(sharedConfig, {
//   devtool: 'cheap-eval-source-map',

//   stats: {
//     errorDetails: true
//   },

//   output: {
//     // pathinfo: true
//   },

//   devServer: {
//     clientLogLevel: 'none',
//     https: settings.dev_server.https,
//     host: settings.dev_server.host,
//     port: settings.dev_server.port,
//     contentBase: output.path,
//     publicPath: output.publicPath,
//     compress: true,
//     headers: { 'Access-Control-Allow-Origin': '*' },
//     historyApiFallback: true,
//     watchOptions: {
//       ignored: /node_modules/
//     }
//   },

//   externals: {
//     "react": "React",
//     "react-dom": "ReactDOM"
//   }
// })

// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

if (global.Promise == null) {
    global.Promise = require('es6-promise')
}
console.log('PROMISE!', global.Promise);

const webpack = require('webpack')
const merge = require('webpack-merge')
const CompressionPlugin = require('compression-webpack-plugin')
const sharedConfig = require('./shared.js')
const { output } = require('./configuration.js')

module.exports = merge(sharedConfig, {
  output: { filename: '[name].js' },

  // output: {
  //   pathinfo: true
  // },

  devtool: 'source-map',
  // stats: 'normal',

  stats: {
    errorDetails: true
  },

  externals: {
    "react": "React"
  },

  plugins: [
    // new webpack.optimize.UglifyJsPlugin({
    //   minimize: true,
    //   sourceMap: true,

    //   compress: {
    //     warnings: false
    //   },

    //   output: {
    //     comments: false
    //   }
    // }),

    // new CompressionPlugin({
    //   asset: '[path].gz[query]',
    //   algorithm: 'gzip',
    //   test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    // })
  ]
})