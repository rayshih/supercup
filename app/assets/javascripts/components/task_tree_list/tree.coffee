{div, span} = React.DOM
{Glyphicon, Button} = require 'react-bootstrap'
TaskAction = require '../../actions/tasks'

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

  handleMouseOverHandle: ->
    @setState isHoverHandle: true

  handleMouseOutHandle: ->
    @setState isHoverHandle: false

  render: ->
    node = @props.node
    title = node.task.getName()
    children = node.children

    titleClassName = 'title'
    icon = null
    if children
      if @state.showSubtree
        icon = Glyphicon(glyph:"minus")
      else
        titleClassName += ' title-fold'
        icon = Glyphicon(glyph:"plus")

    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @handleDeleteButtonClick
    }, 'Delete'

    options = div {className: 'pull-right'}, icon or deleteBtn

    titleDom =
      div {
        className: titleClassName

        draggable: true
        onDragStart: @handleDragStart
        onDragOver: @allowDrop
        onDrop: @handleDropOnTask
        onClick: @toggle
      },
        Button {
          bsSize: 'xsmall'
          onMouseOver: @handleMouseOverHandle
          onMouseOut: @handleMouseOutHandle
        }, Glyphicon(glyph: "align-justify")
        span {
          style:
            'margin-left': '7px'
        }, title
        options

    subtreeDom = if children and @state.showSubtree
      div {},
        div {
          className: 'indent'
          onDragOver: @allowDrop
          onDrop: @handleDropOnOther
        }
        div {className: 'subtree'},
          children?.map (subtree) ->
            Tree {key: subtree.task.id, node: subtree}

    div {className: 'tree'},
      titleDom
      subtreeDom

module.exports = Tree
