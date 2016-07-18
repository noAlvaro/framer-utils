class exports.LayerSetup

  # User can just inform properties and animations if it's a simple layer state.

  constructor: (@layer, @properties = null, @animations = null) ->

  # User can aways change properties and animations by informing new values.

  newProperties: (props) -> @properties = props if props
  newAnimations: (anims) -> @animations = anims if anims

  # Advanced layer state will require to extend this class, then implement tween
  # and state methods to output the dynamic values.

  state: (params) -> @properties or throw new Error "Missing states for '#{@layer.name}' LayerSetup"
  tween: (params) -> @animations
