class exports.MagnetLayer extends Layer

	@Configs = ['left', 'right', 'top', 'bottom', 'magnetX', 'magnetY']
	@Events = [
		Events.MouseUp		, Events.MouseDown
		Events.MouseOver	, Events.MouseOut
		Events.MouseMove	, Events.MouseWheel
	]

	constructor: (options={}) ->

		@_config = _.pick options, MagnetLayer.Configs
		for p in MagnetLayer.Configs then delete options[p]; @_config[p] ?= 0

		super options
		@ignoreEvents = true # do not change!

		@area = new Layer
			parent: @, backgroundColor: 'transparent'
			x: -@_config.left; y: -@_config.top
			width: @width + (@_config.left + @_config.right)
			height: @height + (@_config.top + @_config.bottom)

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
