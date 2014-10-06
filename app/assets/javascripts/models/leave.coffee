class Leave
  @parse: (data) ->
    leave = new @
    leave.data = data
    leave.id = data.id
    leave

  constructor: (workerId, startDate, endDate, hours) ->
    @data = {
      worker_id: workerId
      start_date: startDate
      end_date: endDate
      hours: hours
    }

  getWorkerId: -> @data.worker_id

  getStartDate: -> @data.start_date
  setStartDate: (date) -> @data.start_date = date

  getEndDate: -> @data.end_date
  setEndDate: (date) -> @data.end_date = date

  getHours: -> parseInt @data.hours, 10
  setHours: (hours) -> @data.hours = hours

module.exports = Leave
