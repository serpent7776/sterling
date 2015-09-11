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

class TransactionValidator

	def TransactionValidator.validate(transactionData)
		r=validateDate(transactionData['date'])
		if r[:code]>0 then return r end
		r=validateCount(transactionData['count'])
		if r[:code]>0 then return r end
		r=validateValue(transactionData['value'])
		if r[:code]>0 then return r end
		return {:code=>0, :msg=>'ok'}
	end

	def TransactionValidator.validateDate(date)
		r= date=~/^[0-9]+$/
		if r==0 then return {:code=>1, :msg=>'Invalid date'} end
		begin
			Date.parse(date)
		rescue ArgumentError
			return {:code=>1, :msg=>'Invalid date'}
		else
			return {:code=>0, :msg=>'ok'}
		end
	end

	def TransactionValidator.validateCount(count)
		#r= count=~/^[1-9][0-9]*$/
		r= count.to_s=='0' ? nil : count=~/^[0-9]+(\.[0-9]+)?$/
		return r.nil? ? {:code=>2, :msg=>'Count must be a positive decimal'} : {:code=>0, :msg=>'ok'}
	end

	def TransactionValidator.validateValue(value)
		r= value=~/^-?[0-9]+(\.[0-9]+)?$/
		return r.nil? ? {:code=>3, :msg=>'Value must be a decimal'} : {:code=>0, :msg=>'ok'}
	end

end

end
