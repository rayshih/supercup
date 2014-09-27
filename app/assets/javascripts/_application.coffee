window.React = require 'react'

{Routes, Route, Link, DefaultRoute} = require 'react-router'
{Navbar, Nav} = require 'react-bootstrap'
{div, li} = React.DOM
{NavItem} = require './components/utils'
TaskList = require './components/task_list'

App = React.createClass
  displayName: 'App'
  render: ->
    div null,
      Navbar {},
        div {className: 'navbar-header'},
          Link {to: '/', className: 'navbar-brand'}, 'SuperCup'
      div {className: 'container theme-showcase'},
        @props.activeRouteHandler()

routes = Routes {location:"history"},
  Route {path:"/", handler: App},
    DefaultRoute {handler: TaskList}

$ -> React.renderComponent routes, document.body
