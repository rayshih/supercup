window.React = require 'react'

{Routes, Route, Link, DefaultRoute} = require 'react-router'
{Navbar, Nav} = require 'react-bootstrap'
{div, li} = React.DOM
{NavItem} = require './components/utils'
TaskList = require './components/task_list'
OrderedTaskList = require './components/ordered_task_list'
TaskTreeList = require './components/task_tree_list'

App = React.createClass
  displayName: 'App'
  render: ->
    div null,
      Navbar {},
        div {className: 'navbar-header'},
          Link {to: '/', className: 'navbar-brand'}, 'SuperCup'
        Nav {},
          NavItem {to: 'order'}, 'Order'
          NavItem {to: 'tree'}, 'Tree'
      div {className: 'container'},
        @props.activeRouteHandler()

routes = Routes {location:"history"},
  Route {path:"/", handler: App},
    DefaultRoute {handler: TaskList}
    Route {name:"order", handler: OrderedTaskList}
    Route {name:"tree", handler: TaskTreeList}

$ -> React.renderComponent routes, document.body
