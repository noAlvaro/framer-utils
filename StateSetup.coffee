class exports.StateSetup

  constructor: (@stateName) ->
    @state = []; @fixed = []; @all = []
    StateManager.STATES[@stateName] = @

  addSetup: (layerSetups...) ->
    for setup in layerSetups
      scope.removeIf setup.layer for scope in [@fixed, @all]
    @addTo @state, layerSetups

  addMoved: (layer, state = layer.originalFrame, tween = null) ->
    output = new LayerSetup layer, state, tween
    @addSetup output; output

  addFixed: (fixedLayers...) ->
    for setup in @state
      (@all.removeIf setup.layer; @state.removeIf setup) if setup.layer in fixedLayers
    @addTo @fixed, fixedLayers

  addTo: (scope, list) -> for item in list
    if layer = (if scope is @state then item.layer else if scope is @fixed then item)
      @all.pushIfNew layer; scope.pushIfNew item
      @indexChildrenOf layer if layer.subLayers.length

  indexChildrenOf: (layer) ->
    for child in layer.subLayers
      scope.push child for scope in [@fixed, @all] unless child in @all
      arguments.callee.call @, child if child.subLayers.length

  run: (params, instant = false) ->
    for setup in @state
      skipOpacity = setup.layer.opacity or setup.properties.hasOwnProperty 'opacity'
      setup.layer.opacity = 1 unless skipOpacity
      setup.layer.states.add @stateName, setup.state params
      if instant or not setup.animations then setup.layer.states.switchInstant @stateName
      else setup.layer.states.switch @stateName, setup.tween params

# animation step callbacks
# layer linking
