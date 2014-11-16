{div, h3, thead, tbody, th, tr, td} = React.DOM
_ = require 'lodash'
Reflux = require 'reflux'
{Table, Button, ModalTrigger, Modal, Input} = require 'react-bootstrap'
Leaves = require './leaves'
WorkerAction = require '../../actions/workers'
workerStore = require '../../stores/workers'
{EnterToInputText} = require '../../components/utils'

WorkerModal = React.createClass
  displayName: 'WorkerModal'

  onSaveButtonClick: ->
    order = @refs.order.getValue()
    worker = @props.worker
    worker.setOrder order
    WorkerAction.update worker

    @props.onRequestHide()

  render: ->
    worker = @props.worker

    orderInput = Input {
      ref: 'order'
      type: 'number'
      addonBefore: 'order'
      defaultValue: worker.getOrder()
    }

    Modal {
      title: worker.getName()
      onRequestHide: @props.onRequestHide
    },
      div {className: 'modal-body'},
        orderInput
        Leaves {worker}
      div {className: 'modal-footer'},
        Button {
          bsStyle: 'primary'
          onClick: @onSaveButtonClick
        }, 'Save'

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
      td {}, worker.getOrder()

WorkerList = React.createClass
  displayName: 'WorkerList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    # TODO: descriptive naming
    data : []

  componentDidMount: ->
    @listenTo workerStore, @onStoreChange
    WorkerAction.index()

  onStoreChange: (data) ->
    # Leaky: data passed-in by store should be sorted
    @setState data: _.sortBy(data, (w) ->
      w.getOrder()
    )


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
            th {}, 'Order'
        tbody {}, workerRows

module.exports = WorkerList
