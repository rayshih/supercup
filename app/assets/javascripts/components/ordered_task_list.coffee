{div, thead, tbody, th, tr, td} = React.DOM
{Table, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
{EnterToInputText, ClickToEditText} = require '../components/utils'
Sorter = require '../libs/sorter'

OrderedTaskListTable = React.createClass
  displayName: 'TaskListTable'
  render: ->
    Table {},
      thead {},
        tr {},
          th {className: 'col-md-1'}, '#'
          th {className: 'col-md-6'}, 'Name'
          th {className: 'col-md-2'}, 'Dependencies'
          th {className: 'col-md-1'}, 'Milestone'
          th {className: 'col-md-1'}, 'Rank'
          th {className: 'col-md-1'}, 'Priority'
          th {className: 'col-md-1'}, 'Actions'
      tbody {}, @props.items

OrderedTaskListItem = React.createClass
  displayName: 'OrderedTaskListItem'

  handleNameChange: (name) ->
    task = @props.task
    task.setName name
    TaskAction.update task

  handleHideButtonClick: ->
    @props.onHideButtonClick @props.task.id

  render: ->
    task = @props.task

    tr {key: @props.key},
      td {}, task.id
      td {}, ClickToEditText({onChange: @handleNameChange}, task.getName())
      td {}, task.getDependenciesString()
      td {}, @props.milestone
      td {}, @props.rank
      td {}, task.getPriority()
      td {},
        Button {bsSize: 'xsmall', onClick: @handleHideButtonClick}, 'hide'

OrderedTaskList = React.createClass
  displayName: 'OrderedTaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    sorter = new Sorter data
    sorter.sort()
    @setState
      hidden: []
      data: sorter.result
      rank: sorter.depth
      milestone: sorter.milestone

  handleHideButtonClick: (id) ->
    state = @state
    state.hidden.push id
    @setState state

  render: ->
    listItems = @state.data.filter((task) =>
      @state.hidden.indexOf(task.id) == -1
    ).map (task) =>
      rank = @state.rank[task.id]
      milestone = @state.milestone[task.id]
      OrderedTaskListItem {
        key: task.id,
        onHideButtonClick: @handleHideButtonClick,
        task, rank, milestone
      }

    OrderedTaskListTable {items: listItems}

module.exports = OrderedTaskList
