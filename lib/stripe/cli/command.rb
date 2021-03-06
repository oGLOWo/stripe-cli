require 'parseconfig'

module Stripe
  module CLI
    class Command < Thor
      @@root_config = ::File.expand_path('~/.stripecli')
      @@local_config = ::File.expand_path('./.stripecli')

      class_option :key, :aliases => :k
      class_option :env, :aliases => :e
      class_option :version, :aliases => :v
      class_option :dollar_amounts, :type => :boolean

      protected

      def api_key
        @api_key ||= options[:key] || stored_api_option('key')
      end

      def api_version
        @api_version ||= options.delete(:version) || stored_api_option('version')
      end

      def environment
        @env ||= options.delete(:env) || config['default']
      end

      def dollar_amounts
        convert_amount_to_dollars = options.delete(:dollar_amounts)
        convert_amount_to_dollars.nil? ?
        stored_api_option('dollar_amounts') == 'false' ?
        false : true : convert_amount_to_dollars
      end

      def stored_api_option option
        if File.exists?(config_file)
          if environment
            config[environment][option.to_s] || config[option.to_s]
          else
            config[option.to_s]
          end
        end
      end

      def config
        ParseConfig.new(config_file) if File.exist?(config_file)
      end

      def config_file
        File.exist?(@@local_config) ? @@local_config : @@root_config
      end

      def list klass, options
        request klass, :all, options, api_key
      end

      def find klass, id
        request klass, :retrieve, id, api_key
      end

      def delete klass, id
        request klass.new( id, api_key ), :delete
      end

      def create klass, options
        request klass, :create, options, api_key
      end

      def request object, method, *arguments
        Stripe.api_version = api_version unless api_version.nil?
        begin
          output object.send method, *arguments
        rescue StripeError => e
          output e.message
        end
      end

    private

      def output objects
        ap inspect( objects ), :indent => -2
      end

      def inspect object
        case object
        when Array
          object.map {|o| inspect(o) }
        when Hash
          handle_hash object
        when Stripe::ListObject
          inspect object.data
        when Stripe::StripeObject
          inspect object.instance_variable_get(:@values)
        when Numeric
          object > 1000000000 ? Time.at( object ) : object
        else
          object
        end
      end

      def handle_hash object
        object.inject({}) do |hash, (key, value)|
          hash[key] = inspect( value )
          hash
        end
      end
    end
  end
end