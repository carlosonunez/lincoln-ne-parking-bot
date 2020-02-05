# frozen_string_literal: true

module SpecHelpers
  module Integration
    module SharedSecrets
      def self.generate_secret_path!(secret_name:)
        secret_folder = ENV['SHARED_SECRETS_FOLDER'] || '/secrets'
        raise 'Secrets folder not found' unless Dir.exist? secret_folder

        secret_path = "#{secret_folder}/#{secret_name}"
        return secret_path if File.exist? secret_path

        raise "No secret found at: #{secret_path}"
      end

      def self.read(secret_name:)
        File.read(generate_secret_path!(secret_name: secret_name))
      end
    end
  end
end
