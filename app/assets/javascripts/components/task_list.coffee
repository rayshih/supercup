{div, thead, tbody, tr, th, td} = React.DOM
{Table, Input} = require 'react-bootstrap'

TaskList = React.createClass
  displayName: 'TaskList'

  getInitialState: ->
    currentNewTaskName: ''
    data : [
      {name: 'test1'}
      {name: 'test2'}
      {name: 'test3'}
      {name: 'test4'}
    ]

  handleInputChange: (e) ->
    @setState
      currentNewTaskName: @refs.input.getValue()
      data: @state.data

  handleInputKeyPress: (e) ->
    return if e.key isnt "Enter"

    input = @refs.input
    newTaskName = input.getValue()
    data = @state.data

    data.push name: newTaskName
    @setState
      currentNewTaskName: ''
      data: data

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

