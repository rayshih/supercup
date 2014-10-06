{div, h3, thead, tbody, th, tr, td} = React.DOM
Reflux = require 'reflux'
{Table, Button, ModalTrigger, Modal} = require 'react-bootstrap'
Leaves = require './leaves'
WorkerAction = require '../../actions/workers'
workerStore = require '../../stores/workers'
{EnterToInputText} = require '../../components/utils'

WorkerModal = React.createClass
  displayName: 'WorkerModal'
  render: ->
    worker = @props.worker
    Modal {
      title: worker.getName()
      onRequestHide: @props.onRequestHide
    },
      div {className: 'modal-body'},
        Leaves {worker}
      div {className: 'modal-footer'},
        Button {
          onClick: @props.onRequestHide
        }, 'Close'

WorkerRow = React.createClass
  displayName: 'WorkerRow'

  # handleClick: ->
  #   WorkerAction.destroy @props.worker.id

  render: ->
    worker = @props.worker
    editBtn = ModalTrigger {
      modal: WorkerModal {worker}
    }, Button {
        bsSize: 'xsmall'
        onClick: @handleClick
      }, 'Edit'

    tr {key: worker.id},
      td {}, worker.id
      td {}, worker.getName()
      td {}, editBtn

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
