# vim: set sw=4 ts=4:
#
# Copyright © 2012,2013,2014 Serpent7776. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

require 'rdbi';
require 'rdbi-driver-sqlite3';
require 'date';
require 'Sterling/Category';
require 'Sterling/Transaction';
require 'Sterling/CategoryValidator';
require 'Sterling/Version';
require 'Sterling/rdbi_result_driver_hash';

module Sterling

class DB

	def initialize(filename)
		@db_ver=0.10;
		@conn=RDBI.connect(:SQLite3, :database=>filename)
		#create tables
		query=
"CREATE TABLE IF NOT EXISTS categories(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  parentID NUMERIC,
  name TEXT
);"
		@conn.execute(query)
		query=
"CREATE TABLE IF NOT EXISTS transactions(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT,
  count NUMERIC,
  value NUMERIC,
  categoryID NUMERIC,
  descr TEXT
);"
		@conn.execute(query)
		#create indices
		query="CREATE INDEX IF NOT EXISTS transactions_category_index ON transactions(categoryID)";
		@conn.execute(query);
		#try to upgrade db
		upgradeDatabase()
	end


	#upgrade database from previous version
	def upgradeDatabase
		begin
			#take last entry
			q="SELECT db_ver FROM META ORDER BY ID DESC LIMIT 1"
			db_ver=@conn.execute(q).fetch(:first)[0].to_f
		rescue RDBI::Error, SQLite3::SQLException
			#if error occurs assume we need to upgrade the db
			#create META table
			q=
"CREATE TABLE META(
	ID INTEGER PRIMARY KEY AUTOINCREMENT,
	mod_by_app_name TEXT,	-- name of application that modified database
	mod_by_app_ver TEXT,	-- version of application that modified database
	db_ver TEXT				-- version to which db was upgraded
)"
			@conn.execute(q)
			#upgrade db
			q1="SELECT ID,date FROM transactions"
			q2="UPDATE transactions SET date=? WHERE ID=?"
			stmt_rd=@conn.prepare(q1)
			stmt_wr=@conn.prepare(q2)
			stmt_rd.execute().each { |data|
				(id,date)=data
				stmt_wr.execute(Date.parse(date).strftime('%Y-%m-%d'), id)
			}
			#insert entry
			q=
"INSERT INTO META(mod_by_app_name,mod_by_app_ver,db_ver)
VALUES ('Sterling', #{Version.version}, #{@db_ver})"
			@conn.execute(q)
		end
	end

	#create two basic categories
	def createDefaultCategories
		query="INSERT INTO categories(ID,name,parentID) VALUES(1, 'incomes', 0);"
		@conn.execute(query);
		query="INSERT INTO categories(ID,name,parentID) VALUES(2, 'expenses', 0);"
		@conn.execute(query);
	end

	#return number of categories
	def getCategoriesCount
		query="SELECT COUNT(ID) FROM categories";
		@conn.execute(query).fetch(:first)[0].to_i;
	end

	# Method: getCategory
	# Return data for category with given id
	#
	# Parameters:
	# 	id	-	id of a category; must be positive number
	def getCategory(id)
		if not id>0 then raise ArgumentError, 'category id must be positive' end
		query="SELECT ID,parentID,name FROM categories WHERE ID=#{id.to_i}";
		return @conn.execute(query).as(:Hash).fetch(:first);
	end

	#return ID of category with given name
	def getCategoryId(name)
		q='SELECT ID FROM categories WHERE name=?'
		id=nil
		@conn.prepare(q) do |stmt|
			id=stmt.execute(name).fetch(:first)[0]
		end
		return id
	end

	# Method: getCategoryPath
  	# Return path for given category
	#
	# Params:
	# 	id	-	id of a category; must be positive number
	def getCategoryPath(id)
		if not id>0 then raise ArgumentError, 'category id must be positive' end
		query = <<EOS
WITH RECURSIVE
tpath(rowno, ID, parentID, name, cpath) AS (
	SELECT  1, id, parentid, name, name from categories WHERE id=?
	UNION
	SELECT p.rowno+1, c.id,c.parentID,c.name, c.name || '/' || p.cpath FROM tpath AS p left join categories AS c on p.parentID=c.ID
	where c.parentid>=0
)
SELECT cpath FROM tpath ORDER BY rowno DESC LIMIT 1;
EOS
		path = ''
		stmt=@conn.prepare(query);
		ar=stmt.execute(id.to_i).as(:Array).fetch(:first)
		path=ar[0]
		return path
	end

	#insert new category
	def insertCategory(categoryData)
		query="INSERT INTO categories(parentID, name) VALUES(?, ?)";
		stmt=@conn.prepare(query);
		res=stmt.execute(categoryData['parentID'].to_i, categoryData['name'].to_s);
		stmt.finish;
		#return res.affected_count
	   	#TODO: return some status code
   	end

	# Method: updateCategory
	# Updates category with given id
	#
	# Parameters:
	# categoryID	-	id of a category to update, must be positive integer
	# categoryData	-	hash of category data
	def updateCategory(categoryID, categoryData)
		if not categoryID>0 then raise ArgumentError, 'categoryID must be positive integer' end
		if CategoryValidator.validate(categoryData)
			query="UPDATE categories SET parentID=?, name=? WHERE ID=?"
			stmt=@conn.prepare(query)
			res=stmt.execute(categoryData['parentID'].to_i, categoryData['name'].to_s, categoryID.to_i)
			stmt.finish
		end
		return nil
		#return res.result_count	# always return 0
		#TODO: return some status code
	end

	# Method: removeCategory
	# Removes category with given id
	#
	# Parameters:
	# 	categoryID	-	id of a category to be removed
	def removeCategory(categoryID)
		if not categoryID>0 then raise ArgumentError, 'categoryID must be positive integer' end
		#TODO: wrap this into transaction
		parentID=getCategory(categoryID)['parentID']
		#remove category
		query="DELETE FROM categories WHERE ID=?";
		stmt=@conn.prepare(query);
		stmt.execute(categoryID.to_i);
		stmt.finish;
		#move all transactions from removed category to parent
		query="UPDATE transactions SET categoryID=? WHERE categoryID=?";
		stmt=@conn.prepare(query);
		stmt.execute(parentID, categoryID);
		stmt.finish;
		#move all subcategories from removed category to parent category
		query="UPDATE categories SET parentID=? WHERE parentID=?";
		stmt=@conn.prepare(query);
		stmt.execute(parentID, categoryID);
		stmt.finish;
		#TODO: return some status code
	end

	#execute block for each category
	def iterateCategories(&block)
		if block_given?
			query="SELECT ID,parentID,name FROM categories";
			stmt=@conn.prepare(query);
			res=stmt.execute();
			#iterate_stmt(res, &block);
			res.as(:Hash).each(&block)
			return 0;
		end
		return -1;
	end

	# Method: getTransaction
	# Return data for transaction with given id
	#
	# Parameters:
	# 	id	-	id of a transaction, must be positive integer
	def getTransaction(id)
		if not id>0 then raise ArgumentError, 'transaction id must be positive integer' end
		query="SELECT ID, date, count, value, categoryID, descr FROM transactions WHERE ID=#{id.to_i}";
		return @conn.execute(query).as(:Hash).fetch(:first)
	end

   	#insert new transaction
	def insertTransaction(transactionData)
		query="INSERT INTO transactions(date, count, value, categoryID, descr) VALUES(?, ?, ?, ?, ?)";
		stmt=@conn.prepare(query);
		date= (transactionData['date'].nil? ? Date.today : Date.parse(transactionData['date'])).strftime('%Y-%m-%d')
		#stmt.execute(Date::parse(transactionData['date']).strftime('%Y-%m-%d'), transactionData['count'].to_i, transactionData['value'].to_f, transactionData['categoryID'].to_i, transactionData['descr'].to_s);
		stmt.execute(date, transactionData['count'].to_f, transactionData['value'].to_f, transactionData['categoryID'].to_i, transactionData['descr'].to_s);
		stmt.finish;
		#TODO: return rowID
	end

	# Method: updateTransaction
   	# Update transaction with given id
	#
	# Parameters:
	#   id     -   id of a transaction
	#   data   -   new data to be set
	def updateTransaction(id, data)
		if not id>0 then raise ArgumentError, 'transaction id must be positive integer' end
		query="UPDATE transactions SET date=?, count=?, value=?, categoryID=?, descr=? WHERE ID=?";
		stmt=@conn.prepare(query);
		date= data['date'].to_s.empty? ? Date::jd.strftime('%Y-%m-%d') : Date::parse(data['date']).strftime('%Y-%m-%d');
		stmt.execute(date, data['count'].to_f, data['value'].to_f, data['categoryID'].to_i, data['descr'].to_s, id.to_i);
		stmt.finish;
		#TODO: return some status code
	end

	# Method: removeTransaction
	# Removes transaction with given id
	#
	# Parameters:
	#   transactionID   -   id of a transaction
	def removeTransaction(transactionID)
		if not transactionID>0 then raise ArgumentError, 'transactionID must be positive integer' end
		query="DELETE FROM transactions WHERE ID=?";
		stmt=@conn.prepare(query);
		stmt.execute(transactionID.to_i);
		stmt.finish;
		#TODO: return some status code
	end

	#execute block for each transaction (pass all data as parameters)
	def iterateTransactions(&block)
		if block_given?
			query="SELECT ID,date,count,value,categoryID,descr FROM transactions ORDER BY date DESC";
			stmt=@conn.prepare(query);
			res=stmt.execute();
			res.as(:Hash).each(&block)
			return 0;
		end
		return -1;
	end

	#execute block for each transaction (pass only basic data as parameters)
	def iterateTransactionsShort(&block)
		if block_given?
			query="SELECT ID,count,value,categoryID FROM transactions";
			stmt=@conn.prepare(query);
			res=stmt.execute();
			res.as(:Hash).each(&block)
			return 0;
		end
		return -1;
	end

end

end
