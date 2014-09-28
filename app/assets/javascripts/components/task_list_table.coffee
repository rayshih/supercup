{div, thead, tr, th, tbody} = React.DOM
{Table} = require 'react-bootstrap'

TaskListTable = React.createClass
  displayName: 'TaskListTable'
  render: ->
    div {},
      Table {},
        thead {},
          tr {},
            th {className: 'col-md-1'}, '#'
            th {className: 'col-md-6'}, 'Name'
            th {className: 'col-md-3'}, 'Dependencies'
            th {className: 'col-md-2'}, 'Actions'
        tbody {}, @props.items

module.exports = TaskListTable
