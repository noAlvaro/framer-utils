{FramerUtils} = require 'FramerUtils'
{Framework} = require 'constants/Framework'

# TODO: optimize by replacing _.omit for _.pick
class exports.Symbol extends Layer

	@Images: {}

	@Regex:
		titleCase: /\b[A-Z][a-z]*([A-Z][a-z]*)*\b/g
		camelCase: /\b[a-z]+([A-Z][a-z]*)*\b/g

	@getClassName: (fromString) -> fromString?.match(Symbol.Regex.titleCase)?[0]

	@getTargetName: (fromString) -> fromString?.split('@')[1]?.match(Symbol.Regex.camelCase)?[0]

	@getImage: (resetPoint, layers...) ->
		props = _.map layers, 'props'
		baseImage = if props.length > 1 then @intersectProps props, layers else props[0]
		isText = _.difference(Object.keys(Framework.TextLayerExclusives), Object.keys baseImage).length is 0
		layerType = if isText then 'TextLayer' else 'Layer'
		baseImage.x = baseImage.y = 0 if resetPoint
		output = _.omitBy baseImage, (v, k) -> Framework[layerType][k] is v
		output.__isText = isText; output.__children = []; sampleLayer = layers[0]
		output.__children.push Symbol.getImage false, child for child in sampleLayer.children; output

	@intersectProps: (props, layers) ->
		omitedKeys = [];
		image = _.assignWith {}, props..., (objValue, srcValue, key, object, source) ->
			return srcValue unless key in Object.keys object
			omitedKeys.push key unless objValue is srcValue; srcValue
		output = _.omit image, omitedKeys; output.stagedProfiles = []
		output.stagedProfiles.push _.pick layer.props, omitedKeys for layer in layers
		output


	# LIMIT: Do not instantiate Symbols inside Symbols of the same type.
	constructor: (layerOptions={}, @initializers={}, @initializeOptions=true) ->
		className = @constructor.name
		layers = _.filter(Framer.CurrentContext.layers, (l) -> (Symbol.getClassName l.name) is className)
		throw new Error "Design for #{className} could not be found." unless layers.length
		image = Symbol.Images[className] or Symbol.Images[className] = Symbol.getImage true, layers...
		refLayer = layers[0]; refLayer.destroy() unless refLayer instanceof Symbol
		profile = if image.stagedProfiles then image.stagedProfiles[0]; image.stagedProfiles.rotate
		super _.defaults {}, layerOptions, image, profile
		@addSubLayer childImage for childImage in image.__children

	addSubLayer: (image, parent=@) ->
		className = Symbol.getClassName image.name
		classObject = window[className]
		if className and not classObject
			throw new Error "#{@constructor.name} cannot find the required #{className} class to initialize its sub-components."
		classObject ?= if image.__isText then TextLayer else Layer
		targetName = Symbol.getTargetName image.name
		initializer = @initializers[targetName] or @initializers[className] or []
		if @initializeOptions and Array.isArray initializer
			image = _.omit image, Object.keys candidate for candidate in initializer if typeof candidate is 'object' and not Array.isArray candidate
		else image = _.omit image, Object.keys initializer if typeof initializer is 'object'
		instance = new (Function::bind.apply classObject, [null].concat initializer) # also concats objects
		instance.props = image # will overwrite layerOptions in initializer with Design Tab layouts unless @initializeOptions
		instance.parent = parent; parent[targetName] = instance if targetName
		@addSubLayer childImage, (instance or temp) for childImage in image.__children if classObject is Layer
