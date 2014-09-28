{div, thead, tbody, th, tr, td} = React.DOM
{Table} = require 'react-bootstrap'
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
          th {className: 'col-md-3'}, 'Dependencies'
          th {className: 'col-md-1'}, 'Milestone'
          th {className: 'col-md-1'}, 'Rank'
          th {className: 'col-md-1'}, 'Priority'
      tbody {}, @props.items

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
      td {}, @props.milestone
      td {}, @props.rank
      td {}, task.getPriority()

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
      data: sorter.result
      rank: sorter.depth
      milestone: sorter.milestone

  render: ->
    listItems = @state.data.map (task) =>
      rank = @state.rank[task.id]
      milestone = @state.milestone[task.id]
      OrderedTaskListItem {key: task.id, task, rank, milestone}

    OrderedTaskListTable {items: listItems}

module.exports = OrderedTaskList
