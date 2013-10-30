$:.unshift(ENV['basedir'])
require 'Sterling/TransactionsFilter.rb'

data=[
	#0
	{
		'date' => '02.10.1998',
		'count' => 2,
		'value' => 22.5,
		'categoryID' => 7,
		'description' => 'lorem ipsum foobar',
	}
]

filters=
[
	#0
	{
		:date => ['01.05.1998', nil],
	},
	#1
	{
		:date => ['1998-09-01', '2000-09-30'],
		:count => [1, nil],
	},
	#2
	{
		:count => [5, 10],
		:value => [10, 20],
	},
	#3
	{
		:count => [1, 3],
		:categoryID => 7,
	},
	#4
	{
		:categoryID => 5,
		:description => 'foo',
	},
	#5
	{
		:count => [nil, 5],
	},
	#6
	{
		:value => [nil, 10],
	},
	#7
	{
		:date => [nil, '1.01.1995'],
	},
]

test_results=[
	#data 0
	[
		true,	#filter 0
		true,	#filter 1
		false,	#filter 2
		true,	#filter 3
		false,	#filter 4
		true,	#filter 5
		false,	#filter 6
		false,	#filter 7
	],
]

filters.each_index{|f|
	filterData=filters[f]
	filter=Sterling::TransactionsFilter.new
	if filterData.has_key?(:date)
		filter.date=filterData[:date]
	end
	if filterData.has_key?(:count)
		filter.count=filterData[:count]
	end
	if filterData.has_key?(:value)
		filter.value=filterData[:value]
	end
	if filterData.has_key?(:categoryID)
		filter.category=filterData[:categoryID]
	end
	if filterData.has_key?(:description)
		filter.description=filterData[:description]
	end
	data.each_index{|d|
		dt=data[d]
		result=filter.filter(dt)
		expected=test_results[d][f]
		if result!=expected
			fail "Test failed for data ##{d} and filter ##{f}: got result '#{result}', expected '#{expected}'"
		end
	}
}
