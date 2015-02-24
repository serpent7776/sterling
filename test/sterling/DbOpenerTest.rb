$:.unshift(ENV['basedir'])
require 'test/unit'
require 'Sterling/DbOpener'
require 'Sterling/Version'

module Sterling

class DbOpenerTest < Test::Unit::TestCase

	def test_openDatabase
		conn = nil
		dbname = "/tmp/test.db"
		if File.exists?(dbname) then
			File.delete(dbname)
		end
		assert_nothing_raised do
			conn = DbOpener.openDatabase(dbname)
		end
		assert_not_nil(conn, "db connection is nil")
		DbOpener.reset
	end

	def test_openDatabaseTwiceThrows
		conn = nil
		dbname = "/tmp/test.db"
		if File.exists?(dbname) then
			File.delete(dbname)
		end
		assert_nothing_raised do
			conn = DbOpener.openDatabase(dbname)
		end
		assert_not_nil(conn, "db connection is nil")
		assert_raise(DbOpener::DbAlreadyOpened) do
			conn = DbOpener.openDatabase(dbname)
		end
		DbOpener.reset
	end

	def test_upgradeNewerDatabaseFails
		conn = nil
		dbname = "/tmp/test.db"
		if File.exists?(dbname) then
			File.delete(dbname)
		end
		assert_nothing_raised do
			conn = DbOpener.openDatabase(dbname)
		end
		assert_not_nil(conn, "db connection is nil")
		query = "INSERT INTO META(mod_by_app_name,mod_by_app_ver,db_ver) VALUES('Sterling', #{Version.version}, 9999)"
		conn.execute(query)
		assert_raise DbOpener::DbVersionNotSupported do
			DbOpener.checkDatabaseVersion
		end
		DbOpener.reset
	end

	def test_verifyDatabase
		conn = nil
		dbname = "/tmp/test.db"
		if File.exists?(dbname) then
			File.delete(dbname)
		end
		assert_nothing_raised do
			conn = DbOpener.openDatabase(dbname)
		end
		assert_not_nil(conn, "db connection is nil")
		assert_nothing_raised do
			query = 'SELECT COUNT(*) FROM META'
			count = conn.execute(query).fetch(:first)[0].to_i
			assert(count>0, "META table is empty")
		end
		assert_nothing_raised do
			query = 'SELECT COUNT(*) FROM categories'
			count = conn.execute(query).fetch(:first)[0].to_i
			assert(count>0, "categories table is empty")
		end
		DbOpener.reset
	end

end

end
