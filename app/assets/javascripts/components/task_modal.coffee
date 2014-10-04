{div, span, h4} = React.DOM
{Button, Modal, Label} = require 'react-bootstrap'
{ClickToEditText} = require '../components/utils'
TaskListItem = require './task_list_item'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'

Field = React.createClass
  displayName: 'Field'
  render: ->
    label = @props.label
    value = @props.value?.toString() or ''

    div {},
      h4 {}, label
      @transferPropsTo(ClickToEditText({}, value))

TaskModal = React.createClass
  displayName: 'TaskModal'

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
          defaultValue: '(Unssign)'
          onChange: @handleDurationChange
        }
        Field {
          label: 'Milestone:'
          value: task.getMilestone()
          enableEmpty: true
          defaultValue: '(empty)'
          onChange: @handleMilestoneChange
        }
        Field {
          label: 'Priority:'
          value: task.getPriority()
          enableEmpty: true
          defaultValue: '(empty)'
          onChange: @handlePriorityChange
        }
        Field {
          label: 'Dependencies:'
          value: task.getDependenciesString()
          enableEmpty: true
          defaultValue: '(empty)'
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
