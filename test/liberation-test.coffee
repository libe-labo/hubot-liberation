chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'liberation', ->
  beforeEach ->
    @robot = { }

    require('../src/liberation')(@robot)
