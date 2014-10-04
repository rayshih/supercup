_ = require 'lodash'
{ul, li} = React.DOM

FilteredList = React.createClass
  displayName: 'FilterList'
  render: ->
    data = @props.data
    filterString = @props.filterString

    if filterString
      ul {}, _.chain(data).filter((item) ->
        item.toLowerCase().indexOf(filterString) != -1
      ).map((item, i) ->
        li {key: i}, item
      ).value()
    else null

module.exports = FilteredList
