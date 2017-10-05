class exports.Spring

  @Exessive   = new Spring(200  , 15  , -3).toString()
  @Gentle     = new Spring(40   , 5   ,  0).toString()
  @Swing      = new Spring(120  , 15  ,  0).toString()
  @Smooth     = new Spring(100  , 20  ,  0).toString()
  @SuperSlow  = new Spring(30   , 20  ,  0).toString()
  @Slow       = new Spring(100  , 15  , -3).toString()
  @Snap       = new Spring(200  , 20  ,  0).toString()
  @Tight      = new Spring(300  , 25  ,  0).toString()
  @Straight   = new Spring(500  , 40  ,  0).toString()

  constructor: (@tension, @friction, @velocity) ->

  toString: -> "spring(#{@tension}, #{@friction}, #{@velocity})"
