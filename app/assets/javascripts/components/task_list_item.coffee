{span} = React.DOM
{Label} = require 'react-bootstrap'

TaskListItem = React.createClass
  displayName: 'TakeListitem'
  render: ->
    task = @props.task

    taskName = task.getName()
    taskName = taskName.substring(0, 50) + '...' if taskName.length > 50
    milestone = task.getMilestone()
    priority = task.getPriority()
    duration = task.getDuration()

    span {className: 'title'},
      Label {}, "##{task.id}"
      ' ', taskName
      ' ', if milestone then Label {bsStyle: 'primary'}, "M#{milestone}"
      ' ', if priority then Label {bsStyle: 'warning'}, "P#{priority}"
      ' ', if duration then Label {bsStyle: 'info'}, "#{duration}H"

module.exports = TaskListItem
