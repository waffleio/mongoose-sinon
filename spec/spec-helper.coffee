mongoose = require 'mongoose'
sinon = require('sinon-as-promised') mongoose.Promise.ES6

before ->
  @sinon = sinon.sandbox.create()

afterEach ->
  @sinon.restore()
