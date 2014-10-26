{div, span} = React.DOM
{Glyphicon, Button, ModalTrigger, Label} = require 'react-bootstrap'
TaskModal = require '../task_modal'
TaskAction = require '../../actions/tasks'
TaskListItem = require '../task_list_item'

TreeTitle = React.createClass
  displayName: 'TreeTitle'
  render: ->
    task = @props.task

    titleClassName = 'title-bar'
    titleClassName += ' title-bar-fold' if @props.hasChildren

    icon = if @props.hasChildren
      if @props.showSubtree
        Glyphicon glyph: "minus"
      else
        Glyphicon glyph: "plus"

    toggleBtn = if icon then Button {
      bsSize: 'xsmall'
      onClick: @props.onToggleButtonClick
    }, icon

    # TODO refactor it and this one is slow
    detailBtn = ModalTrigger {
      modal: TaskModal {task: @props.task}
    },
      Button {
        bsSize: 'xsmall'
      }, 'Detail'

    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @props.onDeleteButtonClick
    }, 'Delete'

    options = div {className: 'pull-right'},
      detailBtn
      ' '
      toggleBtn or deleteBtn

    div {
      className: titleClassName
      draggable: true
      onDragStart: @props.onDragStart
      onDragOver: @props.onDragOver
      onDrop: @props.onDrop
    },
      TaskListItem {task: task}
      options

Subtree = React.createClass
  displayName: 'Subtree'
  render: ->
    div {},
      div {
        className: 'indent'
        onDragOver: @props.onDragOver
        onDrop: @props.onDropToIndent
      }
      div {className: 'subtree'},
        @props.children.map (subtree) =>
          Tree {
            key: subtree.task.id
            node: subtree
            showSubtree: @props.showSubtree
          }

Tree = React.createClass
  displayName: 'Tree'
  getInitialState: ->
    showSubtree: false

  toggle: ->
    @setState showSubtree: !@state.showSubtree

  handleDragStart: (ev) ->
    task = @props.node.task
    ev.dataTransfer.setData 'childTaskId', task.id

  allowDrop: (ev) ->
    ev.preventDefault()

  handleDropOnTask: (ev) ->
    ev.preventDefault()
    task = @props.node.task
    childTaskId = parseInt ev.dataTransfer.getData('childTaskId'), 10
    return if childTaskId is task.id
    TaskAction.setParent childTaskId, task.id

  handleDropOnOther: (ev) ->
    ev.preventDefault()
    childTaskId = parseInt ev.dataTransfer.getData('childTaskId'), 10
    TaskAction.setParent childTaskId, null

  handleDeleteButtonClick: ->
    TaskAction.destroy @props.node.task.id

  render: ->
    node = @props.node
    title = node.task.getName()
    children = node.children
    hasChildren = children.length > 0

    shouldShowSubTree = @props.showSubtree or @state.showSubtree

    div {className: 'tree'},
      TreeTitle {
        task: node.task
        hasChildren: hasChildren
        showSubtree: shouldShowSubTree
        onToggleButtonClick: @toggle
        onDeleteButtonClick: @handleDeleteButtonClick
        onDragStart: @handleDragStart
        onDragOver: @allowDrop
        onDrop: @handleDropOnTask
      }
      if hasChildren and shouldShowSubTree
        Subtree {
          onDragOver: @allowDrop
          onDropToIndent: @handleDropOnOther
          showSubtree: shouldShowSubTree
        }, children

module.exports = Tree
