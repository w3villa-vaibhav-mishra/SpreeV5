# config/initializers/spree_store_url_patch.rb
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

# Use on_load to ensure Spree::Store is loaded before applying the patch
ActiveSupport.on_load(:spree_store) do
  Spree::Store.prepend(SpreeStoreUrlPatch)
end

# Add a fallback in case the :spree_store hook is not defined
Rails.application.config.after_initialize do
  if defined?(Spree::Store) && !Spree::Store.included_modules.include?(SpreeStoreUrlPatch)
    Spree::Store.prepend(SpreeStoreUrlPatch)
  end
end