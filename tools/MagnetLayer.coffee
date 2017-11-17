{FramerUtils} = require '../FramerUtils.coffee'

class exports.MagnetLayer extends Layer

	@Configs = ['left', 'right', 'top', 'bottom', 'magnetX', 'magnetY']
	@Events = [
		Events.MouseUp		, Events.MouseDown
		Events.MouseOver	, Events.MouseOut
		Events.MouseMove	, Events.MouseWheel
	]
	@AreaStyle =
		show:
			border: "1px #{FramerUtils.Color.cssRgba '#ddff33', .25} dashed"
			backgroundColor: FramerUtils.Color.cssRgba '#ddff33', .05
		hide: border: null, backgroundColor: 'transparent'


	@define 'showArea',
		get: -> @_showArea
		set: (v) -> unless @_showArea is (@_showArea = v) then @area.style =
			MagnetLayer.AreaStyle[if @_showArea then 'show' else 'false']

	constructor: (options={}) ->

		@_config = _.pick options, MagnetLayer.Configs
		for p in MagnetLayer.Configs then delete options[p]; @_config[p] ?= 0

		super options
		@ignoreEvents = true # do not change!

		@area = new Layer
			parent: @, borderRadius: 8
			x: -@_config.left; y: -@_config.top
			width: @width + (@_config.left + @_config.right)
			height: @height + (@_config.top + @_config.bottom)
			style: MagnetLayer.AreaStyle.hide

		@_showArea = false

		for e in MagnetLayer.Events
			@["_#{e}"] = (o) => @addMagnetProperties o
			@area.on e, @["_#{e}"]

	addMagnetProperties: (o) ->
		o.magnetLayer = @
		o.magnetPoint =
			x: @calculateAxis 'x', o.point.x
			y: @calculateAxis 'y', o.point.y

	calculateAxis: (axis, point) ->
		switch axis
			when 'x' then side = @width/2; edge = [@_config.left, @_config.right]; push = @_config.magnetX
			when 'y' then side = @height/2; edge = [@_config.top, @_config.bottom]; push = @_config.magnetY
		if ( candidate = point - ( side + edge[0] ) ) < 0
			length = side + edge[0]; interval = [-length, 0]
			position = [length * push, length]
		else
			length = side + edge[1]; interval = [0, length]
			position = [ side + edge[0], ( side + edge[0] ) + ( length * (1 -push) ) ]
		Math.round(Utils.modulate candidate, interval, position)
