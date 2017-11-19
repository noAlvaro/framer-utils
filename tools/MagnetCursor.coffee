{FramerUtils} = require '../FramerUtils.coffee'
{Ease} = require '../Ease.coffee'

class exports.MagnetCursor extends Layer

	@Fill =
		up: new Gradient
			start: new Color('white').alpha .11
			end: new Color('white').alpha .56
		down: new Gradient
			start: new Color('white').alpha .38
			end: new Color('white').alpha .12

	@Bevel =
		up:
			y: 1, blur: 2, type: 'inner'
			color: new Color('white').alpha .41
		down:
			y: 1, blur: 2, type: 'inner'
			color: new Color('white').alpha .80

	@Shadow =
		one: y: 2, blur: 4, color: new Color('black').alpha .2
		two: y: 1, blur: 1, color: new Color('black').alpha .1

	@Size = up: 23, down: 22

	@Animation =
		time: .1
		curve: Ease.ExpoOut

	constructor: ->

		for candidateMc in Framer.Device.hands.children
			candidateMc.destroy() if candidateMc.constructor.name is @constructor.name


		super size: 0, backgroundColor: 'transparent', parent: Framer.Device.hands
		document.body.style.cursor = 'none'

		@placer = new Layer name: 'placer', size: @size, parent: @, backgroundColor: 'transparent'

		radius = MagnetCursor.Size.up
		@cursor = new Layer
			name: 'cursor', parent: @placer
			x: -radius, y: -radius, size: radius*2
			borderRadius: radius, backgroundColor: 'transparent'
			gradient: MagnetCursor.Fill.up
			shadow1: MagnetCursor.Bevel.up
			shadow2: MagnetCursor.Shadow.one
			shadow3: MagnetCursor.Shadow.two

		radius = MagnetCursor.Size.down
		@cursor.states.down =
			x: -radius, y: -radius, size: radius*2
			borderRadius: radius, backgroundColor: 'transparent'
			gradient: MagnetCursor.Fill.down
			shadow1: MagnetCursor.Bevel.down

		Framer.Device.screen.on Events.MouseMove, @sync
		Framer.Device.screen.on Events.MouseDown, @press
		Framer.Device.screen.on Events.MouseUp, @release

		@justReleased = false

		@outline = new MagnetOutline x: -23, y: -1, parent: @

	sync: (e) =>
		p = _.pick e, ['x', 'y']
		deltaX = p.x - @x; deltaY = (p.y - @y)
		@point = p

		point =
		if @magnetPress then x: @placer.point.x - deltaX, y: @placer.point.y - deltaY
		else if e.magnetPoint then method = @outline.open; @magnetPoint e.magnetLayer, e.magnetPoint
		else method = @outline.close; point = x: 0, y: 0

		if method?() or @placer.isAnimating or @justReleased
			options = _.defaults time: (if @justReleased then 1 else .1), MagnetCursor.Animation
			@placer.animate point, options; @justReleased = false
		else @placer.point = point

	magnetPoint: (magnetLayer, magnetPoint) ->
		magnetLayer._options.convertPointToLayer magnetPoint, @

	press: (e) =>
		if e.snapPoint and e.magnetPoint
			point = e.magnetLayer.convertPointToLayer e.snapPoint, @
			@placer.animate point, MagnetCursor.Animation
		@cursor.stateSwitch 'down'
		@magnetPress = true if e.magnetPoint

	release: (e) =>
		if e.snapPoint and e.magnetPoint then point = @magnetPoint e.magnetLayer, e.magnetPoint
		@cursor.animate 'default', time: .25
		@magnetPress = false; @justReleased = true; @sync e


class MagnetOutline extends Layer

	@define 'outlineColor',
		get: -> @_outlineColor
		set: (v) -> unless @_outlineColor is (@_outlineColor = v)
			@o.style.border = @_borderStyle
			side.backgroundColor = @_outlineColor for side in @sides

	@define '_borderStyle', get: -> "2px #{@_outlineColor} dotted"


	constructor: (options={}) ->

		super _.defaults options, name: 'outline', size: 0, backgroundColor: 'transparent'

		@_outlineColor = 'grey'
		lineProps =
			width: 2, height: 2, borderRadius: 2
			opacity: 0, backgroundColor: @_outlineColor, parent: @
		radius = 23; offset = lineProps.width/2; gain = 14
		time = .5; time1 = time/3; time2 = time/1.5

		@o = new Layer
			name: 'o', y: offset-radius
			size: radius*2, borderRadius: radius + gain/2
			backgroundColor: 'transparent', opacity: 0, parent: @
			style: border: @_borderStyle

		l = new Layer lineProps
		r = new Layer _.defaults {}, lineProps, originX: 0, scaleX: -1, x: radius*2
		t = new Layer _.defaults {}, lineProps, x: radius - offset, y: -radius
		b = new Layer _.defaults {}, lineProps, x: radius - offset, y: radius

		@sides = [l, r, t, b]

		@a1 = new Animation l, x: radius/2, width: radius/2, opacity: .75, {time: time1, curve: Ease.ExpoIn}
		a2 = new Animation l, x: radius/3*2, width: radius/3, opacity: 1, {time: time2, curve: Ease.ExpoOut}
		b1 = new Animation l, x: 0, width: 2, opacity: 0, {time: time2/2.5, curve: Ease.ExpoOut}
		@b2 = new Animation l, x: radius/2, width: radius/2, opacity: .75, {time: time1/2.5, curve: Ease.ExpoIn}

		l.on 'change:opacity', (e) =>
			layer.opacity = l.opacity for layer in [r, t, b, @o]
			growth = l.opacity * gain
			@o.props = size: radius*2 + growth, x: -growth/2, y: offset-radius-growth/2
		l.on 'change:frame', (e) ->
			r.x = radius*2 - l.x; r.width = l.width
			t.y = l.x - radius + offset; t.height = l.width
			b.y = radius - l.x - l.width + offset; b.height = l.width

		@a1.on Events.AnimationEnd, a2.start; @b2.on Events.AnimationEnd, b1.start
		@a1.on Events.AnimationStart, @startRotation; @b2.on Events.AnimationEnd, @stopRotation

		@opened = false

	startRotation: => @interval = setInterval (=> @o.rotation++), 1/30*1000
	stopRotation: => clearInterval @interval; @o.rotation = 0

	open: => unless @opened then @opened = true; @a1.start()
	close: => if @opened then @opened = false; @b2.start()
