# vim: set sw=4 ts=4:
#
# Copyright © 2015 Serpent7776. All Rights Reserved.
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

module Sterling;

class DbUpgrader

	class DatabaseUpgradeError < RuntimeError
	end

	# upgrade database to given version
	def self.upgradeDatabase(conn, version)
		var = version.to_i
		msg = "upgrade_#{var}"
		begin
			if self.respond_to?(msg) then
				send(msg, conn)
			else
				raise DatabaseUpgradeError, "Upgrade database to version #{version} not supported"
			end
		rescue RDBI::Error, SQLite3::SQLException
			raise DatabaseUpgradeError "Upgrading database to version #{version} failed"
		end
	end

	private
	def self.upgrade_0(dbconn)
		dbconn.transaction do |conn|
			query=
"CREATE TABLE IF NOT EXISTS categories(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  parentID NUMERIC,
  name TEXT
);"
			conn.execute(query)
			query=
"CREATE TABLE IF NOT EXISTS transactions(
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT,
  count NUMERIC,
  value NUMERIC,
  categoryID NUMERIC,
  descr TEXT
);"
			conn.execute(query)
			# create meta table
			query=
"CREATE TABLE IF NOT EXISTS META(
	ID INTEGER PRIMARY KEY AUTOINCREMENT,
	mod_by_app_name TEXT,	-- name of application that modified database
	mod_by_app_ver TEXT,	-- version of application that modified database
	db_ver TEXT		-- version to which db was upgraded
)"
			conn.execute(query)
			#create indices
			query="CREATE INDEX IF NOT EXISTS transactions_category_index ON transactions(categoryID)";
			conn.execute(query);
			#insert basic categories
			query="INSERT INTO categories(ID,name,parentID) VALUES(1, 'incomes', 0);"
			conn.execute(query);
			query="INSERT INTO categories(ID,name,parentID) VALUES(2, 'expenses', 0);"
			conn.execute(query);
		end
	end

end

end

