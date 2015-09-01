_ = require 'lodash'
MockQuery = require './mock-query'

module.exports = (args...) ->
  sinon = _.find args, (arg) ->
    _.isFunction(arg.stub) and _.isFunction(arg.spy)
  mongoose = _.find args, (arg) ->
    arg.Model?

  sinon ?= require 'sinon'
  mongoose ?= require 'mongoose'

  _.each MockQuery.SUPPORTED_METHODS, (method) ->
    new MockQuery mongoose.Model, method, sinon

  supportedMethods: -> MockQuery.SUPPORTED_METHODS
