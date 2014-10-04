{div, span} = React.DOM
{Glyphicon, Button} = require 'react-bootstrap'
TaskAction = require '../../actions/tasks'

TreeTitle = React.createClass
  displayName: 'TreeTitle'
  render: ->
    titleClassName = 'title'
    icon = null
    if @props.hasChildren
      if @props.showSubtree
        icon = Glyphicon(glyph:"minus")
      else
        titleClassName += ' title-fold'
        icon = Glyphicon(glyph:"plus")

    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @props.onDeleteButtonClick
    }, 'Delete'

    options = div {className: 'pull-right'}, icon or deleteBtn

    div {
      className: titleClassName

      draggable: true
      onDragStart: @props.onDragStart
      onDragOver: @props.onDragOver
      onDrop: @props.onDrop
      onClick: @props.onClick
    },
      Button {
        bsSize: 'xsmall'
      }, Glyphicon(glyph: "align-justify")
      span {
        style:
          'margin-left': '7px'
      }, @props.children
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
        @props.children.map (subtree) ->
          Tree {key: subtree.task.id, node: subtree}

Tree = React.createClass
  displayName: 'Tree'
  getInitialState: ->
    showSubtree: false
    isHoverHandle: false

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

    div {className: 'tree'},
      TreeTitle {
        hasChildren: children
        showSubtree: @state.showSubtree
        onClick: @toggle
        onDeleteButtonClick: @handleDeleteButtonClick
        onDragStart: @handleDragStart
        onDragOver: @allowDrop
        onDrop: @handleDropOnTask
      }, title
        if children and @state.showSubtree
          Subtree {
            onDragOver: @allowDrop
            onDropToIndent: @handleDropOnOther
          }, children

module.exports = Tree
