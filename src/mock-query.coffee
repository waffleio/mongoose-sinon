mongoose = require 'mongoose'
mongoose.Promise = require('q').Promise
_ = require 'lodash'

class MockQuery
  @SUPPORTED_METHODS: ['find', 'findById', 'findOne', 'update']

  _mocks: []

  constructor: (Model, method, sinon) ->
    me = @

    sinon.stub Model, method, (args..., callback) ->
      if callback? and not _.isFunction callback
        args.push callback
        callback = undefined

      mock = _.findLast me._mocks, (mock) ->
        _.isEqual mock.query, args

      unless mock
        query = _.map args, (arg) ->
          JSON.stringify arg
        query = query.join ", "
        throw "Unexpected query #{@modelName}##{method}(#{query})"

      [error, result] = mock.result

      if _.isFunction callback
        setTimeout ->
          callback error, result

      me.query = _mockQuery {sinon, error, result}

    Model[method].forQuery = @forQuery
    Model[method].returns = @returns

  forQuery: (@_query...) => @

  returns: (result...) =>
    unless @hasOwnProperty '_query'
      throw new Error 'Must call `forQuery` before calling `returns`'

    @_mocks.push
      query: @_query
      result: result

    delete @_query

    @

  _mockQuery = (args) ->
    {sinon, error, result} = args

    mockQuery = mongoose.Promise.ES6 (resolve, reject) ->
      if error?
        reject error
      else if args.hasOwnProperty 'result'
        resolve result

    _.assign mockQuery,
      lean: sinon.stub().returns mockQuery
      populate: sinon.stub().returns mockQuery
      select: sinon.stub().returns mockQuery
      sort: sinon.stub().returns mockQuery
      exec: (cb) ->
        setTimeout ->
          cb error, result
        , 1

module.exports = MockQuery
