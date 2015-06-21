#!/usr/bin/env ruby

require 'optparse'
require File.join(File.dirname(__FILE__), "config/int_to_rn_config.rb")

module IntToRn
	module Convert
		extend self
		
		# Sudo IntToRn::Convert constructor utilized in order manage the auxiliary functions of module.
		# para args [Array]
		def convert(args)
			@option = {
				:number => nil,
				:cust_numerals => nil,
				:clr_cust_rn => false	
			}
			@float = {}
			IntToRn::Config.config(false)
			option_parse(args) if args.class == Array
			work 
		end 
		
		# User interface
		# @param args [Hash]
		def option_parse(args)
			help = nil
			
			option = OptionParser.new do |opts|
				opts.banner = "Integer to Roman Numeral".center(80, '_')
				opts.separator " "
				opts.separator "DESCRIPTION:"
				opts.separator "	Provides the user with a means of converting an interger value such as \"1\""
				opts.separator "	into it's roman numeral counter part, in the case of \"1\", \"I\" is the outcome." 
				opts.separator "	In Addition it provides the user with a means of defining a customer set of roman numerals."
				opts.separator " "
				opts.separator "USAGE:"
				opts.separator "	./int_to_rn.rb [options] [input] e.g ./int_to_rn.rb -i 1"
				opts.separator " "
				opts.separator "NOTE:"
				opts.separator "	When defining custom roman numerals be aware of the following:"
				opts.separator "	 * You unable to utilize \"V\" or \"I\" as user defined roman numerals."
				opts.separator "	 * You can utilize any other value from the base set (see below) of "
				opts.separator "	   roman numerals but a replacement most be provided." 
				opts.separator "	     e.g. ./int_to_rn.rb -s 'X=50, K=10'"
				opts.separator "	 * When assiging values to your custom roman numerals be aware that you"
				opts.separator "	   are unable to assign values outside the base set"
				opts.separator "	     [1, 5, 10, 50, 100, 500, 1000, 5000]"
				opts.separator "	In regards to decimal number converstion, the following steps are taken"
				opts.separator "	to produce a Roman numeral representation."
				opts.separator "	 * The float is converted int a rational number."
				opts.separator "	 * Following the converstion it is determine whether or not the fraction is a proper or inproper fraction"
				opts.separator "	 * If it is determine that the fraction is an inproper fraction, it is converted into a mixed fraction."
				opts.separator "	 * The rational number or Mixed fraction is then broken up into it various parts 'whole number', 'numerator', and 'denominator'"
				opts.separator "	 * Each part is then converted in to Roman numerals and presented in the following fashion where as a"
				opts.separator "	   period '.' separates the whole number from the fraction and a colon ':' separates the 'numerator',"
				opts.separator "	   and 'denominator'."
				opts.separator "	     e.g 1.25 == I.I:IV"
				opts.separator "	     e.g .5 == I:II"
				opts.separator " "
				opts.separator "OPTIONS:"
				opts.on("-n NUMBER","--number NUMBER", String, "Number to convert to roman numeral") do |n| @option[:number] = n; end
				opts.on("-s CUST_RN", "--cust_rn CUST_RN", String, "Set user defined roman numerals", "e.g 'T=10, F=50'") do |s| @option[:cust_numerals] = s; end
				opts.on("-c", "--clr_cust_rn", "Clear the current set of user defined roman numerals") do |c| @option[:clr_cust_rn] = true; end
				opts.on("-h", "--help"){ puts option }
				help = opts.help
			end.parse!
		
			if (@option[:number].nil? && @option[:cust_numerals].nil? && !@option[:clr_cust_rn])	
				puts help; exit 1
			end
		end
		
		# Utilize in order to perform the primary function in the 
		# integer/float conversion to roman numerals process.	
		def work
			#puts @option[:number].to_f.ceil.class
			IntToRn::Config.check(@option[:number].to_f.ceil)
			unless @option[:number].split('').include?('.')
				set_Integer.print
			else
				set_float.print(true)
			end unless @option[:number].nil?
			IntToRn::Config.config(false).set_rn_custom(@option[:cust_numerals]) unless @option[:cust_numerals].nil?
			IntToRn::Config.config.clear unless !@option[:clr_cust_rn]
			
		end	
		
		# Set @integer to an instance of Rn.
		def set_Integer
			 @integer = Rn.new(@option[:number])
			 self
		end
		
		# Converts the string representation of a float into a rational
		# data type following that it deteremines whether or not the 
		# rational number is a proper or inproper fraction. If it is
		# determined that the ration number is an improper fraction it is
		# converted into a mix number and creates an Rn object from the various
		# parts. If it is determined that it is a proper fraction the Rn
		# objects are created from the numerator, and the denominator.
		def set_float
			_rational = @option[:number].to_f.round(2).to_s.to_r
			_nmtr = _rational.numerator
			_dntr = _rational.denominator
			
			if _nmtr > _dntr
				@float[:wnum] = Rn.new(_nmtr.divmod(_dntr)[0].to_s)
				unless _nmtr.divmod(_dntr)[1] == 0
					@float[:nmtr] = Rn.new(_nmtr.divmod(_dntr)[1].to_s)
				else
					@option[:number] = _nmtr.divmod(_dntr)[0].to_s
					set_Integer.print
				end
				@float[:dntr] = Rn.new(_dntr.to_s) 
			else
				@float[:nmtr] = Rn.new(_nmtr.to_s)
				@float[:dntr] = Rn.new(_dntr.to_s)
			end
			self
		end
		
		# Outputs the converted value
		# @param float [Boolean] Indicated weather or not the value to be output is a integer or a float.
		def print(float=false)
			unless float
				puts @integer.get_rn 
			else
				if @float.length == 3 
					puts "#{@float[:wnum].get_rn}.#{@float[:nmtr].get_rn}:#{@float[:dntr].get_rn}"
				else
					puts "#{@float[:nmtr].get_rn}:#{@float[:dntr].get_rn}"
				end 
			end
			exit
		end 
		
		class Rn	
			def initialize(int)
				@int = int
				@place_value = {}
				@rn = ""
				
				int_to_rn
					.set_rn		
			end
			
			# Splits integer value into an array containing each of it corresponding values and calls set_place_value.
			def int_to_rn; set_place_value(@int.split(''), @place_value); self; end
			
			# Calculates the place value of each value in the corresponding integer. 
			# 	e.g 485 == [400, 80, 5]
			# @param number [Array] String representation of each par of the corresponding integer.
			# @param storage [Hash] Used to store the place values.
			def set_place_value(number, storage)
				e = (number.length - 1)
				number.each do |value|
					storage.merge!({IntToRn::Config::RNSUBBASE['X']**e => (value.to_i * IntToRn::Config::RNSUBBASE['X']**e)})
					e -= 1 
				end
				self
			end
			
			# Determines the Roman Numeral for each value in @place_value and sets @rn to concatenated string containing the full
			# roman numeric value.
			def set_rn
				@place_value.each do |key, value|
					_5th = (key * IntToRn::Config::RNSUBBASE['V'])
					_10th = (key * IntToRn::Config::RNSUBBASE['X']) 
					
					if(_5th > value) && (_5th - value) == key
						@rn += IntToRn::Config.rn_custom.key(key) + IntToRn::Config.rn_custom.key(_5th)
					elsif(_10th > value) && (_5th < value) && (_10th - value) == key 
						@rn += IntToRn::Config.rn_custom.key(key) + IntToRn::Config.rn_custom.key(_10th)
					elsif(_5th < value) 
						@rn += IntToRn::Config.rn_custom.key(_5th) + (IntToRn::Config.rn_custom.key(key)*((value - _5th)/key))
					elsif(_5th == value)
						@rn += IntToRn::Config.rn_custom.key(_5th)
					elsif(_5th > value)
						@rn += IntToRn::Config.rn_custom.key(key)*(value/key)
					end					 
				end
				self
			end
				
			def get_place_value; @place_value; end
			def get_rn; @rn; end
		end
	end
end

IntToRn::Convert.convert(ARGV)
