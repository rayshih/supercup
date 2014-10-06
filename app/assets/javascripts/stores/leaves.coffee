_ = require 'lodash'
Reflux = require 'reflux'
action = require '../actions/leaves'
Leave = require '../models/leave'

module.exports = Reflux.createStore
  init: ->
    @data = null
    @listenToMany action

  get: (id) ->
    _.find @data, (leave) -> leave.id == id

  findByWorkerId: (workerId) ->
    _.filter @data, (leave) -> leave.getWorkerId() == workerId

  parse: (data) ->
    @data = data.map (item) -> Leave.parse item
    @reorder()

  reorder: ->
    @data = _.chain(@data).
    sortBy((leave) ->
      leave.getStartDate()
    ).
    value()

  onIndex: ->
    return @trigger @data if @data

    $.getJSON '/api/leaves', (data) =>
      @trigger @parse(data)

  onCreate: (leave) ->
    $.ajax(
      method: 'POST'
      dataType: 'json'
      url: '/api/leaves'
      data:
        leave: leave.data
    ).done (data) =>
      @data.push Leave.parse(data)
      @reorder()
      @trigger @data

  onDestroy: (id) ->
    @data = _.filter @data, (leave) -> leave.id != id
    @trigger @data

    $.ajax
      method: 'DELETE'
      dataType: 'json'
      url: "/api/leaves/#{id}"
