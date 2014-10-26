{div, form} = React.DOM
{Input} = require 'react-bootstrap'
{EnterToInputText} = require '../utils'

Filter = React.createClass
  displayName: 'Filter'

  propTypes:
    onChange: React.PropTypes.func

  onChange: ->
    s = @refs.input.getValue()
    @props.onChange? s

  render: ->
    div {},
      form {className: "form-horizontal"},
        Input {
          type: 'text'
          label: 'Filter'
          labelClassName: 'col-xs-1'
          wrapperClassName: 'col-xs-11'

          ref: 'input'
          onChange: @onChange

          placeholder: 'Not finish yet'
        }


module.exports = Filter
