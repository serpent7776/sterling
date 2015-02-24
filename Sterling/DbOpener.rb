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
require 'rdbi-driver-sqlite3';
require 'Sterling/Version';
require 'Sterling/DbTool';
require 'Sterling/DbUpgrader';

module Sterling;

class DbOpener

	@@db_ver = 0;
	@@conn = nil;

	class DbVersionNotSupported < RuntimeError
	end

	class DbAlreadyOpened < RuntimeError
	end

	def self.reset
		@@db_ver = 0
		@@conn = nil
	end

	# try to open database upgrading if needed
	def self.openDatabase(filename)
		if @@conn.nil? then
			@@conn = RDBI.connect(:SQLite3, :database=>filename)
			checkDatabaseVersion()
			return @@conn
		else
			raise DbAlreadyOpened.new 'database already opened'
		end
	end

	# check database version and run upgrade if needed
	def self.checkDatabaseVersion()
		if @@conn.nil? then return false end
		#
		db_ver = nil;
		begin
			#take last entry
			q="SELECT db_ver FROM META ORDER BY ID DESC LIMIT 1"
			db_ver=@@conn.execute(q).fetch(:first)[0].to_i
		rescue RDBI::Error, SQLite3::SQLException
			#if error occurs assume we need to upgrade the db
			#reformat date
			@@conn.transaction do |conn|
				if DbTool.tableExists?(conn, 'transactions') then
					q1="SELECT ID,date FROM transactions"
					q2="UPDATE transactions SET date=? WHERE ID=?"
					stmt_rd=conn.prepare(q1)
					stmt_wr=conn.prepare(q2)
					stmt_rd.execute().each { |data|
						(id,date)=data
						stmt_wr.execute(Date.parse(date).strftime('%Y-%m-%d'), id)
					}
				end
			end
		end
		# database is newer version than we expect
		if db_ver.to_i > @@db_ver then
			raise DbVersionNotSupported, "Database version #{db_ver} is not supported; probably created by newer version application"
		end
		# upgrade database
		if db_ver.nil? then
			upgradeDatabase(0)
			db_ver = 0
		end
		while db_ver < @@db_ver do
			upgradeDatabase(db_ver+1)
			db_ver += 1
		end
		#insert entry
		q=
"INSERT INTO META(mod_by_app_name,mod_by_app_ver,db_ver)
VALUES ('Sterling', #{Version.version}, #{@@db_ver})"
		@@conn.execute(q)
		return true
	end

	def self.upgradeDatabase(version)
		if @@conn.nil? then 
			return false
		else
			DbUpgrader.upgradeDatabase(@@conn, version)
			return true
		end
	end

end

end
