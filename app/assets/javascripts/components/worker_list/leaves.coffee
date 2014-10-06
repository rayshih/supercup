{div, h2, h3, h4, ul, li} = React.DOM
Reflux = require 'reflux'
{Table, Input, Button} = require 'react-bootstrap'
LeaveAction = require '../../actions/leaves'
leaveStore = require '../../stores/leaves'
Leave = require '../../models/leave'

LeaveItem = React.createClass
  displayName: 'LeavesItem'
  handleDeleteBtnClick: ->
    LeaveAction.destroy @props.leave.id

  render: ->
    leave = @props.leave
    display = if leave.getEndDate()
      "#{leave.getStartDate()}~#{leave.getEndDate()}"
    else
      "#{leave.getStartDate()}, #{leave.getHours()} hours"

    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @handleDeleteBtnClick
    }, 'Delete'

    li {},
      display
      ' '
      deleteBtn

LeaveList = React.createClass
  displayName: 'LeavesList'
  render: ->
    leaves = @props.leaves?.map (l) ->
      LeaveItem {key: l.id, leave: l}

    div {},
      h3 {}, 'Leaves'
      ul {}, leaves

NewLeave = React.createClass
  displayName: 'NewLeave'
  handleAddButtonClick: ->
    workerId = @props.worker.id
    startDate = @refs.startDateInput.getValue()
    endDate = @refs.endDateInput.getValue()
    hours = @refs.hoursInput.getValue()
    LeaveAction.create new Leave(
      workerId
      startDate
      endDate
      hours
    )

  render: ->
    div {},
      h3 {}, 'Add Leave'
      div {},
        Input {
          ref: 'startDateInput'
          type: 'date'
          addonBefore: 'start date'
        }
        Input {
          ref: 'endDateInput'
          type: 'date'
          addonBefore: 'end date'
        }
        Input {
          ref: 'hoursInput'
          type: 'number'
          addonAfter: 'hours'
        }
        Button {
          bsStyle: 'primary'
          onClick: @handleAddButtonClick
        }, 'Add'

Leaves = React.createClass
  displayName: 'Leaves'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    leaves: null

  componentDidMount: ->
    @listenTo leaveStore, @onStoreChange
    LeaveAction.index()

  onStoreChange: (data) ->
    worker = @props.worker
    leaves = leaveStore.findByWorkerId worker.id
    @setState {leaves}

  render: ->
    worker = @props.worker
    div {},
      LeaveList {leaves: @state.leaves}
      NewLeave {worker}

module.exports = Leaves
