class exports.StateManager

  @DEFAULT_TIME   = .4
  @DEFAULT_CURVE  = ExpoOut
  @OFF_DEFINITION = opacity: 0

  @init: (layers) ->
    @STATES = {}
    @LAYERS = []
    @IGNORE = []
    @LAYERS.push v for k, v of layers

  @accessor StateManager, 'state',
    get: -> @thisState
    set: (stateName) ->
      if @_state isnt stateName and candidate = @STATES[stateName]
        @REGISTER_SWITCH candidate; @changeTo (@_state = stateName)
      else throw new Error 'State not found.'

  @REGISTER_SWITCH: (to) -> @prevState = @thisState; @thisState = to

  @changeTo: (state, params, instant = false) ->
    throw new Error 'State is missing.' unless nextState = @STATES[state]
    @REGISTER_SWITCH nextState unless @_state is state
    for layer in (@prevState?.all or @LAYERS)
      continue if layer in @IGNORE or not (layer instanceof Layer)
      @OFF layer, instant unless layer in @thisState.all
    @ON layer, instant for layer in @thisState.all
    @thisState.run params, instant

  @ignore: (layers...) -> for layer in layers
    @IGNORE.pushIfNew layer
    arguments.callee.apply @, layer.subLayers if layer.subLayers.length

  @consider: (layer...) -> for layer in layers
    @IGNORE.removeIf layer
    arguments.callee.apply @, layer.subLayers if layer.subLayers.length

  @ON: (layer, instant) -> layer.visible = true unless @NEEDS_PHASING layer, @OFF_DEFINITION

  @OFF: (layer, instant) -> if @NEEDS_PHASING layer, @OFF_DEFINITION
    if instant then FramerUtils.castAllProps @OFF_DEFINITION, layer; else
      # Unworkaroundable issue: FramerJS fails to remove the listener
      # layer.on AnimationEnd, StateManager.PHASE_OUT
      layer.animate properties: @OFF_DEFINITION, time: @DEFAULT_TIME, curve: @DEFAULT_CURVE

  @NEEDS_PHASING: (layer, definition) ->
    (return true unless layer[prop] is definition[prop]) for prop of definition; false

  @PHASE_OUT: (event, layer) ->
    # Unworkaroundable issue: FramerJS fails to remove the listener
    # layer.off AnimationEnd, StateManager.PHASE_OUT; @visible = false


# history/back support
