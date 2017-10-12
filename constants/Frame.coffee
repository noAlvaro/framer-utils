class exports.Frame

  @Up             : new Frame  0  , -1  , 0, 1
  @Down           : new Frame  0  ,  0  , 0, 1
  @Left           : new Frame -1  ,  0  , 1, 0
  @Right          : new Frame  0  ,  0  , 1, 0
  @Vertical       : new Frame  0  , -1  , 0, 2
  @Horizontal     : new Frame -1  ,  0  , 2, 0
  @AllDirections  : new Frame -1  , -1  , 2, 2

  @DIRECTIONAL: (direction = AllDirections, size = 1) ->
    output = switch direction
      when Up             then @Up            .clone()
      when Down           then @Down          .clone()
      when Left           then @Left          .clone()
      when Right          then @Right         .clone()
      when Vertical       then @Vertical      .clone()
      when Horizontal     then @Horizontal    .clone()
      when AllDirections  then @AllDirections .clone()
    output.scale size if size isnt 1
    output

  @_Properties: ['x', 'y', 'width', 'height']

  constructor: (@x = 0, @y = 0, @width = 0, @height = 0) ->

  scale: (value) -> @[property] *= value for property in Frame._Properties; @

  sum: (frame) -> @[property] += frame[property] for property in Frame._Properties; @
