class exports.Spring

  constructor: (@tension, @friction, @velocity) ->

  toString: -> "spring(#{@tension}, #{@friction}, #{@velocity})"
