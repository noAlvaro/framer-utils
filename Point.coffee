class exports.Point

  @FromFrame: (frame) -> new Point frame.x, frame.y

  constructor: (@x = 0, @y = 0) ->
