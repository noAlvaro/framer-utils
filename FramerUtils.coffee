window['FramerUtils'] = class exports.FramerUtils

	# String improvements
	String::splice = (index, count, add = "") -> @slice(0, index) + add + @slice index + count

	# Array improvements
	Array::remove = (item) -> @splice(index, 1) if (index = @indexOf item) > -1
	Array::removeIf = (item) -> @remove item if item in @
	Array::pushIfNew = (item) -> @push item unless item in @

	# Object improvements
	# Object::asList = -> output = []; output.push v for k, v of @; output

	# Function improvements
	Function::accessor = (scope, prop, desc) -> Object.defineProperty scope, prop, desc

	# Require modules in global scope
	@loadModules: (modules...) -> for module in modules
		window[module] = require(module)[module]

	# Create shortcuts for whatever
	@createShortcuts: (scopes...) ->
		window[prop] = scope[prop] for prop of scope for scope in scopes

	# Require modules and create shortcuts for them in global scope
	@linkModules: (modules...) -> for module in modules
		MyUtils.loadModules module; MyUtils.createShortcuts window[module]

	# Initialize settings
	MyUtils.createShortcuts Events
	MyUtils.loadModules 'Type', 'Spring', 'Frame', 'Point'
	MyUtils.linkModules 'Easings', 'Springs', 'Directions', 'Colors'
	MyUtils.loadModules 'StateManager', 'StateSetup', 'LayerSetup', 'TextLayer'

	# Framer bug on printing routine :(
	# https://www.facebook.com/groups/framerjs/permalink/784989038294836/
	# Object::desc = (props...) ->
		# filterProps = props.length
		# isArray = @ instanceof Array
		# output = []
		# v.constructor for p, v of @
			# continue if filterProps and not (p in props)
			# s = switch typeof v
				# when Type.Boolean, Type.Number, Type.String then v
				# when Type.Function then "#{v.name}()"
				# else "#{v.constructor.name}#{(if v instanceof Array then '[]' else '{}').splice 1, 0, Object.keys(v).length}"

	# Loads; Records original frame values; Creates shortcuts for layers
	# Start the state managing framework
	@load: (path) ->
		layers = Framer.Importer.load path
		MyUtils.recordOriginals layers
		MyUtils.createShortcuts layers
		StateManager.init layers

	# Records original frames
	@recordOriginals: (layers) -> for layerName of layers
		scope = layers[layerName]; scope.originalFrame = scope.frame

	@clone: (object) ->
		unless object instanceof Array
			output = {}
			output[prop] = value for prop, value of object
			output
		else object.slice()

	# Animates with default settings
	@justAnimate: (props) -> time: .4, curve: ExpoInOut, properties: props

	# Ensures that a value is between the informed interval
	@clip: (value, min, max) -> Math.min Math.max(value, min), max

	# Inverts the number if a certain confition is matched
	@invertIf: (number, condition) -> number - 2 * number * Number(condition)

	# Cast selected properties from an object to another
	@castProps: (from, to, props...) -> to[prop] = from[prop] for prop in props

	# Cast selected properties if they don't exists in 'to' object
	@castPropsIf: (from, to, props...) -> to[prop] ?= from[prop] for prop in props

	# Cast all properties from an object to another
	@castAllProps: (from, to) -> to[prop] = value for prop, value of from

	# Cast all properties if they don't exists in 'to' object
	@castAllPropsIf: (from, to) -> to[prop] ?= value for prop, value of from

	# Add mixin methods and properties to class prototype
	@mix: (mixin, klass) -> klass::[name] = method for name, method of mixin

	# Executes a function after a defined amount of time
	@delay: (time, fn, args...) -> setTimeout fn, time * 1000, args...

	# Convert six digit CSS hex strings into CSS rgba function string
	@hexToRgba = (hexColor, opacity = 1) ->
		hexColor = MyUtils.fullHex hexColor
		r = parseInt hexColor.substring(1, 3), 16
		g = parseInt hexColor.substring(3, 5), 16
		b = parseInt hexColor.substring(5, 7), 16
		"rgba(#{r}, #{g}, #{b}, #{opacity})"

	@fullHex = (hexColor) ->
		if hexColor.length < 7
			if colorInfo = hexColor.split('#')[1]
				counter = 6 - colorInfo.length
				colorInfo = "0#{colorInfo}" while counter-- > 0
				return "##{colorInfo}"
			else throw new Error 'Unrecognized hex color signature.'
		else return hexColor
