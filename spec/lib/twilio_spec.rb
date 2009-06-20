require File.dirname(__FILE__) + '/../spec_helper'


############## Helper Functions ##############


def verb_params(verb)
  raise ArgumentError, "#{verb} is not a valid TwiML verb"  if not Twilio.constants.include?(verb.to_s.downcase.titlecase)
  verb_class = eval("Twilio::#{verb.to_s.downcase.titlecase}")
  if verb_class.body_required? or verb_class.body_optional?
    "String body for #{verb_class.verb_name}"
  else
    []
  end
end


############## Verb Shared Groups ##############


describe "a TwiML verb with children", :shared => true do
  it "should be invalid with no children" if described_class.children_required?

  it "should be invalid with a body" if described_class.children_required? or described_class.body_prohibited?

  it "should produce valid XML with no children" do
    @verb.should have(0).children
    @verb.to_xml.should eql("<#{@verb.verb_name}></#{@verb.verb_name}>")
  end

  it "should contain one child" do
    child = @verb.allowed_verbs[0]
    @verb.send(child.downcase.to_sym, *verb_params(child))

    @verb.should have(1).children
  end

  it "should produce valid XML with one child" do
    child = @verb.allowed_verbs[0]
    @verb.send(child.downcase.to_sym, *verb_params(child))

    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.children[0].to_xml}</#{@verb.verb_name}>")
  end

  it "should contain multiple children" do
    3.times do |i|
      child = @verb.allowed_verbs[i % @verb.allowed_verbs.length]
      @verb.send(child.downcase.to_sym, *verb_params(child))
    end

    @verb.should have(3).children
  end

  it "should produce valid XML with multiple children" do
    3.times do |i|
      child = @verb.allowed_verbs[i % @verb.allowed_verbs.length]
      @verb.send(child.downcase.to_sym, *verb_params(child))
    end

    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.children.collect{|a|a.to_xml}.join('')}</#{@verb.verb_name}>")
  end
end


describe "a TwiML verb with a body", :shared => true do
  it_should_behave_like "a TwiML verb with no children"
  it "should be invalid with no body" if described_class.body_required?

  it "should produce valid XML with no body" do
    @verb.to_xml.should eql("<#{@verb.verb_name}></#{@verb.verb_name}>")
  end

  it "should produce valid XML with a body" do
    @verb.body = "Hello, I <3 Ruby!"
    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.body.to_xs}</#{@verb.verb_name}>")
  end
end


describe "a TwiML verb with attributes", :shared => true do
  it "should produce valid XML with no attributes"

  it "should produce valid XML with attributes"

  it "should have attributes"
end


describe "a TwiML verb with no attributes", :shared => true do
  it "should not have any attributes" do
    @verb.should have(0).attributes
  end

  it "should produce valid XML with no attributes"

  it "should be invalid with attributes"
end


describe "a TwiML verb with no children", :shared => true do
  it "should be invalid with children" if described_class.children_prohibited?

  it "should produce valid XML with no children" do
    @verb.to_xml.should eql("<#{@verb.verb_name}></#{@verb.verb_name}>")
  end
end


############## Verb Specs ##############


describe Twilio::Say do
  before(:each) do
    @verb = Twilio::Say.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Play do
  before(:each) do
    @verb = Twilio::Play.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Gather do
  before(:each) do
    @verb = Twilio::Gather.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with children"
end

describe Twilio::Record do
  before(:each) do
    @verb = Twilio::Record.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Dial do
  before(:each) do
    @verb = Twilio::Dial.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with children"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Redirect do
  before(:each) do
    @verb = Twilio::Redirect.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Pause do
  before(:each) do
    @verb = Twilio::Pause.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Hangup do
  before(:each) do
    @verb = Twilio::Hangup.new
  end

  it_should_behave_like "a TwiML verb with no attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Number do
  before(:each) do
    @verb = Twilio::Number.new
  end

  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Response do
  before(:each) do
    @verb = Twilio::Response.new
  end

  it_should_behave_like "a TwiML verb with no attributes"
  it_should_behave_like "a TwiML verb with children"
end
