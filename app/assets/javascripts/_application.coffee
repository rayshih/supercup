window.React = require 'react'

{Routes, Route, Link, DefaultRoute} = require 'react-router'
{Navbar, Nav} = require 'react-bootstrap'
{div, li} = React.DOM
{NavItem} = require './components/utils'
OrderedTaskList = require './components/ordered_task_list'
TaskTreeList = require './components/task_tree_list/index'
Assign = require './components/assign'
WorkerList = require './components/worker_list/index'

App = React.createClass
  displayName: 'App'
  render: ->
    div null,
      Navbar {},
        div {className: 'navbar-header'},
          Link {to: '/', className: 'navbar-brand'}, 'SuperCup'
        Nav {},
          NavItem {to: 'order'}, 'Order'
          NavItem {to: 'assign'}, 'Assign'
          NavItem {to: 'workers'}, 'Workers'
      div {className: 'container'},
        @props.activeRouteHandler()

routes = Routes {location:"history"},
  Route {path:"/", handler: App},
    DefaultRoute {handler: TaskTreeList}
    Route {name: 'order', handler: OrderedTaskList}
    Route {name: 'assign', handler: Assign}
    Route {name: 'workers', handler: WorkerList}

$ -> React.renderComponent routes, document.body
