require 'care_bert'

#desc "Explaining what the task does"
#task :care_bert do
#   # Task goes here
#  puts "success"
#end


# file: validate_models.rake
# task: rake db:validate_models
namespace :care_bert do
  desc "Run model validations on all model records in database"
  task :validate_models => :environment do
    # ANALYZE all
    report = CareBert::Sniffer.validate_models
    CareBert::Reporter.validate_models report
  end

  desc "Tries to load all instances and tracks failures on load"
  task :table_integrity => :environment do
    report = CareBert::Sniffer.check_table_integrity
    CareBert::Reporter.table_integrity report
  end

  desc "Checks all belongs_to-associations of all instances and checks presence of model if foreign-key is set"
  task :missing_assocs => :environment do
    report = CareBert::Sniffer.check_missing_assocs
    CareBert::Reporter.missing_assocs report
  end


end