class exports.Point

  @FROM_FRAME: (frame) -> new Point frame.x, frame.y

  constructor: (@x = 0, @y = 0) ->
