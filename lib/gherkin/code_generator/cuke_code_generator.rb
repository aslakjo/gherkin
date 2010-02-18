module Gherkin
  class CodeGenerator

    def initialize(erb)
      require 'erb'

      @keywords = []

     @erb_template = set_code_template(erb)
    end

    def generate
      generate_steps_for_all_supported_languages
    end

    def write_to_file(file)
      steps_file = File.open(file, "w")

      steps = generate()

      steps_file.puts steps
      steps_file.close
    end

    def generate_steps_for_all_supported_languages
      steps = ""
      Gherkin::I18n.all.each do |lang|
          keywords = narative_keywords(lang)
          language = lang.keywords("grammar_name").first
          language = strip_keyword_of_paranteses language
          @keywords << [language, keywords].flatten

          template = ERB.new(@erb_template)
          steps += template.result(binding)
          steps += "\n"
      end

      steps
    end

    def keywords
      @keywords
    end

    def narative_keywords(language)
      [fetch_keyword_for(language, "given"), fetch_keyword_for(language, "when"), fetch_keyword_for(language, "then")].uniq
    end

    private
    def set_code_template(erb)
       if not erb.class.to_s == "Hash"
        IO.read(erb)
      else
        erb[:template]
      end
    end

    def fetch_keyword_for(language, keyword)
      translated_keyword = language.keywords(keyword).last
      translated_keyword = strip_illegal_characters translated_keyword

      if contains_standard_keyword? translated_keyword
        nil
      else
        translated_keyword
      end
    end

    def contains_standard_keyword?(i18n_keyword)
      standard_keywords = ["given", "when", "then"]

      standard_keywords.each do |keyword|
        if keyword =~ /^#{i18n_keyword}$/i
          return true
        end
      end

      false
    end

    def strip_illegal_characters(keyword)
      keyword.gsub(/[<>\s']/, "")
    end

    def strip_keyword_of_paranteses(language)
      language.gsub(/[\)\(]/, "")
    end
  end
end