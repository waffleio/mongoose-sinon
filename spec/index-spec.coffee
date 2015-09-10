_ = require 'lodash'
mongoose = require 'mongoose'
proxyquire = require 'proxyquire'

describe 'mongoose-sinon', ->
  before ->
    schema = new mongoose.Schema
      name: String
    @Model = mongoose.model 'IndexSchema', schema

  it 'has #supportedMethods', ->
    MongooseSinon = require('../src') @sinon

    should.exist MongooseSinon.supportedMethods, 'should have #supportedMethods'
    MongooseSinon.supportedMethods.should.be.a 'function'
    MongooseSinon.supportedMethods().should.be.an 'array'
    MongooseSinon.supportedMethods().length.should.equal 4

  it 'stubs Model methods', ->
    MongooseSinon = require('../src') @sinon

    _.each MongooseSinon.supportedMethods(), (methodName) =>
      should.exist @Model[methodName].isSinonProxy, "@Model.#{methodName} should be a sinon stub"
      @Model[methodName].isSinonProxy.should.be.true
      should.exist @Model[methodName].forQuery, "@Model.#{methodName} should have a #forQuery function"
      @Model[methodName].forQuery.should.be.a 'function'
      should.exist @Model[methodName].returns, "@Model.#{methodName} should have a #returns function"
      @Model[methodName].returns.should.be.a 'function'

  it 'uses passed in sinon instance', ->
    global = require 'sinon'
    sandbox = global.sandbox.create()

    @sinon.stub sandbox, 'stub'
    @sinon.stub global, 'stub'

    MongooseSinon = require('../src') sandbox

    global.stub.callCount.should.equal 0
    sandbox.stub.callCount.should.equal MongooseSinon.supportedMethods().length
    global.stub.should.not.have.been.called
    _.each MongooseSinon.supportedMethods(), (method) ->
      sandbox.stub.should.have.been.calledWith mongoose.Model, method

    sandbox.restore()

  it 'requires sinon if not passed in', ->
    global = require 'sinon'
    sandbox = global.sandbox.create()

    @sinon.spy global, 'stub'
    @sinon.spy sandbox, 'stub'

    MongooseSinon = require('../src')()

    global.stub.callCount.should.equal MongooseSinon.supportedMethods().length
    sandbox.stub.callCount.should.equal 0
    _.each MongooseSinon.supportedMethods(), (method) ->
      global.stub.should.have.been.calledWith mongoose.Model, method

    # Have to manually clean up after this test because it is not in a sandbox
    _.each global.stub.args, ([thisValue, fnName]) ->
      thisValue[fnName].restore()

  it 'uses passed in mongoose instance', ->
    MockQueryStub = @sinon.stub()
    required = require 'mongoose'
    passed = Model: {}

    MongooseSinon = proxyquire('../src', './mock-query': MockQueryStub) @sinon, passed

    MockQueryStub.callCount.should.equal MongooseSinon.supportedMethods().length
    MockQueryStub.should.have.always.been.calledWith passed.Model
    MockQueryStub.should.not.have.been.calledWith required.Model

  it 'requires mongoose if not passed in', ->
    MockQueryStub = @sinon.stub()
    required = require 'mongoose'

    MongooseSinon = proxyquire('../src', './mock-query': MockQueryStub) @sinon

    MockQueryStub.callCount.should.equal MongooseSinon.supportedMethods().length
    MockQueryStub.should.have.always.been.calledWith required.Model

  it 'supports passing arguments in reverse order', ->
    MockQueryStub = @sinon.stub()
    MongooseStub = Model: {}

    MongooseSinon = proxyquire('../src', './mock-query': MockQueryStub) MongooseStub, @sinon

    MockQueryStub.callCount.should.equal MongooseSinon.supportedMethods().length
    _.each MockQueryStub.args, ([model, method, sinon]) =>
      should.exist model, 'should have passed model'
      model.should.equal MongooseStub.Model
      should.exist sinon, 'should have passed sinon'
      sinon.should.equal @sinon

  it 'supports passing only mongoose', ->
    sinon = require 'sinon'
    MockQueryStub = @sinon.stub()
    MongooseStub = Model: {}

    MongooseSinon = proxyquire('../src', './mock-query': MockQueryStub) MongooseStub

    MockQueryStub.callCount.should.equal MongooseSinon.supportedMethods().length
    _.each MockQueryStub.args, ([model, method, sinon]) ->
      should.exist model, 'should have passed model'
      model.should.equal MongooseStub.Model
      should.exist sinon, 'should have passed sinon'
      sinon.should.equal sinon
