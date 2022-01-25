module OmniAuth
  module Strategies
    class OpenIDConnect
      def public_key
        return config.jwks if options.discovery

        return key_or_secret if key_or_secret
        return fetch_key if client_options.jwks_uri #modified line
      end

      private

      def fetch_key
        @fetch_key ||= parse_jwk_key(::OpenIDConnect.http_client.get_content(client_options.jwks_uri))
      end
    end
  end
end
