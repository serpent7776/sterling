$:.unshift(ENV['basedir'])
require 'Sterling/TransactionValidator.rb'

tests={
	'date' => {
		# valid category entries
		Date.today.strftime('%Y-%m-%d') => 0,
		'2013-08-25' => 0,
		'02.10.1998' => 0,
		'3/10/1990' => 0,
		'05/06/1998' => 0,
		# invalid entries
		'2010-15-30' => 1,
		'123' => 1,
		'foo' => 1,
		'33/10/1995' => 1,
		'00/00/1998' => 1,
		'' => 1,
	},
	'count' => {
		# valid
		'123' => 0,
		'1' => 0,
		'1.5' => 0,
		# invalid
		'a' => 2,
		'0' => 2,
		'-1' => 2,
		'' => 2,
	},
	'value' => {
		# valid
		'1' => 0,
		'12345' => 0,
		'12.5' => 0,
		'12.0' => 0,
		'-12' => 0,
		'0' => 0,
		'-1.4' => 0,
		# invalid
		'a' => 3,
		'12,4' => 3,
		'' => 3,
		'1.-1' => 3,
		'12e' => 3,
	}
}

tests['date'].each{|date,result|
	r=Sterling::TransactionValidator.validateDate(date)
	if r[:code] != result then fail "Failed test for date #{date} with error ##{r[:code]}: #{r[:msg]}" end
}

tests['count'].each{|count,result|
	r=Sterling::TransactionValidator.validateCount(count)
	if r[:code] != result then fail "Failed test for count #{count} with error ##{r[:code]}: #{r[:msg]}" end
}

tests['value'].each{|value,result|
	r=Sterling::TransactionValidator.validateValue(value)
	if r[:code] != result then fail "Failed test for value #{value} with error ##{r[:code]}: #{r[:msg]}" end
}
