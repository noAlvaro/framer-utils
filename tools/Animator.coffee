class exports.Animator extends Layer

	@define 'progress',
		get: -> @_progress
		set: (v) -> @sync() unless @_progress is @_progress = v

	@define 'range',
		get: -> @_range or .75
		set: (v) -> @refresh() unless @_range is @_range = v

	constructor: (@properties...) -> # accepts layer options as last item
		super if typeof @properties[..].pop() is 'object' then @properties.pop() else {}
		@on 'change:children', @refresh

	refresh: -> @lastState = new Array @children.length; @sync()

	sync: ->
		totalChildren = @children.length
		return unless totalChildren-- and typeof @_progress is 'number'
		progressFix = (1 + @range) * @_progress
		for child, index in @children
			position = child.index / totalChildren
			diff = Math.max 0, progressFix - position
			value = Math.min 1, diff / @range
			unless @lastState[index] is value
				child[property] = value for property in @properties
				@lastState[index] = value
