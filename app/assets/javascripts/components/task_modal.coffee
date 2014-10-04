Reflux = require 'reflux'
{div, span, h4, option} = React.DOM
{Button, Modal, Label, Input} = require 'react-bootstrap'
{ClickToEditText} = require '../components/utils'
TaskListItem = require './task_list_item'
TaskAction = require '../actions/tasks'
WorkerAction = require '../actions/workers'
taskStore = require '../stores/tasks'
workerStore = require '../stores/workers'

Field = React.createClass
  displayName: 'Field'
  render: ->
    label = @props.label
    value = @props.value?.toString() or ''

    div {},
      h4 {}, label
      @transferPropsTo(ClickToEditText({}, value))

ClickToSelectWorker = React.createClass
  displayName: 'ClickToSelectWorker'

  getInitialState: ->
    currentWorkerId: @props.currentWorkerId
    editMode: false

  onChange: ->
    value = @refs.select.getValue()
    workerId = parseInt value, 10
    workerId = null if isNaN workerId
    @props.onChange workerId

  handleClick: -> @setState editMode: true
  handleBlur: -> @setState editMode: false

  render: ->
    if @state.editMode
      options = @props.workers.map (worker) ->
        option {key: worker.id, value: worker.id}, worker.getName()
      options.unshift option({key: 0, value: 'null'}, 'null (Please Select One)')

      Input {
        ref: 'select'
        type: 'select'
        onChange: @onChange
        value: @props.currentWorkerId
      }, options
    else
      worker = _.find @props.workers, (worker) => worker.id == @props.currentWorkerId
      span {
        onClick: @handleClick
        onBlur: @handleBlur
      }, worker?.getName() or '(null)'

TaskModal = React.createClass
  displayName: 'TaskModal'
  mixins: [Reflux.ListenerMixin]

  componentDidMount: ->
    @listenTo workerStore, @onWorkerStoreChange
    WorkerAction.index()

  getInitialState: ->
    workers: []

  onWorkerStoreChange: (workers) ->
    @setState workers: workers

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

  handleDurationChange: (dStr) ->
    task = @props.task
    duration = parseInt dStr, 10
    task.setDuration if isNaN duration
      null
    else
      duration
    TaskAction.update task

  handlePriorityChange: (pStr) ->
    task = @props.task
    priority = parseInt(pStr, 10)
    if isNaN(priority)
      task.setPriority null
    else
      task.setPriority priority
    TaskAction.update task

  handleWorkerSelectChange: (workerId) ->
    task = @props.task
    task.setAssignedWorkerId workerId
    TaskAction.update task

  handleDependenciesChange: (dStr) ->
    task = @props.task
    task.setDependenciesString dStr
    TaskAction.update task

  render: ->
    task = @props.task

    dependencyList = task.getDependencies().map (depId) ->
      t = taskStore.get depId

      div {
        key: depId
        className: 'title-bar'
      },
        TaskListItem {task: t}

    Modal {
      title: "##{task.id}"
      onRequestHide: @props.onRequestHide
    },
      div {className: 'modal-body'},
        Field {label: 'Task Name:', value: task.getName(), onChange: @handleNameChange}
        Field {
          label: 'Duration:'
          value: task.getDuration()
          enableEmpty: true
          defaultValue: '(null)'
          onChange: @handleDurationChange
        }
        Field {
          label: 'Milestone:'
          value: task.getMilestone()
          enableEmpty: true
          defaultValue: '(null)'
          onChange: @handleMilestoneChange
        }
        Field {
          label: 'Priority:'
          value: task.getPriority()
          enableEmpty: true
          defaultValue: '(null)'
          onChange: @handlePriorityChange
        }
        h4 {}, 'Assigned To:'
        ClickToSelectWorker {
          workers: @state.workers
          currentWorkerId: task.getAssignedWorkerId()
          onChange: @handleWorkerSelectChange
        }
        Field {
          label: 'Dependencies:'
          value: task.getDependenciesString()
          enableEmpty: true
          defaultValue: '(null)'
          onChange: @handleDependenciesChange
        }
        div {
          style:
            marginTop: '10px'
        }, dependencyList
      div {className: 'modal-footer'},
        Button {
          onClick: @props.onRequestHide
        }, 'Close'

module.exports = TaskModal
