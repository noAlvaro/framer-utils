class exports.Framework

  # assumes new layers are aways visible
  @getLayerImage: ->
    sample = new Layer visible: false
    image = sample.props; sample.destroy()
    _.defaults visible: true, image

  # assumes new texts are aways visible
  @getTextLayerImage: ->
    sample = new TextLayer visible: false
    image = sample.props; sample.destroy()
    _.defaults visible: true, image

  # remove layer image from text images
  @getTextLayerExclusiveImage: ->
    exclusiveKeys = _.difference Object.keys(@TextLayer), Object.keys(@Layer)
    _.pick @TextLayer, exclusiveKeys

  @Layer: @getLayerImage()
  @TextLayer: @getTextLayerImage()
  @TextLayerExclusives: @getTextLayerExclusiveImage()
