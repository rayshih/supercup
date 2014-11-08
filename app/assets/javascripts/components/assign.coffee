_ = require 'lodash'
Reflux = require 'reflux'
{div, h1, thead, tbody, tr, th, td} = React.DOM
{Table, Label} = require 'react-bootstrap'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
WorkerAction = require '../actions/workers'
workerStore = require '../stores/workers'
LeaveAction = require '../actions/leaves'
leaveStore = require '../stores/leaves'
Sorter = require '../libs/sorter'
{AutoAssign, Channel} = require '../libs/auto_assign'
moment = require 'moment'

# TODO Refactor this file
# TODO display leave
# ----- Tomorrow -----
# TODO 3: input all data (3 hours
# TODO 4: still need a output format for excel (optional

TaskView = React.createClass
  displayName: 'TaskView'
  render: ->
    t = @props.task
    tdStyle = wordWrap: 'break-word'

    milestone = t.getMilestone()
    milestoneLabel = if milestone then Label {bsStyle: 'primary'}, "M#{milestone}"

    tr {key: t.id},
      td {style: tdStyle},
        milestoneLabel
        ' '
        Label {}, "##{t.id}"
        ' '
        "#{t.getName()}"

ChannelNameView = React.createClass
  displayName: 'ChannelNameView'
  render: ->
    name = @props.name
    div {style: minHeight: '100px'},
      div {
        style:
          position: 'absolute'
          backgroundColor: 'white'
          border: 'gray 1px solid'
          padding: '10px'
      }, name

ChannelTasksView = React.createClass
  displayName: 'ChannelTasksView'
  render: ->
    tasks = @props.tasks
    # one day tasks in table
    list = Table {
      bordered: true
      style:
        tableLayout: 'fixed'
        margin: 0
    },
      tbody {},
        tasks?.map (t) ->
          TaskView {
            key: t.id
            task: t
          }

    # outer cell
    td {
      style:
        padding: 0
    }, list


Assign = React.createClass
  displayName: 'Assign'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    tasks : null
    workers : null

  componentDidMount: ->
    # TODO refactor this to another store
    @listenTo taskStore, @onTaskStoreChange
    @listenTo workerStore, @onWorkerStoreChange
    @listenTo leaveStore, @onLeaveStoreChange
    TaskAction.index()
    WorkerAction.index()
    LeaveAction.index()

  onTaskStoreChange: (data) ->
    sorter = new Sorter data
    sorter.sort()
    @setState tasks: sorter.result

  onWorkerStoreChange: (workers) -> @setState {workers}
  onLeaveStoreChange: (leaves) -> @setState {leaves} # for trigger render TODO refactor

  assign: ->
    tasks = @state.tasks
    workers = @state.workers
    autoAssign = new AutoAssign moment('2014-11-10')
    # autoAssign = new AutoAssign moment() # from now
    return autoAssign if not workers or workers.length == 0 or not tasks

    channels = (for w in workers
      c = new Channel(w.id, w.getName())
      for l in leaveStore.findByWorkerId(w.id)
        c.addLeave l
      c
    )
    channels.push new Channel(100, 'Milestone')

    for c in channels
      autoAssign.addChannel c

    for t in tasks
      autoAssign.assignTask t

    autoAssign

  render: ->
    assign = @assign()
    channels = assign.channels

    numDate = 70
    workers = @state.workers

    # date display
    header = _.map [0...numDate], (i) ->
      th {
        key: i
        style:
          width: '150px'
      }, assign.getDateFromIndex(i).format('ddd, MMM DD')

    # content
    body = _(channels).sortBy((c) ->
      workerStore.get(c.id)?.getOrder()
    ).map (channel) ->
      cells = _.map [0...numDate], (date) ->
        ChannelTasksView {
          key: date
          tasks: channel.tasksIndexByDay[date]
        }

      # per worker
      tr {key: channel.id},
        # float worker name
        th {}, ChannelNameView {name: channel.name}
        # task nested cells
        cells

    # wrapper
    div {},
      h1 {}, 'Assign'
      div {
        style:
          overflow: 'scroll'
      },
        # table
        Table {
          bordered: true
          style:
            'table-layout': 'fixed'
        },
          # header
          thead {},
            tr {},
              th {
                style:
                  width: '150px'
              }, header
          # body
          tbody {}, body


module.exports = Assign
