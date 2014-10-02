require 'care_bert/configuration'
require 'care_bert/sniffer'
require 'care_bert/reporter'


module CareBert


  # load Railtie if Rails exists
  if defined?(Rails)
    require 'care_bert/railtie'
    #CareBert::Railtie.insert
  end


end
