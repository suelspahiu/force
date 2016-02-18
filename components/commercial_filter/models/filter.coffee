Backbone = require 'backbone'
Q = require 'bluebird-q'
{ defaults, extend, pick } = require 'underscore'
Aggregations = require '../collections/aggregations.coffee'
Artworks = require '../../../collections/artworks.coffee'
metaphysics = require '../../../lib/metaphysics.coffee'

module.exports = class Filter
  extend Backbone.Events

  constructor: ({ @params } = {}) ->
    throw new Error 'Requires a params model' unless @params?
    @artworks = new Artworks()
    @aggregations = new Aggregations()

    @params.on 'change', @fetch, @

  query: ->
    query = """
      query filterArtworks(
        $aggregations: [ArtworkAggregation]!,
        $for_sale: Boolean,
        $size: Int,
        $page: Int,
        $color: String,
        $price_range: String,
        $gene_id: String,
        $medium: String
      ){
        filter_artworks(
          aggregations: $aggregations,
          for_sale: $for_sale,
          size: $size,
          page: $page,
          color: $color,
          price_range: $price_range,
          gene_id: $gene_id,
          medium: $medium
        ){
          total
          aggregations {
            ... aggregations
          }
          hits {
            ... artwork
          }
        }
      }
      #{require '../queries/artwork.coffee'}
      #{require '../queries/aggregations.coffee'}
    """

  fetch: ->
    Q.promise (resolve, reject) =>
      metaphysics query: @query(), variables: @params.current()
        .then ({ filter_artworks }) =>
          @artworks.reset filter_artworks.hits
          @aggregations.reset filter_artworks.aggregations
          resolve @
        .catch (error) ->
          reject error