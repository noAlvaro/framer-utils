class exports.StateManager

  @DefaultTime   : .4
  @DefaultCurve  : ExpoOut
  @OffDefinition : opacity: 0

  @init: (layers) ->
    @States = {}
    @Layers = []
    @Ignore = []
    @Layers.push v for k, v of layers

  @accessor StateManager, 'state',
    get: -> @thisState
    set: (stateName) ->
      if @_state isnt stateName and candidate = @States[stateName]
        @RegisterSwitch candidate; @changeTo (@_state = stateName)
      else throw new Error 'State not found.'

  @RegisterSwitch: (to) -> @prevState = @thisState; @thisState = to

  @changeTo: (state, params, instant = false) ->
    throw new Error 'State is missing.' unless nextState = @States[state]
    @RegisterSwitch nextState unless @_state is state
    for layer in (@prevState?.all or @Layers)
      continue if layer in @Ignore or not (layer instanceof Layer)
      @Off layer, instant unless layer in @thisState.all
    @On layer, instant for layer in @thisState.all
    @thisState.run params, instant

  @ignore: (layers...) -> for layer in layers
    @Ignore.pushIfNew layer
    arguments.callee.apply @, layer.subLayers if layer.subLayers.length

  @consider: (layer...) -> for layer in layers
    @Ignore.removeIf layer
    arguments.callee.apply @, layer.subLayers if layer.subLayers.length

  @On: (layer, instant) -> layer.visible = true unless @NeedsPhasing layer, @OffDefinition

  @Off: (layer, instant) -> if @NeedsPhasing layer, @OffDefinition
    if instant then FramerUtils.castAllProps @OffDefinition, layer; else
      # Unworkaroundable issue: FramerJS fails to remove the listener
      # layer.on AnimationEnd, StateManager.PhaseOut
      layer.animate properties: @OffDefinition, time: @DefaultTime, curve: @DefaultCurve

  @NeedsPhasing: (layer, definition) ->
    (return true unless layer[prop] is definition[prop]) for prop of definition; false

  @PhaseOut: (event, layer) ->
    # Unworkaroundable issue: FramerJS fails to remove the listener
    # layer.off AnimationEnd, StateManager.PhaseOut; @visible = false


# history/back support
