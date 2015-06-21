#!/usr/bin/env ruby

require "pstore"

module IntToRn
	module Config
		extend self		
 
		RNSUBBASE = { 'I' => 1, 'V' => 5, 'X' => 10, 'L' => 50, 'C' => 100, 'D' => 500, 'M' => 1000, "#{"V"+"\u203E".encode}" => 5000 }
		RNCUSTOME = File.join(File.dirname(__FILE__), "int_to_rn.pstore")		
	
		def config(skip=true)
			@store = PStore.new(RNCUSTOME) 
			@rn_custom = Hash.new; 
			@rn_custom.replace(RNSUBBASE) 
			load_rn_custom unless skip 
			self
		end
		
		# Loads the client defined roman numerals into @rn_customer.
		def load_rn_custom
			unless (File.size?(RNCUSTOME).nil? || 
				@store.transaction { @store[:custom_numerals] } == @rn_custom ||
				@store.transaction { @store[:custom_numerals] }.nil?)
				@rn_custom.replace(@store.transaction { @store[:custom_numerals] }){ |key, v1, v2| v1 }
			end
			self
		end
	
    # Set the instance variable @rn_custom to provide list, ensuring that none of the
		# custom value contain reference to either 1, 5, I or V. 
		# @param cust_rn [String] list of numbers and their user defined roman numerals.
		def set_rn_custom(cust_rn)
			
			custom_numerals = cust_rn.split(',')
			custom_numerals.each do |value|
				key_value = value.split('=')
				check(key_value).rm_org_val(key_value)
				@rn_custom.merge!(key_value[0].strip => key_value[1].to_i){ |key, v1, v2| v2 }
			end 
			check(@rn_custom) 
			puts "User defined Roman Numerals set #{rn_custom}}"	
			store 
			self
		end
		
		# Return to the caller the contents of the instance variable rn_custom
		# @return [Hash] Contains numeric keys and their user defined roman numeric values. 		
		def rn_custom; @rn_custom; end
		
		# Stores user defined roman numeric values for use on next call.
		# @param over_write [Boolean] indicates whether to overwrite the hash and merge it.
		def store
			@store.transaction do
				@store[:custom_numerals] = @rn_custom
				@store.commit
			end

		  self	
		end

		# Utilized in order to clear user defined roman numeric value.
		def clear
			@store.transaction { @store.delete(:custom_numerals); @store.commit}
			puts "User defined Roman Numerals cleared."
			config(true)			
		end
		
		def rm_org_val(key_value)
			@rn_custom.delete_if {|key, value| value == key_value[1].to_i} if @rn_custom.value?(key_value[1].to_i)
			self
		end

		# Ensures that none of the values in the array key_value are either 1, 5, I or V.
		# @param key_value [Array] consistant of an integer and it user defined roman numeral.
		def check(key_value)
			case key_value.class.to_s
			when 'Array'	
				raise ArgumentError, "Altering values for numeral 1 and 5 is not allowed" if key_value[1].to_i == 1 || key_value[1].to_i == 5
				raise ArgumentError, "Altering the corresponding values for roman numeral 'I' and 'V' not allowed" if key_value[0] == 'I' || key_value[0] == 'V'
				raise ArgumentError, "An attmept was made to set value that is not among the base values #{RNSUBBASE.values}" if !RNSUBBASE.values.include?(key_value[1].to_i) 
			when 'Hash'
				key_value.each do |key, value|
					if RNSUBBASE.key?(key) && RNSUBBASE[key] != key_value[key] && !key_value.value?(RNSUBBASE[key])
						raise ArgumentError, "Roman numeral #{key} to be used as a user defined roman numeral for #{value} provide user defined roman numeral for #{RNSUBBASE[key]}" 
					end
				end
			when 'Fixnum'
				raise ArgumentError, "Currently unable to convert values larger than 8999, primarily due to time restrictions \"next update maybe\"" unless key_value < 9000	
			else
				puts "What happened"
			end
			self
		end
	end
end
