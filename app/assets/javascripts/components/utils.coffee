{li, span} = React.DOM
{Link} = require 'react-router'
{Input} = require 'react-bootstrap'

NavItem = React.createClass
  displayName: 'NavItem'
  render: ->
    li @props, Link({to: @props.to}, @props.children)

EnterToInputText = React.createClass
  displayName: 'EnterToInputText'

  getInitialState: ->
    current: @props.value

  handleInputChange: (e) ->
    @setState
      current: @refs.input.getValue()

  handleInputKeyPress: (e) ->
    return if e.key isnt "Enter"
    @triggerChange()

  handleBlur: ->
    if @props.inputOnBlur
      @triggerChange()

  triggerChange: ->
    current = @state.current
    @setState current: ''
    @props.onChange current

  render: ->
    Input
      type: 'text'
      ref: 'input'
      value: @state.current
      autoFocus: @props.inputOnBlur
      onBlur: @handleBlur
      onKeyPress: @handleInputKeyPress
      onChange: @handleInputChange

ClickToEditText = React.createClass
  displayName: 'ClickToEditText'

  getInitialState: ->
    editMode: false
    current: @props.children

  handleClick: ->
    @setState
      editMode: true
      current: @props.children

  onInputChange: (text) ->
    current = text
    @props.onChange current
    @setState
      editMode: false
      current: current

  render: ->
    if @state.editMode
      EnterToInputText
        value: @state.current
        inputOnBlur: true
        onChange: @onInputChange
    else
      span {onClick: @handleClick}, @state.current

module.exports = {
  NavItem
  ClickToEditText
  EnterToInputText
}
