Backbone = require 'backbone'
_ = require 'underscore'
{ FeaturedCities } = require 'places'
FollowButtonView = require '../../../../components/follow_button/view.coffee'
ViewHelpers = require './view_helpers.coffee'
Profile = require '../../../../models/profile.coffee'
template = -> require('./index.jade') arguments...

module.exports = class PartnerCellView extends Backbone.View
  className: 'partner-cell'

  initialize: ({ @following, @partner, @preferredCitySlug }) ->

  postRender: -> _.defer =>
    @followButton = new FollowButtonView
      el: @$('.js-follow-button')
      following: @following
      model: new Profile @partner.profile
      modelName: 'profile'

  render: ->
    city = _.findWhere FeaturedCities, slug: @preferredCitySlug if @preferredCitySlug
    @$el.html template
      partner: @partner
      preferredCity: city?.name
      ViewHelpers: ViewHelpers
    @postRender()
    this
