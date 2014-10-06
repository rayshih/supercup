{div, h2, h3, h4} = React.DOM
{Input, Button} = require 'react-bootstrap'

LeaveItem = React.createClass
  displayName: 'LeavesItem'
  render: ->

LeaveList = React.createClass
  displayName: 'LeavesList'
  render: ->
    div {}, 'leave list'

NewLeave = React.createClass
  displayName: 'NewLeave'
  render: ->
    div {},
      h3 {}, 'Add Leave'
      div {},
        Input {
          type: 'text'
          addonBefore: 'start date'
        }
        Input {
          type: 'text'
          addonBefore: 'end date'
        }
        Input {
          type: 'text'
          addonAfter: 'hours'
        }
        Button {
          bsStyle: 'primary'
        }, 'Add'

Leaves = React.createClass
  displayName: 'Leaves'
  render: ->
    div {},
      LeaveList {}
      NewLeave {}

module.exports = Leaves
