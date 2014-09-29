{div} = React.DOM

Tree = React.createClass
  displayName: 'Tree'
  getInitialState: ->
    showSubtree: true

  toggle: ->
    @setState showSubtree: !@state.showSubtree

  render: ->
    node = @props.node

    titleStyle =
      "margin-top": "-1px"
      border: "gray 1px solid"
      padding: "5px"
      cursor: 'pointer'

    subtreeStyle =
      "margin-left": "2em"
      display: if @state.showSubtree then 'block' else 'none'

    titleDom =
      div {
        style: titleStyle
        onClick: @toggle
      }, node.title

    subtreeDom =
      div {style: subtreeStyle},
        node.children?.map (subtree) -> Tree {node: subtree}

    div {},
      titleDom
      subtreeDom

TaskTreeList = React.createClass
  displayName: 'TaskTreeList'
  render: ->
    data =
      title: 'title 1'
      children: [
        {title: 'title 2'}
        {
          title: 'title 3'
          children: [
            {title: 'title 4'}
            {title: 'title 5'}
          ]
        }
        {title: 'title 6'}
      ]

    Tree {node: data}

module.exports = TaskTreeList

