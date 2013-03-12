module ApplicationHelper
  def t(path, options = {})
    super(path, (@i18n_defaults||{}).merge(@i18n_options||{}).merge(options))
  end
end
