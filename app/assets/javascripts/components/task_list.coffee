{div, thead, tbody, tr, th, td, span, ul, li, h3} = React.DOM
{Table, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
{EnterToInputText, ClickToEditText} = require '../components/utils'

TaskListTable = React.createClass
  displayName: 'TaskListTable'
  render: ->
    Table {},
      thead {},
        tr {},
          th {className: 'col-md-1'}, '#'
          th {className: 'col-md-6'}, 'Name'
          th {className: 'col-md-2'}, 'Dependencies'
          th {className: 'col-md-1'}, 'Milestone'
          th {className: 'col-md-1'}, 'Priority'
          th {className: 'col-md-1'}, 'Actions'
      tbody {}, @props.items

TaskListItem = React.createClass
  displayName: 'TaskListItem'

  handleNameChange: (name) ->
    task = @props.task
    task.setName name
    TaskAction.update task

  handleMilestoneChange: (mStr) ->
    task = @props.task
    milestone = parseInt(mStr, 10)
    if isNaN(milestone)
      task.setMilestone null
    else
      task.setMilestone milestone
    TaskAction.update task

  handlePriorityChange: (pStr) ->
    task = @props.task
    priority = parseInt(pStr, 10)
    if isNaN(priority)
      task.setPriority null
    else
      task.setPriority priority
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
      td {}, ClickToEditText {
        enableEmpty: true
        onChange: @handleDependenciesChange
        defaultValue: '(empty)'
      }, task.getDependenciesString()
      td {}, ClickToEditText {
        enableEmpty: true
        onChange: @handleMilestoneChange
        defaultValue: '(empty)'
      }, task.getMilestone()?.toString()
      td {}, ClickToEditText {
        enableEmpty: true
        onChange: @handlePriorityChange
        defaultValue: '(empty)'
      }, task.getPriority()?.toString()
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

  onInputChange: (text = '') ->
    state = @state
    state.filterString = if text.length > 0 then text.toLowerCase() else null

    @setState state

  onInputEnter: (text) ->
    TaskAction.create name: text
    @setState data: @state.data

  render: ->
    data = @state.data

    filterString = @state.filterString
    hintList = if filterString
      ul {}, _.chain(data).filter((task) ->
        task.getName().toLowerCase().indexOf(filterString) != -1
      ).take(5).map((task) ->
        li {key: task.id}, task.getName()
      ).value()
    else null

    listItems = data.map (task) ->
      TaskListItem {key: task.id, task: task}

    div {},
      h3 {}, 'Insert new Task:'
      EnterToInputText
        onChange: @onInputChange
        onEnter: @onInputEnter
        value: @state.currentNewTaskName
      hintList,
      TaskListTable {items: listItems}

module.exports = TaskList

