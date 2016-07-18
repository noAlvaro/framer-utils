class exports.Frame

  @UP             = new Frame  0  , -1  , 0, 1
  @DOWN           = new Frame  0  ,  0  , 0, 1
  @LEFT           = new Frame -1  ,  0  , 1, 0
  @RIGHT          = new Frame  0  ,  0  , 1, 0
  @VERTICAL       = new Frame  0  , -1  , 0, 2
  @HORIZONTAL     = new Frame -1  ,  0  , 2, 0
  @ALL_DIRECTIONS = new Frame -1  , -1  , 2, 2

  @DIRECTIONAL: (direction = AllDirections, size = 1) ->
    output = switch direction
      when Up             then @UP            .clone()
      when Down           then @DOWN          .clone()
      when Left           then @LEFT          .clone()
      when Right          then @RIGHT         .clone()
      when Vertical       then @VERTICAL      .clone()
      when Horizontal     then @HORIZONTAL    .clone()
      when AllDirections  then @ALL_DIRECTION .clone()
    output.scale size if size isnt 1
    output

  @_PROPERTIES = ['x', 'y', 'width', 'height']

  constructor: (@x = 0, @y = 0, @width = 0, @height = 0) ->

  scale: (value) -> @[property] *= value for property in Frame._PROPERTIES; @

  sum: (frame) -> @[property] += frame[property] for property in Frame._PROPERTIES; @
