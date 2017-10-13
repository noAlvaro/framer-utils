{Framework} = require 'constants/Framework'

class exports.VisualComponent extends Layer

	@Images: {}

	@Regex:
		titleCase: /\b[A-Z][a-z]*([A-Z][a-z]*)*\b/g
		camelCase: /\b[a-z]+([A-Z][a-z]*)*\b/g

	@getClassName: (fromString) -> fromString.match(VisualComponent.Regex.titleCase)?[0]

	@getTargetName: (fromString) -> fromString.split('@')[1]?.match(VisualComponent.Regex.camelCase)?[0]

	@getImage: (layer, resetPoint = false) ->
		candidate = layer.props
		candidate.x = candidate.y = 0 if resetPoint
		output = _.omitBy candidate, (v, k) -> Framework.Layer[k] is v
		output.children = []
		output.children.push VisualComponent.getImage child for child in layer.children
		output

# IMPORTANT 1:	layerOptions within initializers will be replaced by props that were customized in Design Tab.
# IMPORTANT 2:	Subcomponent classes must be available inside `window` scope.
# In Framer Studio you can declare it liek: `class @ClassName extends VisualComponent`

	constructor: (layerOptions={}, @initializers={}, @initializeOptions=true) ->
		className = @constructor.name
		unless image = VisualComponent.Images[className]
#			TODO: intersect images to disambiguate classes without listeners... like this:
#			candidates = _.filter(Framer.CurrentContext.layers, (l) -> (VisualComponent.getClassName l.name) is className)
#			... and then using _.assignInWith to assemble intersection into a single image object
			unless design = _.find(Framer.CurrentContext.layers, (l) -> (VisualComponent.getClassName l.name) is className)
				throw new Error "Design for #{className} could not be found."
			VisualComponent.Images[className] = image = VisualComponent.getImage design, true; design.destroy()
		super _.defaults layerOptions, image
		@addSubLayer childImage for childImage in image.children

	addSubLayer: (image, parent=@) ->
		className = VisualComponent.getClassName image.name
		classObject = window[className]
		if className and not classObject
			throw new Error "#{@constructor.name} cannot find the required #{className} class to initialize its sub-components."
		classObject ?= Layer
		targetName = VisualComponent.getTargetName image.name
		initializer = @initializers[targetName] or @initializers[className] or []
		print @ if className is 'Word'
		if @initializeOptions and Array.isArray initializer
			image = _.omit image, Object.keys candidate for candidate in initializer if typeof candidate is 'object' and not Array.isArray candidate
		else image = _.omit image, Object.keys initializer if typeof initializer is 'object'
		instance = new (Function::bind.apply classObject, [null].concat initializer) # also concats objects
		instance.props = image # will overwrite layerOptions in initializer with Design Tab layouts unless @initializeOptions
		instance.parent = parent; parent[targetName] = instance if targetName
		@addSubLayer childImage, (instance or temp) for childImage in image.children if classObject is Layer
