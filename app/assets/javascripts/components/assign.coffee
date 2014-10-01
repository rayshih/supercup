_ = require 'lodash'
{div, h1, thead, tbody, tr, th, td} = React.DOM
{Table} = require 'react-bootstrap'

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

Assign = React.createClass
  displayName: 'Assign'
  getInitialState: ->
    data = _.chain(schedules).map(convert).flatten().value()
    data: data

  render: ->
    data = @state.data

    numDate = 20
    numWorker = 3

    header = _.map [1..numDate], (i) ->
      th {
        key: i
        style:
          width: '150px'
      }, i

    body = _.map [0...numWorker], (workerId) ->
      cells = _.map [0...numDate], (date) ->
        list = Table {
          bordered: true
          style:
            margin: 0
        }, _.chain(data).filter((s) ->
            s.workerId == workerId and s.date == date
          ).map((s, i) ->
            tr {key: i}, td {}, s.name
          ).value()

        td {
          key: date
          style:
            padding: 0
        }, list

      tr {},
        th {},
          div {
            style:
              position: 'absolute'
              backgroundColor: 'white'
              border: 'gray 1px solid'
              padding: '10px'
          }, worker[workerId]
        cells

    div {},
      h1 {}, 'Assign'
      div {
        style:
          overflow: 'scroll'
      },
        Table {
          bordered: true
          style:
            'table-layout': 'fixed'
        },
          thead {},
            tr {},
              th {
                style:
                  width: '150px'
              }, header
          tbody {},
            tr {}, body


module.exports = Assign
