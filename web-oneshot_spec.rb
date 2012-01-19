require 'rspec'
require './wos.rb'

include Helpers

describe "accept_auth tests" do

  [
    [nil, nil, nil, nil, true],
    ['a', nil, 'blah', 'blah', false],
    ['blah', nil, 'blah', nil, true],
    ['blah', 'blah', 'blah', 'blah', true],
    ['wrong_user', nil, 'blah', nil, false],
    ['right_user', 'wrong_pass', 'right_user', 'pass', false],
    [nil, 'pass', nil, 'pass', true]
  ].each do |passed_user, passed_pass, user, pass, result|

    it "should return #{result} for user = #{passed_user} and pass = #{passed_pass}" do
      @options = {:user => user, :pass => pass}
      accept_auth(passed_user, passed_pass).should == result
    end

  end
end
