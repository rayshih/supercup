_ = require 'lodash'
Reflux = require 'reflux'
action = require '../actions/tasks'
Task = require '../models/task'

module.exports = Reflux.createStore
  init: ->
    @data = []
    @count = 0

    @listenTo action.index, @index
    @listenTo action.create, @create
    @listenTo action.update, @update
    @listenTo action.destroy, @destroy
    @listenTo action.setParent, @setParent

  get: (id) ->
    _.find @data, (task) -> task.id == id

  parse: (data) ->
    @data = data.map (item) -> new Task(item)
    @reorder()

  reorder: ->
    @data = _.chain(@data).
    sortBy('id').
    reverse().
    value()

  index: ->
    @trigger @data

    $.getJSON '/api/tasks', (data) =>
      @data = @parse data
      @trigger @data

  create: (task) ->
    $.ajax(
      method: 'POST'
      dataType: 'json'
      url: '/api/tasks'
      data:
        task: task
    ).done (task) =>
      @data.push new Task(task)
      @reorder()
      @trigger @data

  update: (task) ->
    $.ajax(
      method: 'PUT'
      dataType: 'json'
      url: "/api/tasks/#{task.id}"
      data:
        task: task.data
    ).done (task) =>
      @data = _.filter @data, (t) ->
        t.id != task.id
      @data.push new Task(task)
      @reorder()
      @trigger @data

  destroy: (id) ->
    @data = _.filter @data, (task) -> task.id != id
    @trigger @data

    $.ajax
      method: 'DELETE'
      dataType: 'json'
      url: "/api/tasks/#{id}"

  setParent: (childId, parentId) ->
    childTask = @get childId
    childTask.setParentId parentId
    @trigger @data

    $.ajax(
      method: 'PUT'
      dataType: 'json'
      url: "/api/tasks/#{childId}"
      data:
        task:
          parent_id: parentId
    )

