require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'gherkin/code_generator/cuke_code_generator'

describe CukeCodeGenerator do
  before :each do
    @generator = CukeCodeGenerator.new( :template => "<%= language %>" )
    @generator.generate
  end

  it "should not have illegal characters in attribute names" do
    @generator.keywords.flatten.each do |keyword|
      keyword.should_not =~ /[\(\)<>\s']/
    end
  end

  it "should remove text in parantesis" do
    @generator.keywords.flatten.each do |keyword|
      keyword.should_not == "Romanian(diacritical)"
    end
  end

  describe "keywords" do
    it "should have a unique list of keywords" do
      @generator.keywords.uniq.should == @generator.keywords
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
      CukeCodeGenerator.new("file_with_template.erb").generate.should match NORWEGIAN_LINE
    end
  end
end
