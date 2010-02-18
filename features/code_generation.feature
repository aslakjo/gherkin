# language: en
Feature: Code generation
  In order to have language support in all language
  As a develper of other languages like cuke4nuke and cuke4duke
  I want generator to make all my given when then attributes

  Scenario: Correctly formed feature
    Given I have the following code template
    """
        language: <%= language %> keywords: <% keywords.each do |keyword| %><%= keyword %>, <% end %>
    """
    When I generate code for mye language
    Then the generated code should contain
    """
    language: Norwegian keywords: Gitt, N\303\245r, S\303\245,
    """
