{div, thead, tbody, tr, th, td, span} = React.DOM
{Table, Input, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'

ClickToEditText = React.createClass
  displayName: 'ClickToEditText'

  getInitialState: ->
    editMode: false
    current: @props.children

  handleClick: ->
    @setState
      editMode: true
      current: @props.children

  handleInputChange: (e) ->
    @setState
      editMode: true
      current: @refs.input.getValue()

  handleInputKeyPress: (e) ->
    return if e.key isnt "Enter"
    @finishEdit()

  finishEdit: ->
    current = @refs.input.getValue()
    @props.onChange current
    @setState
      editMode: false
      current: current

  render: ->
    if @state.editMode
      Input
        type: 'text'
        ref: 'input'
        value: @state.current
        onKeyPress: @handleInputKeyPress
        onChange: @handleInputChange
        onBlur: @finishEdit
    else
      span {onClick: @handleClick}, @state.current

TaskListItem = React.createClass
  displayName: 'TaskListItem'
  handleDeleteButtonClick: ->
    TaskAction.destroy @props.task.id

  handleChange: (name) ->
    task = @props.task
    task.name = name
    TaskAction.update task

  render: ->
    task = @props.task

    tr {key: @props.key},
        td {}, task.id
        td {}, ClickToEditText({onChange: @handleChange}, task.name)
        td {},
          Button {bsStyle: 'danger', bsSize: 'xsmall', onClick: @handleDeleteButtonClick},
            'Delete'

TaskList = React.createClass
  displayName: 'TaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    currentNewTaskName: ''
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange

    TaskAction.index()

  onStoreChange: (data) ->
    @setState
      currentNewTaskName: @state.currentNewTaskName
      data: data

  handleInputChange: (e) ->
    @setState
      currentNewTaskName: @refs.input.getValue()
      data: @state.data

  handleInputKeyPress: (e) ->
    return if e.key isnt "Enter"

    newTaskName = @refs.input.getValue()
    TaskAction.create name: newTaskName

    @setState
      currentNewTaskName: ''
      data: @state.data

  render: ->
    listItems = @state.data.map (task, i) ->
      TaskListItem {key: i, task: task}

    div {},
      Table {},
        thead {},
          tr {},
            th {}, '#'
            th {}, 'Name'
            th {}, 'Actions'
        tbody {}, listItems
      Input
        type: 'text'
        ref: 'input'
        value: @state.currentNewTaskName
        onKeyPress: @handleInputKeyPress
        onChange: @handleInputChange

module.exports = TaskList

