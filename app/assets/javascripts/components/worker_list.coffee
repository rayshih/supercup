{div, h3, thead, tbody, th, tr, td} = React.DOM
Reflux = require 'reflux'
{Table, Button} = require 'react-bootstrap'
WorkerAction = require '../actions/workers'
workerStore = require '../stores/workers'
{EnterToInputText} = require '../components/utils'

WorkerRow = React.createClass
  displayName: 'WorkerRow'

  handleClick: ->
    WorkerAction.destroy @props.worker.id

  render: ->
    worker = @props.worker
    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @handleClick
    }, 'Delete'

    tr {key: worker.id},
      td {}, worker.id
      td {}, worker.getName()
      td {}, deleteBtn

WorkerList = React.createClass
  displayName: 'WorkerList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data : []

  componentDidMount: ->
    @listenTo workerStore, @onStoreChange
    WorkerAction.index()

  onStoreChange: (data) ->
    @setState data: data

  onInputEnter: (name) ->
    WorkerAction.create name: name

  render: ->
    workerRows = @state.data.map (worker) ->
      WorkerRow key: worker.id, worker: worker

    div {},
      h3 {}, 'Worker List'
      EnterToInputText onEnter: @onInputEnter
      Table {},
        thead {},
          tr {},
            th {}, '#'
            th {}, 'Name'
            th {}, 'Actions'
        tbody {}, workerRows

module.exports = WorkerList
