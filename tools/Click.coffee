class exports.Click extends Layer

	constructor: (parent, point, size = 6) ->
		super
			name: 'click'
			x: point.x - size / 2
			y: point.y - size / 2
			width: size
			height: size
			borderRadius: size / 2
			backgroundColor: Utils.randomColor()
			parent: parent
