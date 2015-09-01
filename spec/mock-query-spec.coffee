_ = require 'lodash'
mongoose = require 'mongoose'

describe 'MockQuery', ->
  before ->
    schema = new mongoose.Schema
      name: String
    @Model = mongoose.model 'MockQuerySchema', schema

  beforeEach ->
    MongooseSinon = require('../src') @sinon
    @doc = new @Model name: 'hello'

  _.each require('../src/mock-query').SUPPORTED_METHODS, (method) ->

    describe "##{method}", ->

      describe 'using a callback', ->

        it 'supports mocking', (done) ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method] name: 'hello', (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()

        it 'supports empty query', (done) ->
          modelFindMock = @Model[method]
          .forQuery()
          .returns null, [@doc]

          @Model[method] (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()

        it 'supports empty responses', (done) ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, []

          @Model[method] name: 'hello', (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.should.be.empty
            done()

        it 'supports error', (done) ->
          error = new Error "model##{method} error"

          @Model[method]
          .forQuery name: 'hello'
          .returns error

          @Model[method] name: 'hello', (err, docs) ->
            should.exist err
            err.should.equal error
            should.not.exist docs
            done()

        it 'can handle variable number of option arguments', (done) ->
          modelFindMock = @Model[method]
          .forQuery {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}
          .returns null, [@doc]

          @Model[method] {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}, (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()

        it 'does not match unless all arguments match', ->
          modelFindMock = @Model[method]
          .forQuery {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}
          .returns null, [@doc]

          fn = =>
            @Model[method] {name: 'hello'}, {update: 'other data'}, 'projection', {opts: 'config'}
            .then (docs) =>

          fn.should.throw """Unexpected query MockQuerySchema##{method}({"name":"hello"}, {"update":"other data"}, "projection", {"opts":"config"})"""

        it 'supports populate', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .populate 'children'
          .exec (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.populate.callCount.should.equal 1
            modelFindMock.query.populate.should.have.been.calledWith 'children'
            done()

        it 'supports sort', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .sort 'name'
          .exec (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.sort.callCount.should.equal 1
            modelFindMock.query.sort.should.have.been.calledWith 'name'
            done()

        it 'supports populate and sort together', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .populate 'children'
          .sort 'name'
          .exec (err, docs) =>
            should.not.exist err
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.populate.callCount.should.equal 1
            modelFindMock.query.populate.should.have.been.calledWith 'children'
            modelFindMock.query.sort.callCount.should.equal 1
            modelFindMock.query.sort.should.have.been.calledWith 'name'
            done()

        it 'requires #forQuery to be called before @returns', ->
          @Model[method].returns.should.throw 'Must call `forQuery` before calling `returns`'

        it 'throws error for unexpected queries', ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          fn = =>
            @Model[method] name: 'oops', (err, docs) ->

          fn.should.throw "Unexpected query MockQuerySchema##{method}({\"name\":\"oops\"})"

      describe 'using promises', ->

        it 'supports mocking', (done) ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()
          , done

        it 'supports empty query', (done) ->
          modelFindMock = @Model[method]
          .forQuery()
          .returns null, [@doc]

          @Model[method]()
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()
          , done

        it 'supports empty responses', (done) ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, []

          @Model[method]
            name: 'hello'
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.should.be.empty
            done()
          , done

        it 'supports error', (done) ->
          error = new Error "model##{method} error"

          @Model[method]
          .forQuery name: 'hello'
          .returns error

          @Model[method]
            name: 'hello'
          .then ->
            done 'should have been rejected'
          , (err) ->
            should.exist err
            err.should.equal error
            done()

        it 'can handle variable number of option arguments', (done) ->
          modelFindMock = @Model[method]
          .forQuery {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}
          .returns null, [@doc]

          @Model[method] {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            done()
          , done

        it 'does not match unless all arguments match', ->
          modelFindMock = @Model[method]
          .forQuery {name: 'hello'}, {update: 'data'}, 'projection', {opts: 'config'}
          .returns null, [@doc]

          fn = =>
            @Model[method] {name: 'hello'}, {update: 'other data'}, 'projection', {opts: 'config'}
            .then (docs) =>

          fn.should.throw """Unexpected query MockQuerySchema##{method}({"name":"hello"}, {"update":"other data"}, "projection", {"opts":"config"})"""

        it 'supports populate', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .populate 'children'
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.populate.callCount.should.equal 1
            modelFindMock.query.populate.should.have.been.calledWith 'children'
            done()
          , done

        it 'supports sort', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .sort 'name'
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.sort.callCount.should.equal 1
            modelFindMock.query.sort.should.have.been.calledWith 'name'
            done()
          , done

        it 'supports populate and sort together', (done) ->
          modelFindMock = @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          @Model[method]
            name: 'hello'
          .populate 'children'
          .sort 'name'
          .then (docs) =>
            should.exist docs
            docs.should.be.an 'array'
            docs.length.should.equal 1
            docs[0].should.equal @doc
            modelFindMock.query.populate.callCount.should.equal 1
            modelFindMock.query.populate.should.have.been.calledWith 'children'
            modelFindMock.query.sort.callCount.should.equal 1
            modelFindMock.query.sort.should.have.been.calledWith 'name'
            done()
          , done

        it 'requires #forQuery to be called before @returns', ->
          @Model[method].returns.should.throw 'Must call `forQuery` before calling `returns`'

        it 'throws error for unexpected queries', ->
          @Model[method]
          .forQuery name: 'hello'
          .returns null, [@doc]

          fn = =>
            @Model[method] name: 'oops'
            .then (docs) ->

          fn.should.throw "Unexpected query MockQuerySchema##{method}({\"name\":\"oops\"})"
