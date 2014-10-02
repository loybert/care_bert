module CareBert
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/care_bert_tasks.rake'
      end
    end
  end

  # class Railtie
  # def self.insert
  #---
  # end
  # end
end
