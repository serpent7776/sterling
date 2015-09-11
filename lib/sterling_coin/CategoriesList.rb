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
require 'sterling_coin/DB1';
require 'sterling_coin/CategoryEditor';
require 'sterling_coin/CategoriesTree';
require 'sterling_coin/ScrollingDecorator';
require 'sterling_coin/CategoriesTreeFiller';
require 'sterling_coin/DialogWindow';

module SterlingCoin

class CategoriesList < DialogWindow

       	def initialize(parent)
		super('List of categories', parent);

		@db=DB1.getInstance;
		@categoriesTree=ScrollingDecorator.new(CategoriesTree.new('Category:'), 150, 200)
	
		hbox=Gtk::HBox.new;
		self.vbox.add(hbox);
		hbox.add(@categoriesTree);
		btnbox=Gtk::VButtonBox.new;
		btnbox.spacing=10;
		btnbox.set_layout_style(Gtk::ButtonBox::Style::START);
		hbox.pack_start(btnbox, false, false, 0);
		add_button('Done', Gtk::Dialog::ResponseType::OK);
		#buttons:
		btnCatNew=Gtk::Button.new('_New');
		btnCatEdit=Gtk::Button.new('_Edit');
		btnCatRemove=Gtk::Button.new('_Remove');
		treeview=@categoriesTree;
		proc_category_new=Proc.new{
			cedit=CategoryEditor.new(self);
			response_id=cedit.run;
			categoryData=cedit.categoryData;
			cedit.close;
			if response_id==Gtk::Dialog::ResponseType::OK
				@db.insertCategory(categoryData);
				reloadCategories();
			end
		}
		proc_category_edit=Proc.new{
			sel=treeview.selection;
			iter=sel.selected;
			if !iter.nil?
				categoryData=@db.getCategory(iter[0]);
				cedit=CategoryEditor.new(self)
				cedit.setCategoryData(iter[0], categoryData);
				response_id=cedit.run;
				categoryData=cedit.categoryData;
				categoryID=cedit.categoryID;
				cedit.close;
				if response_id==Gtk::Dialog::ResponseType::OK
					@db.updateCategory(categoryID, categoryData);
					reloadCategories();
				end
			end
		}
		proc_category_delete=Proc.new{
			sel=treeview.selection;
			iter=sel.selected;
			if !iter.nil?
				categoryData=@db.getCategory(iter[0]);
				prompt=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
					Gtk::MessageDialog::Type::QUESTION, Gtk::MessageDialog::ButtonsType::YES_NO, "Do you really want to remove selected category:\n#{iter[1]}");
				response_id=prompt.run;
				prompt.close;
				if response_id==Gtk::Dialog::ResponseType::YES
					@db.removeCategory(iter[0]);
					reloadCategories();
				end
			end
		}
		btnbox.add(btnCatNew);
		btnbox.add(btnCatEdit);
		btnbox.add(btnCatRemove);
		#
		btnCatNew.signal_connect(:clicked, &proc_category_new)
		btnCatEdit.signal_connect(:clicked, &proc_category_edit)
		btnCatRemove.signal_connect(:clicked, &proc_category_delete)
		#
		reloadCategories();
		#
		show_all;
	end

	def reloadCategories()
		@categoriesTree.clear;
		CategoriesTreeFiller.fill(@categoriesTree);
	end

end

end
