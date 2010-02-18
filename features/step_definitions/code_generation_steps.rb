
Given /^I have the following code template$/ do |template|
  @template =  template
end

When /^I generate code for mye language$/ do
  require "gherkin/code_generator/cuke_code_generator"
  @code_attributes = CukeCodeGenerator.new(:template => @template).generate
end

Then /^the generated code should contain$/ do |code|
  @code_attributes.should match(/.*#{code}.*/m)
end