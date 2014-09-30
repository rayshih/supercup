_ = require 'lodash'
{div, span, ul, li} = React.DOM
{Glyphicon, Button} = require 'react-bootstrap'
Reflux = require 'reflux'
taskStore = require '../stores/tasks'
TaskAction = require '../actions/tasks'
{EnterToInputText} = require '../components/utils'

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
  sortedRoots

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
    # @state.isHoverHandle

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

    titleStyle =
      "margin-top": "-1px"
      'background-color': 'white'
      border: "gray 1px solid"
      padding: "5px"
      position: 'relative'

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
        icon = Glyphicon(glyph:"minus")
      else
        titleStyle['background-color'] = 'LightBlue'
        icon = Glyphicon(glyph:"plus")

    deleteBtn = Button {
      bsStyle: 'danger'
      bsSize: 'xsmall'
      onClick: @handleDeleteButtonClick
    }, 'Delete'

    options = div {className: 'pull-right'}, icon or deleteBtn

    titleDom =
      div {
        draggable: true
        onDragStart: @handleDragStart
        onDragOver: @allowDrop
        onDrop: @handleDropOnTask

        style: titleStyle
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
    trees: []

  componentDidMount: ->
    @listenTo taskStore, @onStoreChange
    TaskAction.index()

  onStoreChange: (data) ->
    @setState
      data: data
      trees: toTrees(data)

  onInputChange: (text = '') ->
    state = @state
    state.filterString = if text.length > 0 then text.toLowerCase() else null

    @setState state

  onInputEnter: (text) ->
    @setState filterString: null
    TaskAction.create name: text

  render: ->
    data = @state.data

    filterString = @state.filterString
    hintList = if filterString
      ul {}, _.chain(data).filter((task) ->
        task.getName().toLowerCase().indexOf(filterString) != -1
      ).map((task) ->
        li {key: task.id}, task.getName()
      ).value()
    else null

    trees = @state.trees.map (tree, i) ->
      Tree {key: i, node: tree}

    div {},
      EnterToInputText
        onChange: @onInputChange
        onEnter: @onInputEnter
        value: @state.currentNewTaskName
      hintList,
      trees

module.exports = TaskTreeList

