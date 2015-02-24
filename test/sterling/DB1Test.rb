$:.unshift(ENV['basedir'])
require 'test/unit'
require 'Sterling/DB1'

module Sterling

class DB1Test < Test::Unit::TestCase

	def test_getInstance
		db = nil
		dbname = "/tmp/test.db"
		assert_nothing_raised do
			db = DB1.getInstance(dbname)
		end
		assert_not_nil(db, "db is nil")
	end

end

end
