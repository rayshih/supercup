_ = require 'lodash'
Reflux = require 'reflux'
{div, h1, thead, tbody, tr, th, td} = React.DOM
{Table} = require 'react-bootstrap'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
WorkerAction = require '../actions/workers'
workerStore = require '../stores/workers'
Sorter = require '../libs/sorter'
{AutoAssign, Channel} = require '../libs/auto_assign'
moment = require 'moment'

worker = [
  'Carlos'
  '200'
  'Ray'
]

s = (workerId, name, begin, end) ->
  end or= begin

  {
    workerId: workerId
    name: name
    begin: begin
    end: end
  }

schedules = [
  s 0, 'Comment on Spot Overview (old compatible)', 0, 19
  s 0, 'Tag Management', 0
  s 0, 'Tuning UI With WebApp (pricing)', 1
  s 0, 'apple store screen shot', 1

  s 1, 'fix auth bug', 0
  s 1, 'complete PDF', 0, 1
  s 1, 'bug fix', 1

  s 2, 'Comment on Spot Overview (old compatible)', 3, 7
]

convert = (s) ->
  ({workerId: s.workerId, name: s.name, date: i} for i in [s.begin..s.end])

# TODO    Refactor this file
# TODO    Redesign algorithm
# TODO 2: convert tasks duration to (start, end) "day" pair (2 hours
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
    @listenTo taskStore, @onStoreChange
    @listenTo workerStore, @onWorkerStoreChange
    TaskAction.index()
    WorkerAction.index()

  onStoreChange: (data) ->
    sorter = new Sorter data
    sorter.sort()
    @setState tasks: sorter.result

  onWorkerStoreChange: (workers) ->
    @setState {workers}

  assign: ->
    tasks = @state.tasks
    workers = @state.workers
    return [] if not workers or workers.length == 0 or not tasks

    channels = (new Channel(w.id, w.getName()) for w in workers)
    channels.push new Channel(100, 'Milestone')

    autoAssign = new AutoAssign
    for c in channels
      autoAssign.addChannel c

    for t in tasks
      autoAssign.assignTask t

    hash = {}
    for c in channels
      hash[c.id] = c
    hash

  render: ->
    channels = @assign()

    numDate = 40
    workers = @state.workers

    # date display
    header = _.map [0...numDate], (i) ->
      th {
        key: i
        style:
          width: '150px'
      }, moment().add(i, 'day').format('ddd, MMM DD')

    # week end offset
    weekDay = moment().isoWeekday()
    offset = if weekDay > 5 then 8 - weekDay else 0

    # content
    body = _.map channels, (channel) ->
      cells = _.map [0...numDate], (date) ->
        index = date - offset
        index = Math.floor(index / 7) * 5 + index % 7

        # one day tasks in table
        list = Table {
          bordered: true
          style:
            tableLayout: 'fixed'
            margin: 0
        },
        if moment().add(date, 'days').isoWeekday() <= 5
          channel.tasksIndexByDay[index]?.map((t, i) ->
            tr {key: i},
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
