{FramerUtils} = require 'FramerUtils'

class exports.BoundlessScroll extends ScrollComponent

  @DEFAULTS:
    name: 'scroll'
    clip: false
    pixelAlign: true
    snapTreshold: .2
    backgroundColor: 'transparent'
    scrollHorizontal: false
    fxProperty: 'opacity'
    fxLines: 1
    fxDecay: .5
    fxSlots: false


  @ERRORS:
    linesIsntLayer: "BoundlessScroll: provided 'lines' must be an layer of lines."
    badLineHeight: "BoundlessScroll: 'lineHeight' must be a positive number."
    badLinePadding: "BoundlessScroll: 'linePadding' cannot be a negative number."
    badLines: "BoundlessScroll: 'lines' cannot be a negative number."
    badBug: "BoundlessScroll: you've gone under an untreated bug domain :)"

  @define 'lineHeight',
    get: -> @_lineHeight
    set: (v) ->
      throw new Error exports.BoundlessScroll.ERRORS.badLineHeight unless v? and v > 0
      @updateLines() unless @_lineHeight is @_lineHeight = v

  @define 'linePadding',
    get: -> @_linePadding
    set: (v) ->
      throw new Error exports.BoundlessScroll.ERRORS.badLinePadding unless v? and v >= 0
      @updateLines() unless @_linePadding is @_linePadding = v

  @define 'lineView',
    get: -> @_lineView
    set: (v) ->
      throw new Error exports.BoundlessScroll.ERRORS.badLines unless v? and v >= 0
      @updateLines() unless @_lineView isnt @_lineView = v

  @define 'snap',
    get: -> @_snap
    set: (v) -> @updateScroll() unless @_snap is @_snap = v

  @define 'snapTreshold',
    get: -> @_snapTreshold
    set: (v) -> @_snapTreshold = v

  @define 'fxOptions',
    get: -> @_fx
    set: (v) -> @_fx.update v

  constructor: (@lines, @lineHeight, @linePadding, @lineView, @snap, options = {}) ->
    super _.defaults options,
      width: @lines.width
      name: exports.BoundlessScroll.DEFAULTS.name
      snapTreshold: exports.BoundlessScroll.DEFAULTS.snapTreshold
      scrollHorizontal: exports.BoundlessScroll.DEFAULTS.scrollHorizontal
    @content.addChild @lines
    @content.on 'change:y', => @updateScroll()
    @content.draggable.pixelAlign = exports.BoundlessScroll.DEFAULTS.pixelAlign
    @on Events.MouseDown, => @_mouseDown = true
    @on Events.ScrollEnd, => @_isSnapping = @_mouseDown = false; @updateScroll() unless @velocity.y
    @_fx = new BoundlessScrollFx @
    @_isSnapping = @_mouseDown = false
    @_canUpdate = true; @updateLines()

  adjust: (lineHeight, linePadding, lineView, snap) ->
    @_canUpdate = false
    @lineHeight = lineHeight
    @linePadding = linePadding
    @lineView = lineView
    @snap = snap
    @_canUpdate = true
    @updateLines()

  updateLines: ->
    return unless @_canUpdate
    # line.y = (@_lineHeight + @_linePadding) * index for line, index in @content
    @totalLines = @lines.children.length; @lineSize = @_lineHeight + @_linePadding
    @propRange =
      top: if @_fx.bipolar then [-1, 0] else [0, 1]
      bottom: if @_fx.bipolar then [1, 0] else [0, 1]
      middle: if @_fx.bipolar then 0 else 1
    @height = Math.max 0, @lineSize * @_lineView - @_linePadding + 2 * @_fx.boundSize
    slotHeight = @_fx.slots * @lineSize
    throw new Error exports.BoundlessScroll.ERRORS.badBug if @_lineView + 2 > @totalLines
    @content.draggable.constraints.y = @height - (@content.height + slotHeight) - @_fx.boundSize
    @content.draggable.constraints.height = (@content.height + slotHeight) * 2 - @height + 2 * @_fx.boundSize
    @updateScroll() if @content.y is @content.y = @_fx.boundSize + slotHeight # one updateScroll execution only

  updateScroll: ->
    return if not @_canUpdate or @direction in ['left', 'right']
    # calculate interval and staged items
    upperIndex = Math.floor (@scrollY + @_fx.boundSize) / @lineSize - 1
    lowerIndex = upperIndex + @_lineView + 2
    upperCap = Math.min @totalLines, Math.max 0, upperIndex
    lowerCap = Math.min @totalLines, Math.max 0, lowerIndex
    fxInterval = @lineSize * @_fx.lines - @_linePadding
    upMinor = @scrollY
    upMajor = upMinor + fxInterval
    loMinor = @scrollY + @height - @_fx.boundSize
    loMajor = loMinor - fxInterval
    for index in [upperCap..lowerCap]
      if line = @lines.children[index]
        candidateFx =
        if upMajor >= line.y
          Utils.modulate line.y, [upMinor, upMajor], @propRange.top, true
        else if loMajor <= line.y
          Utils.modulate line.y, [loMinor, loMajor], @propRange.bottom, true
        else @propRange.middle
        line[@_fx.property] = candidateFx unless line[@_fx.property] is candidateFx
    # snaps scroll if threshold is reached
    if @_snap and not @content.draggable.isBeyondConstraints and Math.abs(@velocity.y) < @_snapTreshold and not @_isSnapping and (not @isDragging or not @_mouseDown) and @isMoving
      @_isSnapping = true
      @scrollToPoint x: 0, y: Math.round( (@scrollY + @_fx.boundSize) / @lineSize ) * @lineSize - @_fx.boundSize

  resetProperty: (to = null) ->
    resetValue = to or if @_fx.bipolar then 0 else 1
    line[@_fx.property] = resetValue for line in @lines.children

class BoundlessScrollFx

  ###

    CONSTRUCTOR
      property      string        property to receive boundless value
      bipolar       boolean       property behavior switch: [0,1] to [-1,1]
      boundSize     number        space reserved for boundary effect
      lines         integer       amount of bound items in each margin
      slots         boolean       empty slots to avoid mandatory decays

    INSTRUCTIONS
      1.  'property' takes either a 'string' or a {name:, bipolar:} bundle

  ###

  @DEFAULTS =
    property:
      name: 'opacity'
      bipolar: false
    lines: 1
    slots: 0

  @define 'property',
    get: -> @_property or BoundlessScrollFx.DEFAULTS.property.name
    set: (v) -> switch typeof v
      when 'string'
        ( @_.resetProperty(); @_property = v; @_.updateScroll() ) unless @property is v
      when 'object'
        (@_.resetProperty(); @_property = v.name) unless @property is v.name
        if @bipolar is @_bipolar = v.bipolar then @_.updateScroll() else @_.updateLines()

  @define 'bipolar',
    get: -> @_bipolar or BoundlessScrollFx.DEFAULTS.property.bipolar
    set: (v) -> @_.updateLines() unless @bipolar is @_bipolar = v

  @define 'boundSize',
    get: -> @_boundSize or @_.lineHeight
    set: (v) -> @_.updateLines() unless @boundSize is @_boundSize = v

  @define 'lines',
    get: -> @_lines or BoundlessScrollFx.DEFAULTS.lines
    set: (v) -> @_.updateScroll() unless @lines is @_lines = Math.max 1, (Math.min (Math.ceil @_.lineView / 2), v)

  @define 'slots',
    get: -> @_slots or BoundlessScrollFx.DEFAULTS.slots
    set: (v) -> @_.updateLines() unless @slots is @_slots = v

  constructor: (@_) ->

  update: (fxOptions) ->
    props = ['boundSize', 'lines', 'slots']
    if fxOptions.property and fxOptions.bipolar? then @property = name: fxOptions.property, bipolar: fxOptions.bipolar
    else (props.unshift prop if prop?) for prop in ['property', 'bipolar']
    ( @[prop] = fxOptions[prop] if fxOptions[prop]? ) for prop in props
