{FramerUtils} = require '../FramerUtils.coffee'

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


	@Animation =
		time: .05
		curve: Bezier.easeOut

	constructor: ->

		super size: 0, backgroundColor: 'transparent', parent: Framer.Device.hands
		document.body.style.cursor = 'none'

		@placer = new Layer name: 'placer', size: @size, parent: @

		radius = 23
		@cursor = new Layer
			name: 'cursor', parent: @placer
			x: -radius, y: -radius, size: radius*2
			borderRadius: radius
			gradient: MagnetCursor.Fill.up
			shadow1: MagnetCursor.Bevel.up
			shadow2: MagnetCursor.Shadow.one
			shadow3: MagnetCursor.Shadow.two

		radius = 22
		@cursor.states.down =
			x: -radius, y: -radius, size: radius*2
			borderRadius: radius
			gradient: MagnetCursor.Fill.down
			shadow1: MagnetCursor.Bevel.down

		Framer.Device.screen.on Events.MouseMove, @sync
		Framer.Device.screen.on Events.MouseDown, => @cursor.stateSwitch 'down'
		Framer.Device.screen.on Events.MouseUp, => @cursor.animate 'default', time: .25
		Framer.Device.screen.on "change:children", => print 'here'

		@outline = new MagnetOutline x: -23, y: -1, parent: @

	sync: (e) =>
		@frame = e
		if e.magnetPoint
			point = e.magnetLayer._options.convertPointToLayer e.magnetPoint, @
			method = @outline.open
		else
			point = x: 0, y: 0
			method = @outline.close

		if method() or @placer.isAnimating
			@placer.animate point: point, MagnetCursor.Animation
		else @placer.point = point




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
		time = .3; time1 = time/3; time2 = time/1.5

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

		@a1 = new Animation l, x: radius/2, width: radius/2, opacity: .75, {time: time1, curve: Bezier.easeIn}
		a2 = new Animation l, x: radius/3*2, width: radius/3, opacity: 1, {time: time2, curve: Bezier.easeOut}
		b1 = @a1.reverse(); b1.options = time: time2, curve: Bezier.easeOut
		@b2 = a2.reverse(); @b2.options = time: time1, curve: Bezier.easeIn

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
