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

module Sterling

require 'gtk2';
require 'date';
require 'Sterling/DateSelector';

class DateEntry < Gtk::HBox

	def initialize
		super
		@ctrl=Hash.new
		@ctrl['date']=Gtk::Entry.new.set_editable(false);
		@ctrl['date_sel']=Gtk::Button.new('...')
		add(@ctrl['date']).pack_start(@ctrl['date_sel'], false, false)
		proc_date_sel=Proc.new{
			dialog=DateSelector.new(self.toplevel)
			response_id=dialog.run
			date=dialog.getDate
			dialog.close
			if response_id==Gtk::Dialog::ResponseType::OK
				str=Date.new(date[0], date[1], date[2]).strftime('%d.%m.%Y')
				@ctrl['date'].text=str
			end
		}
		@ctrl['date_sel'].signal_connect(:clicked, &proc_date_sel)
		#@ctrl['date_sel'].signal_connect(:'mnemonic-activate', &proc_date_sel)
	end

	def text
		return @ctrl['date'].text
	end

	def text=(text)
		return @ctrl['date'].text=text
	end

end

end
