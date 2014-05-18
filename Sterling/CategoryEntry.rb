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

require 'gtk2';
require 'Sterling/CategorySelector';
require 'Sterling/DB1.rb';

module Sterling

class CategoryEntry < Gtk::HBox

	def initialize
		super
		@data={
			:categoryID => 0,
		}
		@ctrl={}
		@ctrl['category']=Gtk::Entry.new.set_editable(false);
		@ctrl['category'].editable=false;
		@ctrl['category_sel']=Gtk::Button.new('...');
		#
		self.add(@ctrl['category']).pack_start(@ctrl['category_sel'], false, false);
		#
		proc_category_sel=Proc.new{
			dialog=CategorySelector.new(self.toplevel);
			dialog.setData(@data[:categoryID]);
			response_id=dialog.run;
			categoryID=dialog.getData;
			dialog.close;
			if (response_id==Gtk::Dialog::ResponseType::OK)
				@data[:categoryID]=categoryID;
				@ctrl['category'].text=DB1.getInstance.getCategoryPath(categoryID);
			end
		}
		#
		@ctrl['category_sel'].signal_connect(:clicked, &proc_category_sel)
	end

	def categoryID()
		return @data[:categoryID]
	end

	def categoryID=(categoryID)
		@data[:categoryID]=categoryID
		@ctrl['category'].text=DB1.getInstance().getCategoryPath(categoryID)
	end

end

end