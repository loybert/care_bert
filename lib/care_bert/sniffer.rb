module CareBert
  module Sniffer
    # returns hash with data
    def self.check_table_integrity
      result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      # Load Model definitions
      Rails.application.eager_load!

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
    def self.validate_models progressbar = nil
      #result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      # Load Model definitions
      Rails.application.eager_load!


      klasses = ActiveRecord::Base .descendants
          .select { |c| c.base_class == c && !c.abstract_class?}
          .reject { |c| c.name.start_with?('HABTM_') }
          .sort_by(&:name)
      #klasses = [ATB, Client, Depot, User, Invoice, LineItem, Note, RateSheet, UsageReport, Inbound::Master, Outbound::Master]
      #klasses -= [Note, Attachment, Event]
      klasses = [Inbound::Shipment, Outbound::Shipment]
      max_count = klasses.sum(&:count)
      progressbar.total = max_count unless progressbar.nil?

      result = {}
      threads = []
      #conns = ThreadSafe::Array.new


      klasses.each do |klass|
        threads << Thread.new do
          klass.establish_connection
          result[klass.name] = {
            total: klass.count,
            smell_count: 0, # max klass.count
            errors: Hash.new # max klass.count
          }
          #next
          klass.find_each(batch_size: chunk_size).each do |record|
            [record].reject(&:valid?).each do |record|
              result[klass.name][:smell_count] += 1
              errors_key = record.errors.full_messages || ['unknown validation error!?']
              unless result[klass.name][:errors].key? errors_key
                result[klass.name][:errors][errors_key] = []
              end
              result[klass.name][:errors][errors_key] << record.id
            end rescue nil

            # TODO: check in which constellation the list to sort might ever be nil
            result[klass.name][:errors].select {|err| !err.nil? }.each do |err|
              result[klass.name][:errors][err].sort! rescue nil
            end
            progressbar.increment unless progressbar.nil?
          end
          #klass.connection.close

          result
        end
      end


      thread_results = threads.map(&:join)
      #result = thread_results.inject(&:merge)

      progressbar.finish unless progressbar.nil?

      result
    end

    def self.check_missing_assocs
      result = {}

      chunk_size = CareBert::Configuration::CHUNK_SIZE

      # Load Model definitions
      Rails.application.eager_load!

      klasses = ActiveRecord::Base.descendants.select { |c| c.base_class == c && !c.abstract_class?}.sort_by(&:name)
      klasses -= [Event, Attachment, Waypoint]
      klasses = [ATB, Client, User, Invoice, LineItem, Note, RateSheet, UsageReport]
      #klasses = [HABTM_Ancestors, HABTM_Loads, HABTM_RelatedShipments, HABTM_RelatedWorkItems, HABTM_ScheduledMasters, HABTM_ScheduledTours, HABTM_Successors, HABTM_Tours]

      klasses.each do |klass|
        result[klass.name] = {
          total: klass.count,
          smell_count: 0, # max klass.count
          errors: Hash.new # max klass.count
        }

        unless klass.attribute_names.include?('id')
          result[klass.name][:smell_count] = 666666; result[klass.name][:errors]['XXXXXX'] = {table: 'broken'}
          puts "Skipping Class #{klass.name}..."
        else

          #begin
            klass.find_each(batch_size: chunk_size).each do |record|
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
            end
          #rescue
          #  result[klass.name][:smell_count] = 666666
          #  result[klass.name][:errors]['XXXXXX'] = {table: 'broken'}
          #end # rescue nil
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

    def self.list_tables
      klasses = ActiveRecord::Base.descendants.select { |c| c.base_class == c && !c.abstract_class?}.sort_by(&:name)
      result = {}
      klasses.each do |klass|
        result[klass.name] = {
            total: klass.count
        }
      end
      result
    end


  end

end
