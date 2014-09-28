{div, thead, tbody, tr, th, td, span} = React.DOM
{Table, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
{EnterToInputText, ClickToEditText} = require '../components/utils'
TaskListTable = require './task_list_table'

TaskListItem = React.createClass
  displayName: 'TaskListItem'

  handleNameChange: (name) ->
    task = @props.task
    task.setName name
    TaskAction.update task

  handleDependenciesChange: (dStr) ->
    task = @props.task
    task.setDependenciesString dStr
    TaskAction.update task

  handleDeleteButtonClick: ->
    TaskAction.destroy @props.task.id

  render: ->
    task = @props.task

    tr {key: @props.key},
      td {}, task.id
      td {}, ClickToEditText({onChange: @handleNameChange}, task.getName())
      td {}, ClickToEditText
        enableEmpty: true
        onChange: @handleDependenciesChange,
        defaultValue: '(empty)'
        task.getDependenciesString()
      td {},
        Button {bsStyle: 'danger', bsSize: 'xsmall', onClick: @handleDeleteButtonClick},
          'Delete'

TaskList = React.createClass
  displayName: 'TaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    @setState data: data

  onInputChange: (text) ->
    TaskAction.create name: text
    @setState data: @state.data

  render: ->
    listItems = @state.data.map (task) ->
      TaskListItem {key: task.id, task: task}

    div {},
      TaskListTable {items: listItems}
      EnterToInputText
        onChange: @onInputChange
        value: @state.currentNewTaskName

module.exports = TaskList

