module SpreeStoreUrlPatch
    def formatted_url
      @formatted_url ||= begin
        clean_url = url.to_s.sub(%r{^https?://}, '').split(':').first
  
        if Rails.env.development? || Rails.env.test?
          scheme = Rails.application.routes.default_url_options[:protocol] || :http
          port = Rails.application.routes.default_url_options[:port].presence || (Rails.env.development? ? 3000 : nil)
  
          if scheme.to_sym == :https
            "https://#{clean_url}#{port ? ":#{port}" : ''}"
          else
            "http://#{clean_url}#{port ? ":#{port}" : ''}"
          end
        else
          "https://#{clean_url}"
        end
      end
    end
    
    def formatted_custom_domain
      return unless default_custom_domain
  
      @formatted_custom_domain ||= if Rails.env.development? || Rails.env.test?
        protocol = Rails.application.routes.default_url_options[:protocol] || 'http'
        port = Rails.application.routes.default_url_options[:port]
        "#{protocol}://#{default_custom_domain.url}#{port ? ":#{port}" : ''}"
      else
        "https://#{default_custom_domain.url}"
      end
    end
    
    def formatted_url_or_custom_domain
      formatted_custom_domain || formatted_url
    end
  end
  
  Spree::Store.prepend(SpreeStoreUrlPatch)