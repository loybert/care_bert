module CareBert
  module Sniffer
    # returns hash with data
    def self.check_table_integrity
      result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      Dir.glob(Rails.root.join('/app/models/**/*.rb')).each { |file| require file }
      ActiveRecord::Base.descendants.select { |c| c.base_class == c }.sort_by(&:name).each do |klass|
        total = klass.count

        result[klass.name] = Hash.new
        result[klass.name][:total] = total
        result[klass.name][:broken_instances] = []

        (total / chunk_size + 1).times do |i|
          begin
            chunk = klass.find(:all, offset: (i * chunk_size), limit: chunk_size)
            chunk.to_a
          rescue
            # puts "Crashed while loading model #{klass.name}"
            track_unloadable_instances(klass, offset..(offset + chunk_size - 1)).each do |id|
              result[klass.name][:broken_instances] << id
            end
          end
        end
        result[klass.name][:broken_instances].sort!
      end
      result
    end

    # inspired from from: http://blog.hasmanythrough.com/2006/8/27/validate-all-your-records
    def self.validate_models
      result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      Dir.glob(Rails.root.join('/app/models/**/*.rb')).each { |file| require file }
      ActiveRecord::Base.descendants.select { |c| c.base_class == c }.sort_by(&:name).each do |klass|
        result[klass.name] = {
          total: klass.count,
          smell_count: 0, # max klass.count
          errors: Hash.new # max klass.count
        }

        (result[klass.name][:total] / chunk_size + 1).times do |i|
          chunk = klass.find(:all, offset: (i * chunk_size), limit: chunk_size)
          chunk.reject(&:valid?).each do |record|
            result[klass.name][:smell_count] += 1
            errors_key = record.errors.full_messages || ['unknown validation error!?']
            unless result[klass.name][:errors].key? errors_key
              result[klass.name][:errors][errors_key] = []
            end
            result[klass.name][:errors][errors_key] << record.id
          end rescue nil

          # TODO: check in which constellation the list to sort might ever be nil
          result[klass.name][:errors].select { |err| !err.nil? }.each { |err| result[klass.name][:errors][err].sort! } rescue nil
        end
      end

      result
    end

    def self.check_missing_assocs
      result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      Dir.glob(Rails.root.join('/app/models/**/*.rb')).each { |file| require file }
      ActiveRecord::Base.descendants.select { |c| c.base_class == c }.sort_by(&:name).each do |klass|
        result[klass.name] = {
          total: klass.count,
          smell_count: 0, # max klass.count
          errors: Hash.new # max klass.count
        }

        (result[klass.name][:total] / chunk_size + 1).times do |i|
          chunk = klass.find(:all, offset: (i * chunk_size), limit: chunk_size)
          chunk.each do |record|

            failing_fields = {}

            [:belongs_to].each do |assoc_type| # optional => :has_one
              fields = klass.reflect_on_all_associations(assoc_type).map(&:name)

              fields.each do |field|
                # puts "Check #{klass.name} => #{field}"

                id_field = "#{field}_id"
                if record.respond_to?(id_field)
                  foreign_id = record.send(id_field)
                  if foreign_id.present? && record.send(field).blank?
                    failing_fields[field] = foreign_id
                    result[klass.name][:smell_count] += 1
                  end
                end
              end
            end

            result[klass.name][:errors][record.id.to_s] = failing_fields if failing_fields.present?
          end rescue nil
        end

      end
      result
    end

    def self.track_unloadable_instances(klass, id_range)
      result = []
      id_range.each do |id|
        begin
          klass.find(id)
        rescue
          result << id
        end
      end
      result
    end
  end
end
