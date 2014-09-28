{div, tr, td} = React.DOM
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
{EnterToInputText, ClickToEditText} = require '../components/utils'
TaskListTable = require './task_list_table'

OrderedTaskListItem = React.createClass
  displayName: 'OrderedTaskListItem'

  handleNameChange: (name) ->
    task = @props.task
    task.setName name
    TaskAction.update task

  render: ->
    task = @props.task

    tr {key: @props.key},
      td {}, task.id
      td {}, ClickToEditText({onChange: @handleNameChange}, task.getName())
      td {}, task.getDependenciesString()
      td {}

OrderedTaskList = React.createClass
  displayName: 'OrderedTaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    @setState data: data

  render: ->
    listItems = @state.data.map (task) ->
      OrderedTaskListItem {key: task.id, task: task}

    div {},
      TaskListTable {items: listItems}

module.exports = OrderedTaskList
