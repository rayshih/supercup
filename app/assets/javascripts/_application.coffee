window.React = require 'react'

{Routes, Route, Link} = require 'react-router'
{Navbar, Nav} = require 'react-bootstrap'
{div, li} = React.DOM

NavItem = React.createClass
  displayName: 'NavItem'
  render: ->
    li @props, Link({to: @props.to}, @props.children)

App = React.createClass
  displayName: 'App'
  render: ->
    div null,
      Navbar {},
        Nav {},
          NavItem {key: 1, to: 'test1'}, 'test1'
          NavItem {key: 2, to: 'test2'}, 'test2'
      @props.activeRouteHandler()

Test1 = React.createClass
  render: ->
    div null, 'test1'

Test2 = React.createClass
  render: ->
    div null, 'test2'


routes = Routes {location:"history"},
  Route {path:"/", handler: App},
    Route {name: "test1", handler: Test1}
    Route {name: "test2", handler: Test2}

$ -> React.renderComponent routes, document.body
