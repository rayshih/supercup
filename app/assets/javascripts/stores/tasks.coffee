Reflux = require 'reflux'
action = require '../actions/tasks'

module.exports = Reflux.createStore
  init: ->
    @data = []
    @listenTo action.create, @createTask

  createTask: (task) ->
    @data.push task
    @trigger @data
