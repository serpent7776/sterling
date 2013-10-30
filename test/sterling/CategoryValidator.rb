$:.unshift(ENV['basedir'])
require 'Sterling/CategoryValidator.rb'

tests={
	'basic' => {
		# valid category entries
		{'name' => 'simplename'} => 0,
		{'name' => 'name with space'} => 0,
		{'name' => 'numb3rs'} => 0,
		{'name' => 'text-spaced'} => 0,
		{'name' => 'text.with.dots'} => 0,
		#{'name' => 'some ąśðćżę utf-8'} => true,
		# invalid entries
		{'name' => '#special^syms/'} => 1,
		{'name' => '.doted'} => 1,
		{'name' => '-dashed'} => 1,
		{'name' => ''} => 1,
		}
}

tests['basic'].each{|categoryData,result|
	r=Sterling::CategoryValidator.validate(categoryData)
	if r[:code] != result then fail "Failed test for category #{categoryData.to_s} with error ##{r[:code]}: #{r[:msg]}" end
}
