{FramerUtils} = require 'FramerUtils'
{Framework} = require 'constants/Framework'

class exports.VisualComponent extends Layer

	@Images: {}

	@Regex:
		titleCase: /\b[A-Z][a-z]*([A-Z][a-z]*)*\b/g
		camelCase: /\b[a-z]+([A-Z][a-z]*)*\b/g

	@getClassName: (fromString) -> fromString?.match(VisualComponent.Regex.titleCase)?[0]

	@getTargetName: (fromString) -> fromString?.split('@')[1]?.match(VisualComponent.Regex.camelCase)?[0]

	@getImage: (resetPoint, layers...) ->
		props = _.map layers, 'props'
		baseImage = if props.length > 1 then @intersectProps props, layers else props[0]
		baseImage.x = baseImage.y = 0 if resetPoint
		output = _.omitBy baseImage, (v, k) -> Framework.Layer[k] is v
		output.children = []; sampleLayer = layers[0]
		output.children.push VisualComponent.getImage false, child for child in sampleLayer.children; output

	@intersectProps: (props, layers) ->
		omitedKeys = [];
		image = _.assignWith {}, props..., (objValue, srcValue, key, object, source) ->
			return srcValue unless key in Object.keys object
			omitedKeys.push key unless objValue is srcValue; srcValue
		output = _.omit image, omitedKeys; output.stagedProfiles = []
		output.stagedProfiles.push _.pick layer.props, omitedKeys for layer in layers
		output


	# LIMIT: Do not instantiate VisualComponents inside VisualComponents of the same type.
	constructor: (layerOptions={}, @initializers={}, @initializeOptions=true) ->
		className = @constructor.name
		layers = _.filter(Framer.CurrentContext.layers, (l) -> (VisualComponent.getClassName l.name) is className)
		throw new Error "Design for #{className} could not be found." unless layers.length
		image = VisualComponent.Images[className] or VisualComponent.Images[className] = VisualComponent.getImage true, layers...
		refLayer = layers[0]; refLayer.destroy() unless refLayer instanceof VisualComponent
		profile = if image.stagedProfiles then image.stagedProfiles[0]; image.stagedProfiles.rotate
		super _.defaults {}, layerOptions, image, profile
		@addSubLayer childImage for childImage in image.children

	addSubLayer: (image, parent=@) ->
		className = VisualComponent.getClassName image.name
		classObject = window[className]
		if className and not classObject
			throw new Error "#{@constructor.name} cannot find the required #{className} class to initialize its sub-components."
		classObject ?= Layer
		targetName = VisualComponent.getTargetName image.name
		initializer = @initializers[targetName] or @initializers[className] or []
		if @initializeOptions and Array.isArray initializer
			image = _.omit image, Object.keys candidate for candidate in initializer if typeof candidate is 'object' and not Array.isArray candidate
		else image = _.omit image, Object.keys initializer if typeof initializer is 'object'
		instance = new (Function::bind.apply classObject, [null].concat initializer) # also concats objects
		instance.props = image # will overwrite layerOptions in initializer with Design Tab layouts unless @initializeOptions
		instance.parent = parent; parent[targetName] = instance if targetName
		@addSubLayer childImage, (instance or temp) for childImage in image.children if classObject is Layer
