require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'gherkin/code_generator/cuke_code_generator'

describe Gherkin::CodeGenerator do
  before :each do
    @generator = Gherkin::CodeGenerator.new( :template => "<%= language %>" )
    @generator.generate
  end

  it "should not have illegal characters in attribute names" do
    @generator.keywords.flatten.each do |keyword|
      keyword.should_not =~ /[\(\)<>\s']/
    end
  end

  it "should not have nil values as keywords" do
    @generator.keywords.flatten.include?(nil).should be_false
  end

  it "should remove text in parantesis" do
    @generator.keywords.flatten.each do |keyword|
      keyword.should_not == "Romanian(diacritical)"
    end
  end

  describe "keywords" do
    it "should be unique within one language" do
      @generator.keywords.each do |language|
        language_name = language.first
        keywords = language[1,10]
        keywords.uniq.should == keywords
      end
    end

    it "should not give given when then as i18n keywords" do
      @generator.keywords.flatten.each do |keyword|
        keyword.should_not =~ /^given$/i
        keyword.should_not =~ /^when$/i
        keyword.should_not =~ /^then$/i
      end
    end
  end

  describe "template from file" do
    it "should take the tempalate form file" do
      template = "<%= language %><% keywords.each do |keyword|%><%= keyword %><% end %>\n"

      File.open("file_with_template.erb", 'w') do |f|
        f.write template 
      end

      NORWEGIAN_LINE = /NorwegianGitt/
      Gherkin::CodeGenerator.new("file_with_template.erb").generate.should match NORWEGIAN_LINE
    end
  end
end
