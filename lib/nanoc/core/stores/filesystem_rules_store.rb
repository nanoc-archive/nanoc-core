# encoding: utf-8

module Nanoc

  # Loads the rules from the Rules file.
  #
  # @api private
  class FilesystemRulesStore < ::Nanoc::RulesStore

    identifier :filesystem

    # TODO remove me (necessary for storing checksum for rules)
    attr_reader :rule_data

    # @return [String] The name of the Rules filename
    def rules_filename
      'Rules'
    end

    # @see ::Nanoc::RulesStore#load_rules
    def load_rules
      # Get rule data
      if !File.file?(rules_filename)
        raise Nanoc::Errors::NoRulesFileFound.new
      end
      @rule_data = File.read(rules_filename)

      # Load DSL
      dsl = Nanoc::CompilerDSL.new(rules_collection)
      dsl.instance_eval(@rule_data, "./#{rules_filename}")
    end

  end

end
