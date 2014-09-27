var webpack = require('webpack');

module.exports = {
  context: __dirname + '/app/assets/javascripts',
  entry: './_application.coffee',
  output: {
    filename: '[name].bundle.js',
    path: __dirname + '/app/assets/javascripts',
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' }
    ]
  },
  resolve: {
    modulesDirectories: ['node_modules', 'bower_components'],
    extensions: ['', '.js', '.js.coffee', '.coffee']
  },
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('bower.json', ['main'])
    )
  ]
};

