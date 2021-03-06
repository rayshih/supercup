{div, thead, tbody, th, tr, td, h3} = React.DOM
{Input, Table, Button, Label, ModalTrigger} = require 'react-bootstrap'
Reflux = require 'reflux'
{EnterToInputText, ClickToEditText} = require '../components/utils'
TaskModal = require './task_modal'
TaskListItem = require './task_list_item'
TaskAction = require '../actions/tasks'
taskStore = require '../stores/tasks'
Sorter = require '../libs/sorter'

OrderedTaskList = React.createClass
  displayName: 'OrderedTaskList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data : []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    sorter = new Sorter data
    sorter.sort()
    @setState
      hidden: []
      data: sorter.result
      milestone: sorter.milestone

  handleInputChange: ->
    @setState filterString: @refs.input.getValue().toLowerCase()

  handleHideButtonClick: (id) ->
    state = @state
    state.hidden.push id
    @setState state

  render: ->
    listItems = @state.data.filter((task) =>
      isntHidden = @state.hidden.indexOf(task.id) == -1

      if @state.filterString
        task.getName().toLowerCase().indexOf(@state.filterString) != -1 and
          isntHidden
      else
        isntHidden
    ).map (task) =>
      milestone = @state.milestone[task.id]

      # TODO refactor it and this one is slow
      detailBtn = ModalTrigger {
        modal: TaskModal {task: task}
      },
        Button {
          bsSize: 'xsmall'
        }, 'Detail'

      div {className: 'title-bar', key: task.id},
        TaskListItem {task: task}
        div {className: 'pull-right'},
          Label({bsStyle: 'primary'}, "M#{milestone}")
          ' ', detailBtn

    div {},
      h3 {}, 'Filter:'
      Input {
        type: 'text'
        ref: 'input'
        value: @state.filterString
        onChange: @handleInputChange
      }
      listItems

module.exports = OrderedTaskList
