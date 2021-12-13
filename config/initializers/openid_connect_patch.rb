module OmniAuth
  module Strategies
    class OpenIDConnect

      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          kc_idp_hint: options.kc_idp_hint,
          response_type: options.response_type,
          response_mode: options.response_mode,
          scope: options.scope,
          state: new_state,
          login_hint: params['login_hint'],
          ui_locales: params['ui_locales'],
          claims_locales: params['claims_locales'],
          prompt: options.prompt,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd,
          acr_values: options.acr_values,
        }

        opts.merge!(options.extra_authorize_params) unless options.extra_authorize_params.empty?

        client.authorization_uri(opts.reject { |_k, v| v.nil? })
      end

		end
	end
end

