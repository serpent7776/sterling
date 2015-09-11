# vim: set sw=4 ts=4:
#
# Copyright © 2013 Serpent7776. All Rights Reserved.
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

require 'date'

module Sterling

class TransactionsFilter

	#DESCRIPTION_MODE_EXACT = 1		# only exact matches
	DESCRIPTION_MODE_SUBSTR = 2		# match substring
	#DESCRIPTION_MODE_PATTERN = 3	# shell pattern
	#DESCRIPTION_MODE_REGEX = 4		# regular expression

	def initialize
		@date=nil			# nil | [date_min, date_max]
		@count=nil			# nil | [count_min, count_max]
		@value=nil			# nil | [value_min, value_max]
		@category=nil		# nil | categoryID
		@description=nil	# nil | string
		@options={
			#'category.recursive' => false,					# bool	whether to include entries from subcategories
			'description.mode' => DESCRIPTION_MODE_SUBSTR,	# DESCRIPTION_MODE_*
		}			
		@fieldNames={
			'date' => 'date',
			'count' => 'count',
			'value' => 'value',
			'category' => 'categoryID',
			'description' => 'description',
		}
	end

	def getopt(opt)
		if @options.has_key?(opt)
			return @options[opt]
		else
			return nil
		end
	end

	def setopt(opt, value)
		if @options.has_key?(opt)
			return @options[opt]=value
		else
			return nil
		end
	end

	def date_min
		return @date.nil? ? nil : @date[0]
	end

	def date_max
		return @date.nil? ? nil : @date[1]
	end

	def count_min
		return @count.nil? ? nil : @count[0]
	end

	def count_max
		return @count.nil? ? nil : @count[1]
	end

	def value_min
		return @value.nil? ? nil : @value[0]
	end

	def value_max
		return @value.nil? ? nil : @value[1]
	end

	def date_min
		return @date.nil? ? nil : @date[0]
	end

	def date_max
		return @date.nil? ? nil : @date[1]
	end

	def categoryID
		return @category.nil? ? nil : @category
	end

	def description
		return @description.nil? ? nil : @description
	end

	def date=(date)
		@date=[]
		if date.is_a?(Array) and date.size==2 and (date[0].to_s.empty? or date[1].to_s.empty? or date[0]<=date[1])
			date.each_index{|i|
				if date[i].is_a?(DateTime)
					@date[i]=date[i]
				elsif date[i].is_a?(String) and not date[i].empty?
					@date[i]=DateTime.parse(date[i])
				else
					@date[i]=nil
				end
			}
		else
			@date=nil
		end
	end

	def count=(count)
		@count=[]
		if count.is_a?(Array) and count.size==2 and (count[0].to_s.empty? or count[1].to_s.empty? or count[0]<=count[1])
			count.each_index{|i|
				if count[i].is_a?(Float)
					@count[i]=count[i]
				elsif count[i].is_a?(Integer)
					@count[i]=count[i].to_f
				elsif count[i].is_a?(String) and not count[i].empty?
					@count[i]=count[i].to_f
				else
					@count[i]=nil
				end
			}
		else
			@count=nil
		end
	end

	def value=(value)
		@value=[]
		if value.is_a?(Array) and value.size==2 and (value[0].to_s.empty? or value[1].to_s.empty? or value[0]<=value[1])
			value.each_index{|i|
				if value[i].is_a?(Float)
					@value[i]=value[i]
				elsif value[i].is_a?(Integer)
					@value[i]=value[i].to_f
				elsif value[i].is_a?(String) and not value[i].empty?
					@value[i]=value[i].to_f
				else
					@value[i]=nil
				end
			}
		else
			@value=nil
		end
	end

	def category=(category)
		if category.is_a?(Integer) and category>0
			@category=category
		else
			@category=nil
		end
	end

	def description=(descr)
		if descr.is_a?(String) and (not descr.empty?)
			@description=descr
		else
			@description=nil
		end
	end

	def filter(data)
		if @date.is_a?(Array) and data.has_key?(@fieldNames['date'])
			if not filter_date(data[@fieldNames['date']]) then return false end
		end
		#
		if @count.is_a?(Array) and data.has_key?(@fieldNames['count'])
			if not filter_count(data[@fieldNames['count']]) then return false end
		end
		#
		if @value.is_a?(Array) and data.has_key?(@fieldNames['value'])
			if not filter_value(data[@fieldNames['value']]) then return false end
		end
		#
		if (not @category.nil?) and data.has_key?(@fieldNames['category'])
			if not filter_category(data[@fieldNames['category']]) then return false end
		end
		#
		if (not @description.nil?) and data.has_key?(@fieldNames['description'])
			if not filter_description(data[@fieldNames['description']]) then return false end
		end
		#
		return true;
	end

	def fieldNames(names)
		@fieldNames.merge!(names)
	end

	private

	def filter_date(date)
		date=DateTime.parse(date)
		r1=	(@date[0].nil? or @date[0]<=date)
		r2=	(@date[1].nil? or @date[1]>=date)
		return (r1 and r2)
	end

	def filter_count(count)
		count=count.to_f
		r1=(@count[0].nil? or @count[0]<=count)
		r2=(@count[1].nil? or @count[1]>=count)
		return (r1 and r2)
	end

	def filter_value(value)
		value=value.to_f
		r1= (@value[0].nil? or @value[0]<=value)
		r2= (@value[1].nil? or @value[1]>=value)
		return (r1 and r2)
	end

	def filter_category(categoryID)
		return (@category.nil? or @category==categoryID.to_i)
	end

	def filter_description(description)
		description=description.to_s
		return (@description.nil? or description.include?(@description))
	end

end

end
