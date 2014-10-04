_ = require 'lodash'
Reflux = require 'reflux'
action = require '../actions/workers'
Worker = require '../models/worker'

module.exports = Reflux.createStore
  init: ->
    @data = null

    @listenToMany action

  get: (id) ->
    _.find @data, (worker) -> worker.id == id

  parse: (data) ->
    @data = data.map (item) -> new Worker(item)
    @reorder()

  reorder: ->
    @data = _.chain(@data).
    sortBy('id').
    value()

  onIndex: ->
    if @data
      @trigger @data
      return
    else
      @trigger []

    $.getJSON '/api/workers', (data) =>
      @data = @parse data
      @trigger @data

  onCreate: (worker) ->
    $.ajax(
      method: 'POST'
      dataType: 'json'
      url: '/api/workers'
      data:
        worker: worker
    ).done (worker) =>
      @data.push new Worker(worker)
      @reorder()
      @trigger @data

  onDestroy: (id) ->
    @data = _.filter @data, (worker) -> worker.id != id
    @trigger @data

    $.ajax
      method: 'DELETE'
      dataType: 'json'
      url: "/api/workers/#{id}"
