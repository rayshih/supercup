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
    current: @props.value or ''

  handleInputChange: (e) ->
    @setState
      current: @refs.input.getValue() or ''

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

  valueForDisplay: (s) ->
    if s and s.length > 0
      s
    else
      @props.defaultValue

  getInitialState: ->
    editMode: false

  handleClick: ->
    @setState editMode: true

  onInputChange: (text) ->
    text = text.trim()
    unless text.length == 0 and !@props.enableEmpty
      @props.onChange text

    @setState editMode: false

  render: ->
    if @state.editMode
      EnterToInputText
        value: @props.children
        inputOnBlur: true
        onChange: @onInputChange
    else
      span {onClick: @handleClick},
        @valueForDisplay @props.children

module.exports = {
  NavItem
  ClickToEditText
  EnterToInputText
}
