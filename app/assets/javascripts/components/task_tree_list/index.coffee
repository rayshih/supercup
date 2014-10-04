_ = require 'lodash'
{div, span, ul, li} = React.DOM
Reflux = require 'reflux'
taskStore = require '../../stores/tasks'
TaskAction = require '../../actions/tasks'
{EnterToInputText} = require '../utils'
FilteredList = require './filtered_list'
Tree = require './tree'

sortNodes = (nodes) ->
  nodes.forEach (node) ->
    children = node.children
    if children and children.length > 0
      node.children = sortNodes children

  nodes.sort (a, b) ->
    am = a.task.getMilestone() or 10000
    bm = b.task.getMilestone() or 10000
    return am - bm if am - bm isnt 0

    aIsNested = if a.children?.length > 0 then 1 else 0
    bIsNested = if b.children?.length > 0 then 1 else 0
    return bIsNested - aIsNested if bIsNested - aIsNested isnt 0

    ap = a.task.getPriority() or -10000
    bp = b.task.getPriority() or -10000
    return bp - ap if bp - ap isnt 0

    a.task.id - b.task.id

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
    filterString = if text.length > 0 then text.toLowerCase() else null
    @setState {filterString}

  onInputEnter: (text) ->
    @setState filterString: null
    TaskAction.create name: text

  render: ->
    data = @state.data
    filterString = @state.filterString
    taskNameList = _.map data, (task) -> task.getName()

    trees = @state.trees.map (tree) ->
      Tree {key: tree.task.id, node: tree}

    div {},
      EnterToInputText
        onChange: @onInputChange
        onEnter: @onInputEnter
      FilteredList
        data: taskNameList
        filterString: filterString
      trees

module.exports = TaskTreeList

