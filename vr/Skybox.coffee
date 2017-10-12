{Ease} = require 'Ease'
{VRComponent} = require 'third-party/vr-component/VRComponent'

class exports.Skybox extends VRComponent

  constructor: (imagePaths) ->

    super imagePaths

    @animationOptions = curve: Ease.ExpoOut, time: 0.3
    @panning = false
    @viewAngle = 180

    @sideAngle = @viewAngle / 2
    @higherInterval = min: 360 - @sideAngle, max: 360 + @sideAngle
    @lesserInterval = min: 0 - @sideAngle, max: 0 + @sideAngle
    @time = .35

    # @on Events.MouseMove, @lookAround

  lookAround: (event) =>
    offset = (if @heading > @higherInterval.min then @higherInterval else @lesserInterval).min
    @animateStop(); @animate properties:
      heading: (event.x / Screen.width) * @viewAngle + offset
      elevation: (event.y / Screen.height - .5) * -@sideAngle
