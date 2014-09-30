_ = require 'lodash'
{div} = React.DOM
{Glyphicon} = require 'react-bootstrap'
Reflux = require 'reflux'
taskStore = require '../stores/tasks'
TaskAction = require '../actions/tasks'

sortNodes = (nodes) ->
  nodes.forEach (node) ->
    children = node.children
    if children and children.length > 0
      node.children = sortNodes children

  _.sortBy nodes, (node) ->
    children = node.children
    if children and children.length > 0 then 0 else 1

toTrees = (list) ->
  hash = {}
  list.forEach (task) ->
    hash[task.id] = {
      task: task
      children: null
    }

  roots = []

  list.forEach (task) ->
    node = hash[task.id]
    parentId = task.getParentId()
    if parentId
      parentNode = hash[parentId]
      parentNode.children or= []
      parentNode.children.push node
    else
      roots.push node

  sortedRoots = sortNodes roots
  console.log sortedRoots

  sortedRoots

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

  render: ->
    node = @props.node
    title = node.task.getName()
    children = node.children

    titleStyle =
      "margin-top": "-1px"
      'background-color': 'white'
      border: "gray 1px solid"
      padding: "5px"
      cursor: 'pointer'
      position: 'relative'
      '-webkit-user-select': 'none'

    wrapperStyle =
      position: 'relative'

    paddingDivStyle =
      # border: 'red 1px solid' # for debugging
      top: 0
      bottom: 0
      width: '2em'
      position: 'absolute'

    subtreeStyle =
      "margin-left": "2em"

    icon = null

    if children
      if @state.showSubtree
        icon = div {className: 'pull-right'}, Glyphicon(glyph:"minus")
      else
        titleStyle['background-color'] = 'LightBlue'
        icon = div {className: 'pull-right'}, Glyphicon(glyph:"plus")

    titleDom =
      div {
        draggable: true
        onDragStart: @handleDragStart
        onDragOver: @allowDrop
        onDrop: @handleDropOnTask

        style: titleStyle
        onClick: @toggle
      }, title, icon

    subtreeDom = if children and @state.showSubtree
      div {style: wrapperStyle},
        div {
          style: paddingDivStyle
          onDragOver: @allowDrop
          onDrop: @handleDropOnOther
        }
        div {style: subtreeStyle},
          children?.map (subtree) ->
            Tree {key: subtree.task.id, node: subtree}

    div {},
      titleDom
      subtreeDom

TaskTreeList = React.createClass
  displayName: 'TaskTreeList'
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    data: []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    @setState data: toTrees(data)

  render: ->
    trees = @state.data.map (tree, i) ->
      Tree {key: i, node: tree}

    div {}, trees

module.exports = TaskTreeList

