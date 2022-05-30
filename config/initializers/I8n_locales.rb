# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
Rails.application.configure do
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  I18n.available_locales = [ :de, :en, :fr, :it ]
  config.i18n.default_locale = :en
  config.i18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  config.i18n.fallbacks.map = {
    fr: [ :fr, :en ],
    de: [ :de, :en ],
    it: [ :it, :en ]
  }

=begin # Configuration example with fall-back
  # This configuration allows to define a business specific language and to generate fall-baks for common terms
  I18n.available_locales = [ :de_OFS, :fr_OFS, :it_OFS, :rm_OFS, :de, :fr, :it, :en, :rm ]
  config.i18n.default_locale = :de_OFS
  config.i18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  config.i18n.fallbacks.map = {
    fr_OFS: [ :fr_OFS, :fr, :en ],
    de_OFS: [ :de_OFS, :de, :en ],
    it_OFS: [ :it_OFS, :it, :en ],
    rm_OFS: [ :rm_OFS, :rm, :de_OFS, :de, :en ]
  }
=end

end
