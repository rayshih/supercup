_ = require 'lodash'
Reflux = require 'reflux'
{span} = React.DOM
{Label} = require 'react-bootstrap'
WorkerAction = require '../actions/workers'
workerStore = require '../stores/workers'

TaskListItem = React.createClass
  displayName: 'TakeListitem'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    workers: []

  onWorkerStoreChange: (workers) ->
    @setState workers: workers

  componentDidMount: ->
    @listenTo workerStore, @onWorkerStoreChange
    WorkerAction.index()

  render: ->
    task = @props.task

    taskName = task.getName()
    taskName = taskName.substring(0, 50) + '...' if taskName.length > 50
    milestone = task.getMilestone()
    priority = task.getPriority()
    duration = task.getDuration()
    workerId = task.getAssignedWorkerId()
    worker = _.find @state.workers, (worker) -> worker.id is workerId

    span {className: 'title'},
      Label {}, "##{task.id}"
      ' ', taskName
      ' ', if milestone then Label {bsStyle: 'primary'}, "M#{milestone}"
      ' ', if priority then Label {bsStyle: 'warning'}, "P#{priority}"
      ' ', if duration then Label {bsStyle: 'info'}, "#{duration}H"
      ' ', if worker then Label {}, worker.getName()

module.exports = TaskListItem
