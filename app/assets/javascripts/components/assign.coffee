_ = require 'lodash'
Reflux = require 'reflux'
{div, h1, thead, tbody, tr, th, td} = React.DOM
{Table} = require 'react-bootstrap'
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

Assign = React.createClass
  displayName: 'Assign'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    tasks : null
    workers : null

  componentDidMount: ->
    # refactor this to another store
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
    autoAssign = new AutoAssign moment('2014-10-06')
    # autoAssign = new AutoAssign moment()
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

    numDate = 40
    workers = @state.workers

    # date display
    header = _.map [0...numDate], (i) ->
      th {
        key: i
        style:
          width: '150px'
      }, assign.getDateFromIndex(i).format('ddd, MMM DD')

    # content
    body = _.map channels, (channel) ->
      cells = _.map [0...numDate], (date) ->
        # one day tasks in table
        list = Table {
          bordered: true
          style:
            tableLayout: 'fixed'
            margin: 0
        },
          tbody {},
            channel.tasksIndexByDay[date]?.map((t) ->
              tr {key: t.id},
                td {
                  style:
                    'word-wrap': 'break-word'
                }, t.getName()
            )

        # outer cell
        td {
          key: date
          style:
            padding: 0
        }, list

      # per worker
      tr {key: channel.id},
        # float worker name
        th {},
          div {
            style:
              'min-height': '100px'
          }, div {
              style:
                position: 'absolute'
                backgroundColor: 'white'
                border: 'gray 1px solid'
                padding: '10px'
            }, channel.name
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
