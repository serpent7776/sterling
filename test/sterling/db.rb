$:.unshift(ENV['basedir'])
require 'Sterling/DB.rb'

$db=Sterling::DB.new('sterling.db')
if $db.nil? then fail 'db.create' end

$db.createDefaultCategories

n=$db.getCategoriesCount
if n!=2 then fail 'categories.no' end

category={'name'=>'rootcat', 'parentID'=>0}
r=$db.insertCategory(category);
#if r then fail 'cat.insert' end

r=$db.getCategory(3);
if r['name']!='rootcat' then fail 'cat.get' end

category={'name'=>'subcategory', 'parentID'=>3}
r=$db.insertCategory(category);
r=$db.getCategoryPath(4)
if r!='rootcat/subcategory' then fail "cat.getpath: #{r}" end

category={'name'=>'subsubcategory', 'parentID'=>4}
r=$db.insertCategory(category);
r=$db.getCategoryPath(5)
if r!='rootcat/subcategory/subsubcategory' then fail "cat.getpath: #{r}" end

n=$db.getCategoriesCount
if n!=5 then fail 'categories.no' end

r=$db.getCategoryId('subcategory')
if r!=4 then fail 'categories.id' end

id=r
category={'name'=>'subcategory_new', 'parentID'=>3}
r=$db.updateCategory(id, category);
#if not r>0 then fail "cat.update #{r}" end
r=$db.getCategory(id);
if r['name']!='subcategory_new' then fail 'cat.update2' end

r=$db.removeCategory(3)
#if not r then fail 'cat.remove' end
r=$db.getCategory(4);
if r['parentID']!=0 then fail 'cat.remove2' end

transaction={'date'=>nil, 'count'=>1, 'value'=>10, 'categoryID'=>0, 'descr'=>'foo'}
r=$db.insertTransaction(transaction)
tid=1
r=$db.getTransaction(tid)
if r['descr']!='foo' or r['value']!=10 then fail 'tr.insert' end

transaction['value']=25
r=$db.updateTransaction(tid, transaction)
#if r.descr!='foo' or r.value!=10 then fail 'tr.update' end
r=$db.getTransaction(tid)
if r['descr']!='foo' or r['value']!=25 then fail 'tr.update2' end

r=$db.removeTransaction(tid)
#if r then fail 'tr.remove' end
r=$db.getTransaction(tid)
if not r.nil? then fail 'tr.remove2' end

begin
	$data=$db.getCategory(-1)
	fail 'calling getCategory with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling getCategory with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.getCategoryPath(-1)
	fail 'calling getCategoryPath with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling getCategoryPath with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.updateCategory(-1, {})
	fail 'calling updateCategory with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling updateCategory with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.removeCategory(-1)
	fail 'calling removeCategory with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling removeCategory with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.getTransaction(-1)
	fail 'calling getTransaction with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling getTransaction with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.updateTransaction(-1, {})
	fail 'calling updateTransaction with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling updateTransaction with nonpositive parameter didn\'t raise ArgumentError'
end

begin
	$data=$db.removeTransaction(-1)
	fail 'calling removeTransaction with nonpositive parameter didn\'t raise error'
rescue ArgumentError
	# ok
else
	fail 'calling removeTransaction with nonpositive parameter didn\'t raise ArgumentError'
end
