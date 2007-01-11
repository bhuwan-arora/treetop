require 'rubygems'
require 'spec/runner'

dir = File.dirname(__FILE__)
require "#{dir}/spec_helper"

context "An &-predication on a terminal symbol" do
  setup do
    @terminal = TerminalSymbol.new("foo")
    @and_predicate = AndPredicate.new(@terminal)
  end
  
  specify "succeeds without updating the index upon parsing matching input" do
    input = @terminal.prefix
    index = 0
    result = @and_predicate.parse_at(input, index, mock("Parser"))
    result.should_be_success
    result.interval.end.should_equal index
  end
  
  specify "fails upon parsing non-matching input" do
    input = "baz"
    @and_predicate.parse_at(input, 0, mock("Parser")).should_be_failure
  end
end

context "A sequence with terminal symbol followed by an &-predicate on another terminal symbol" do
  setup do
    @terminal = TerminalSymbol.new("foo")
    @and_predicate = AndPredicate.new(TerminalSymbol.new("bar"))
    @sequence = Sequence.new([@terminal, @and_predicate])
  end
  
  specify "succeeds when look-ahead predicate matches, without updating the index past the end of the first terminal" do
    input = "---" + @terminal.prefix + @and_predicate.expression.prefix
    index = 3
    result = @sequence.parse_at(input, index, mock("Parser"))
    result.should_be_success
    result.interval.end.should_equal index + @terminal.prefix.size
  end
  
  specify "fails when look-ahead predicate does not match" do
    input = "---" + @terminal.prefix + "baz"
    index = 3
    @sequence.parse_at(input, index, mock("Parser")).should_be_failure
  end
end