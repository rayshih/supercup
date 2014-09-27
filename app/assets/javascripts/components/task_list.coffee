{div, thead, tbody, tr, th, td} = React.DOM
{Table, Input} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'

TaskList = React.createClass
  displayName: 'TaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    currentNewTaskName: ''
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange

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
      tr {key: i},
        td {}, i
        td {}, task.name

    div {},
      Table {},
        thead {},
          tr {},
            th {}, '#'
            th {}, 'name'
        tbody {}, listItems
      Input
        type: 'text'
        ref: 'input'
        value: @state.currentNewTaskName
        onKeyPress: @handleInputKeyPress
        onChange: @handleInputChange

module.exports = TaskList

