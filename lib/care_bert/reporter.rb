module CareBert

  module Reporter

    def self.validate_models report
      puts "-- records -     smells - model --"
      report.each_key do |klass_name|
        printf "%10d - %10d - %s\n", report[klass_name][:total], report[klass_name][:smell_count], klass_name
      end

      puts "\n\n"

      report.each_key do |klass_name|
        # check if smells present
        if report[klass_name][:errors].present?
          # print klass headline
          puts "#{klass_name}: "
          # sum up ids by error-construct
          report[klass_name][:errors].each do |err, ids|
            puts "#{err} >> #{ids}"
          end
          puts
        end
      end

    end

    def self.table_integrity report
      puts "-- records - broken instances - model --"
      anything_broken = false
      report.each_key do |klass_name|
        printf "%10d - %16d - %s\n", report[klass_name][:total], report[klass_name][:broken_instances].count, klass_name
        anything_broken = true if report[klass_name][:broken_instances].count > 0
      end

      if anything_broken
        puts "\n\n"
        puts 'Listing ids of broken models:'
        puts '-------------------------------'
        report.each_key do |klass_name|
          printf " -  %s\n    >> %s\n\n", klass_name, report[klass_name][:broken_instances]
        end
      end

    end


    def self.missing_assocs report
      puts "-- records - broken instances - model --"
      anything_broken = false
      report.each_key do |klass_name|
        printf "%10d - %16d - %s\n", report[klass_name][:total], report[klass_name][:smell_count], klass_name
        anything_broken = true if report[klass_name][:errors].present?
      end

      if anything_broken
        puts "\n\n"
        puts 'Listing ids of missing model-instances of assocs:'
        puts '-------------------------------------------------------'
        report.each_key do |klass_name|
          if report[klass_name][:errors].present?
            puts "- #{klass_name} --------------"
            sorted_keys = report[klass_name][:errors].keys.collect{|b| b.to_i}.sort
            puts ">> affected_instances: #{sorted_keys}"
            sorted_keys.each do |record_id|
              printf " -  %s    >> %s\n", record_id, report[klass_name][:errors][record_id.to_s]
            end
          end
        end
      end

    end

  end

end
