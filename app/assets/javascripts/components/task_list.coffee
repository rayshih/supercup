{div, thead, tbody, tr, th, td, span} = React.DOM
{Table, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
{EnterToInputText, ClickToEditText} = require '../components/utils'

TaskListItem = React.createClass
  displayName: 'TaskListItem'
  handleDeleteButtonClick: ->
    TaskAction.destroy @props.task.id

  handleNameChange: (name) ->
    task = @props.task
    task.setName name
    TaskAction.update task

  handleDependenciesChange: (dStr) ->
    task = @props.task
    task.setDependenciesString dStr
    TaskAction.update task

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
      Table {},
        thead {},
          tr {},
            th {className: 'col-md-1'}, '#'
            th {className: 'col-md-6'}, 'Name'
            th {className: 'col-md-3'}, 'Dependencies'
            th {className: 'col-md-2'}, 'Actions'
        tbody {}, listItems
      EnterToInputText
        onChange: @onInputChange
        value: @state.currentNewTaskName

module.exports = TaskList

