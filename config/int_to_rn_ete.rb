#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "int_to_rn_config.rb")


puts IntToRn::Config.config.clear.rn_custom
begin 
	IntToRn::Config.config(false).set_rn_custom('I=10, K=10').rn_custom
rescue Exception => e
	puts e.message
end
begin 
	IntToRn::Config.config(false).set_rn_custom('V=500, K=50').rn_custom
rescue Exception => e
	puts e.message
end

begin
	IntToRn::Config.config(false).set_rn_custom('L=1, K=100').rn_custom
rescue Exception => e
	puts e.message
end

begin
	IntToRn::Config.config(false).set_rn_custom('L=5, K=500').rn_custom
rescue Exception => e
  puts e.message
end

begin
	IntToRn::Config.config(false).set_rn_custom('L=11, K=10')
rescue Exception => e
	puts e.message
end

begin
	IntToRn::Config.config(false).set_rn_custom('L=10, K=6000')
rescue Exception => e
	puts e.message
end

begin
 puts IntToRn::Config.config(false).set_rn_custom('X=50, K=100').rn_custom
rescue Exception => e
  puts e.message
end

puts IntToRn::Config.config(false).set_rn_custom('T=10, F=50').rn_custom
puts IntToRn::Config.config(false).set_rn_custom('S=10, U=100, K=1000').rn_custom
puts IntToRn::Config.config.clear.rn_custom
