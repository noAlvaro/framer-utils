{FramerUtils} = require '../FramerUtils.coffee'

class exports.MagnetLayer extends Layer

	@Events = [
		Events.MouseUp		, Events.MouseDown
		Events.MouseOver	, Events.MouseOut
		Events.MouseMove	, Events.MouseWheel
	]


	@define 'debug',
		get: -> @_options.show
		set: (v) -> @_options.show = v

	@define 'options',
		get: -> @_options
		set: (v) -> v ?= MagnetOptions.Defaults; for k of MagnetOptions.Defaults
			@_options[k] = v[k] unless v[k] is undefined

	constructor: (options={}) -> # layer + magnet options

		o = Object.keys MagnetOptions.Defaults

		super _.omit options, o
		@ignoreEvents = true # do not change!

		@_options = new MagnetOptions @, _.pick options, o

		for e in MagnetLayer.Events
			@["_#{e}"] = (o) => @addMagnetProperties o
			@_options.on e, @["_#{e}"]

	addMagnetProperties: (o) ->
		o.magnetLayer = @
		o.magnetPoint =
			x: @calculateAxis 'x', o.point.x
			y: @calculateAxis 'y', o.point.y
		o.snapPoint = @snapPoint

	calculateAxis: (axis, point) ->
		switch axis
			when 'x' then side = @width/2; edge = [@_options.left, @_options.right]; push = @_options.magnetX
			when 'y' then side = @height/2; edge = [@_options.top, @_options.bottom]; push = @_options.magnetY
		if ( candidate = point - ( side + edge[0] ) ) < 0
			length = side + edge[0]; interval = [-length, 0]
			position = [length * push, length]
		else
			length = side + edge[1]; interval = [0, length]
			position = [ side + edge[0], ( side + edge[0] ) + ( length * (1 -push) ) ]
		Math.round(Utils.modulate candidate, interval, position)


class MagnetOptions extends Layer

	@Defaults =
		left: 0, right: 0, top: 0, bottom: 0
		magnetX: .5, magnetY: .5, show: false

	@AreaStyle =
		show:
			border: "1px #{FramerUtils.Color.cssRgba '#ddff33', .24} dashed"
			backgroundColor: FramerUtils.Color.cssRgba '#ddff33', .08
		hide: border: null, backgroundColor: 'transparent'


	@define 'left',
		get: -> @_left
		set: (v) -> unless @_left is (v ?= MagnetOptions.Defaults.left)
			@x = -(@_left = v); @fixWidth()

	@define 'right',
		get: -> @_right
		set: (v) -> unless @_right is (v ?= MagnetOptions.Defaults.right)
			@_right = v; @fixWidth()

	@define 'top',
		get: -> @_top
		set: (v) -> unless @_top is (v ?= MagnetOptions.Defaults.top)
			@y = -(@_top = v); @fixHeight()

	@define 'bottom',
		get: -> @_bottom
		set: (v) -> unless @_bottom is (v ?= MagnetOptions.Defaults.bototm)
			@_bottom = v; @fixHeight()

	@define 'magnetX',
		get: -> @_magnetX
		set: (v) -> unless @_magnetX is (v ?= MagnetOptions.Defaults.magnetX)
			@_magnetX = v

	@define 'magnetY',
		get: -> @_magnetY
		set: (v) -> unless @_magnetY is (v ?= MagnetOptions.Defaults.magnetY)
			@_magnetY = v

	@define 'show',
		get: -> @_show
		set: (v) -> unless @_show is (v ?= MagnetOptions.Defaults.show)
			@style = MagnetOptions.AreaStyle[if (@_show = v) then 'show' else 'hide']


	constructor: (parent, options) ->
		super parent: parent, borderRadius: 8
		@[n] = options[n] for n in Object.keys MagnetOptions.Defaults

	fixWidth: -> @width = @parent.width + @_left + @_right
	fixHeight: -> @height = @parent.height + @_top + @_bottom
