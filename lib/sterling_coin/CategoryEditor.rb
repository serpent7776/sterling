# vim: set sw=4 ts=4:
#
# Copyright © 2012,2013,2015 Serpent7776. All Rights Reserved.
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
require 'sterling_coin/DialogWindow';
require 'sterling_coin/DB1';
require 'sterling_coin/CategoriesTree';
require 'sterling_coin/CategoriesTreeFiller';
require 'sterling_coin/CategoryValidator';
require 'sterling_coin/ScrollingDecorator';

module SterlingCoin

class CategoryEditor < DialogWindow

  attr_reader :categoryID, :categoryData;

	def initialize(parent)
		super('Edit category', parent);
		@categoryID=0;
		@categoryData={};
		btn_ok=add_button('O_K', Gtk::Dialog::ResponseType::OK);
		add_button('_Cancel', Gtk::Dialog::ResponseType::CANCEL);
		table=Gtk::Table.new(2, 2);
		self.vbox.add(table);
		#
		@entry={};
		@entry['name']=Gtk::Entry.new;
		@entry['parent']=ScrollingDecorator.new(CategoriesTree.new(''), 175, 250)
		@entry['parent'].headers_visible=false;
		@entry['parent'].replaceCategory({'ID'=>0, 'parentID'=>0, 'name'=>'(root)'});
		CategoriesTreeFiller.fill(@entry['parent']);
		table.attach(Gtk::Label.new('Name'), 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 5);
		table.attach(@entry['name'], 1, 2, 0, 1, Gtk::AttachOptions::EXPAND | Gtk::AttachOptions::FILL, Gtk::AttachOptions::SHRINK, 2, 5);
		table.attach(Gtk::Label.new("Parent\nCategory"), 0, 1, 1, 2, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 5);
		table.attach(@entry['parent'], 1, 2, 1, 2, Gtk::AttachOptions::EXPAND | Gtk::AttachOptions::FILL, Gtk::AttachOptions::EXPAND | Gtk::AttachOptions::FILL, 2, 5);
		#
		proc_validate=Proc.new do |widget,event|
			@categoryData['name']=@entry['name'].text;
			@categoryData['parentID']=@entry['parent'].getSelectedCategoryID;
			r=CategoryValidator.validate(@categoryData)
			if r[:code]>0
				dialog=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
					Gtk::MessageDialog::Type::ERROR, Gtk::MessageDialog::ButtonsType::OK, r[:msg]);
				dialog.run
				dialog.close
				true
			elsif @categoryData['parentID']==@categoryID
				dialog=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
					Gtk::MessageDialog::Type::ERROR, Gtk::MessageDialog::ButtonsType::OK, "Cannot be parent of self");
				dialog.run
				dialog.close
			end
			false
		end
		btn_ok.signal_connect(:'button-press-event', &proc_validate)
		btn_ok.signal_connect(:'mnemonic-activate', &proc_validate)
		show_all;
	end

	def setCategoryData(categoryID, categoryData)
		@categoryID=categoryID;
		@categoryData=categoryData;
	end

	def run
		if not @categoryData['name'].nil?
			@entry['name'].set_text(@categoryData['name']);
		end
		if not @categoryData['parentID'].nil?
			@entry['parent'].selectCategory(@categoryData['parentID']);
		end
		super;
	end

end

end
