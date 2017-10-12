class exports.FramerUtils

	@Number:

		cycle: (int, length) ->
			if (output = int % length) < 0 then length + output else output

		clip: (v, min, max) ->
			Math.min Math.max(v, min), max

		invert: (value, condition) ->
			value - 2 * value * Number Boolean not condition

		almostEqual: (a, b, epsilon = .001) -> Math.abs(a - b) < epsilon

		nearestEven: (v) -> 2 * Math.round(v / 2)


	@Object:

		clone: (object) ->
			unless object instanceof Array
				output = {}
				output[prop] = value for prop, value of object
				output
			else object.slice()

		# Cast selected properties from an object to another
		castProps: (from, to, props...) -> to[prop] = from[prop] for prop in props; to

		# Cast selected properties if they don't exists in 'to' object
		castPropsIf: (from, to, props...) -> to[prop] ?= from[prop] for prop in props; to

		# Cast all properties from an object to another
		castAllProps: (from, to) ->
			to[prop] = value for prop, value of from; to

		# Cast all properties if they don't exists in 'to' object
		castAllPropsIf: (from, to) -> to[prop] ?= value for prop, value of from; to


	@Array:

		intersect: (a, b) ->
			[a, b] = [b, a] if a.length > b.length
			value for value in a when value in b

	Array::first = -> @[0]
	Array::last = -> @[@length - 1]


	@Color:

		hexToRgb: (hex) ->
			result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec hex
			if result
				r: parseInt result[1], 16
				g: parseInt result[2], 16
				b: parseInt result[3], 16
			else null

		cssRgba: (hex, alpha) ->
			rgb = FramerUtils.Color.hexToRgb hex
			"rgba(#{rgb.r},#{rgb.g},#{rgb.b},#{alpha})"


	@Math:

		distance: (fromPoint, toPoint) -> Math.sqrt (fromPoint.x - toPoint.x) * (fromPoint.x - toPoint.x) + (fromPoint.y - toPoint.y) * (fromPoint.y - toPoint.y)


	@Geometry:

		rectEdgePoint: (fromPoint, rectFrame, validateInput) ->
			# Returns the intersection/prolongation point between @fromPoint and @rectFrame's center
			x = fromPoint.x; y = fromPoint.y; minX = rectFrame.x; minY = rectFrame.y
			maxX = rectFrame.x + rectFrame.width; maxY = rectFrame.y + rectFrame.height
			if validateInput and (minX <= x and x <= maxX) and (minY <= y and y <= maxY)
				throw "Point [#{x}, #{y}] cannot be inside rectangle [#{minX}, #{minY}, #{maxX}, #{maxY}]"
			midX = (minX + maxX) / 2; midY = (minY + maxY) / 2; m = (midY - y) / (midX - x)
			if (x <= midX) # check left
				minXy = m * (minX - x) + y
				return {x: minX, y: minXy} if (minY <= minXy && minXy <= maxY)
			if (x >= midX) # check right
				maxXy = m * (maxX - x) + y
				return {x: maxX, y: maxXy} if (minY <= maxXy && maxXy <= maxY)
			if (y <= midY) # check top
				minYx = (minY - y) / m + x
				return {x: minYx, y: minY} if (minX <= minYx && minYx <= maxX)
			if (y >= midY) # check bottom
				maxYx = (maxY - y) / m + x
				return {x: maxYx, y: maxY} if (minX <= maxYx && maxYx <= maxX)
			throw "No intersection for [#{x}, #{y}] inside rectangle [#{minX}, #{minY}, #{maxX}, #{maxY}]"

		linePercentPoint: (pointA, pointB, percent) ->
			x = if pointA.x isnt pointB.x then pointA.x + percent * (pointB.x - pointA.x) else x = pointA.x
			y = if pointA.y isnt pointB.y then y = pointA.y + percent * (pointB.y - pointA.y) else y = pointA.y
			x: x, y: y


	@Layer:

		localToGlobal: ( localLayer, localPoint = {x: 0, y: 0} ) ->
			root = localLayer.getGlobalPosition()
			{x: root.x + localPoint.x, y: root.y + localPoint.y}

		globalToLocal: ( localLayer, globalPoint = {x: 0, y: 0} ) ->
			root = localLayer.getGlobalPosition()
			{x: -root.x + globalPoint.x, y: -root.y + globalPoint.y}


	Layer::getGlobalPosition = ->
		xs = ys = 0; scope = @
		(xs += scope.x; ys += scope.y; scope = scope.parent) while scope
		{x: xs, y: ys}

	Layer::convertPosition = ( toLayer, localPoint = {x: 0, y: 0} ) ->
		globalPoint = FramerUtils.Layer.localToGlobal @, localPoint
		FramerUtils.Layer.globalToLocal toLayer, globalPoint


	@Class:

		mixOf = (base, mixins...) ->
			class Mixed extends base
				for mixin in mixins by -1 #earlier mixins override later ones
					for name, method of mixin::
						Mixed::[name] = method
			Mixed
