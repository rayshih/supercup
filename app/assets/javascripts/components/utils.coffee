{li} = React.DOM
{Link} = require 'react-router'

NavItem = React.createClass
  displayName: 'NavItem'
  render: ->
    li @props, Link({to: @props.to}, @props.children)

module.exports = {NavItem}
