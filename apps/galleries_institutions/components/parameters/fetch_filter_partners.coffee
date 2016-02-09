Backbone = require 'backbone'
_ = require 'underscore'
metaphysics = require '../../../../lib/metaphysics.coffee'
partnerTypes = require '../../queries/partner_types.coffee'
query = require '../../queries/partners_filter_query.coffee'
facetDefaults = require '../filter_facet/facet_defaults.coffee'

{ FeaturedCities } = require 'places'

module.exports = class FetchFilterPartners extends Backbone.Model

  initialize: ({ @params }) ->
    _.each _.pluck(facetDefaults, 'facetName'), (f) =>
      @listenTo @params, "change:#{f}", @reset
    @page = 1
    @partners = []
    @aggregations = new Backbone.Model
    @totalResults = 0

  fetch: =>
    return if @allFetched or @fetching
    @fetching = true

    data = @formatVariables()
    metaphysics
      query: query
      variables: data
    .then (response) =>
      if data.includeAggregations && data.includeResults
        @totalResults = response.results.total

      if data.includeAggregations
        _.each _.omit(response, 'results'), (aggregationFacet, facetName) =>
          @aggregations.set facetName,
            total: aggregationFacet.total,
            countItems: aggregationFacet.aggregations[0].counts

      if data.includeResults
        newPartners = response.results.hits
        Array.prototype.push.apply @partners, response.results.hits

      @allFetched = @partners.length >= @totalResults
      @trigger 'partnersAdded', newPartners

      @fetching = false
      @page++

  formatVariables: ->
    paramsJSON = @params.toJSON()
    data = _.extend _.pick(paramsJSON, 'category'), type: partnerTypes[paramsJSON.type]
    city = _.findWhere FeaturedCities, slug: paramsJSON.location if paramsJSON.location
    data.near = city.coords.join (',') if city

    data.page = @page
    data.includeAggregations = @page == 1
    data.includeResults = @params.hasSelection()
    return data

  reset: =>
    @partners = []
    @allFetched = false
    @page = 1
    @aggregations.clear()
    @totalResults = 0
    @trigger 'reset', this
