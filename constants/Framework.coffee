class exports.Framework

  # assumes new layers are aways visible
  @getLayerImage: ->
    sample = new Layer visible: false;
    image = sample.props; sample.destroy()
    _.defaults visible: true, image

  @Layer: Framework.getLayerImage()
