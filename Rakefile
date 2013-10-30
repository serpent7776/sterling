#Rakefile for sterling v0.11
import 'Rakefile.inc';

CPP_FLAGS=[];
ASM_FLAGS=[];
OPTS={
	'MKBUILDDIRS'=>false,	# do not create bin and obj directories since we do not compile anything
	'TEST'=>true,
}

Tasks={
	'sterling'=>{
		:type=>:empty,
	}
}

SourceFlags={
}

Test={
	'sterling'=>[
		{:name=>'clear', :file=>'clear.sh'},
		{:name=>'db', :file=>'db.rb'},
		{:name=>'CategoryValidator', :file=>'CategoryValidator.rb'},
		{:name=>'TransactionValidator', :file=>'TransactionValidator.rb'},
		{:name=>'TransactionsFilter', :file=>'TransactionsFilter.rb'},
		]
}

Install=[
	{:src=>'sterling', :type=>:exec, :opts=>{}},
	{:src=>'data/sterling.png', :type=>:icon, :opts=>{}},
	{:src=>'Sterling', :type=>:ruby_module, :opts=>{}},
]
