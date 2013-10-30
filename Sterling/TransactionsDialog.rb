# vim: set sw=4 ts=4:
#
# Copyright © 2012,2013 Serpent7776. All Rights Reserved.
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
require 'date';
require 'Sterling/DialogWindow';
require 'Sterling/TransactionEditor';
require 'Sterling/TransactionsFilter';
require 'Sterling/TransactionsFilterDialog';
require 'Sterling/DB1';

module Sterling

class TransactionsDialog < DialogWindow
	#category_id - category for which show transactions or nil to show all
	def initialize(parent, category_id =nil)
		@db=DB1.getInstance;
		# @categoryID=category_id;
		@filter=nil
		if not category_id.nil?
			@filter=TransactionsFilter.new
			@filter.category=category_id
		end
		super('Transactions', parent);
		#init ui
		model=Gtk::ListStore.new(Integer, Date, Integer, Float, String, String);
		@transactions=Gtk::TreeView.new(model);
		renderer=Gtk::CellRendererText.new();
		col=Gtk::TreeViewColumn.new('Date', renderer);
		col.set_cell_data_func(renderer){|col,renderer,model,iter|
			renderer.text=iter[1].strftime('%d.%m.%Y');
		}
		@transactions.append_column(col);
		col=Gtk::TreeViewColumn.new('Count', renderer, :text=>2);
		col.set_cell_data_func(renderer){|col,renderer,model,iter|
			renderer.text=sprintf('%.2f', iter[2]);
		}
		@transactions.append_column(col);
		col=Gtk::TreeViewColumn.new('Value', renderer, :text=>3);
		col.set_cell_data_func(renderer){|col,renderer,model,iter|
			renderer.text=sprintf('%.2f', iter[3]);
		}
		@transactions.append_column(col);
		col=Gtk::TreeViewColumn.new('Category', renderer, :text=>4);
		@transactions.append_column(col);
		col=Gtk::TreeViewColumn.new('Description', renderer, :text=>5);
		@transactions.append_column(col);
		self.add_button('D_one', Gtk::Dialog::ResponseType::OK);
		hbox=Gtk::HBox.new;
		self.vbox.add(hbox);
		scroller=Gtk::ScrolledWindow.new;
		scroller.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC).set_size_request(550, 250);
		scroller.add(@transactions);
		hbox.add(scroller);
		#summary box:
		@summarybox=Gtk::HBox.new;
		@summary_ctrl={}	#controls in summary box
		@summary_ctrl['items_count']=Gtk::Label.new
		@summary_ctrl['total_value']=Gtk::Label.new
		@summarybox.add(@summary_ctrl['items_count'])
		@summarybox.add(@summary_ctrl['total_value'])
		self.vbox.pack_end(@summarybox, false, false, 0);
		#buttons:
		btnbox=Gtk::VButtonBox.new;
		btnbox.spacing=10;
		btnbox.set_layout_style(Gtk::ButtonBox::Style::START);
		hbox.pack_start(btnbox, false, false, 2);
		btnTrNew=Gtk::Button.new('_New');
		btnTrEdit=Gtk::Button.new('_Edit');
		btnTrRemove=Gtk::Button.new('_Remove');
		btnTrFilter=Gtk::Button.new('_Filter');
		btnbox.add(btnTrNew);
		btnbox.add(btnTrEdit);
		btnbox.add(btnTrRemove);
		btnbox.add(btnTrFilter);
		#button events
		btnTrNew.signal_connect(:clicked){
			dialog=TransactionEditor.new(self);
			response_id=dialog.run;
			transactionData=dialog.getTransactionData;
			dialog.close;
			if response_id==Gtk::Dialog::ResponseType::OK
				@db.insertTransaction(transactionData);
				self.reloadData;
			end
		}
		btnTrEdit.signal_connect(:clicked){
			iter=@transactions.selection.selected;
			if not iter.nil?
				dialog=TransactionEditor.new(self);
				transactionData=@db.getTransaction(iter[0]);
				dialog.setTransactionData(iter[0], transactionData);
				response_id=dialog.run;
				transactionData=dialog.getTransactionData;
				dialog.close;
					if response_id==Gtk::Dialog::ResponseType::OK
						@db.updateTransaction(iter[0], transactionData);
						self.reloadData;
					end
			end
		}
		btnTrRemove.signal_connect(:clicked){
			sel=@transactions.selection;
			iter=sel.selected;
			if not iter.nil?
				categoryData=@db.getTransaction(iter[0]);
				prompt=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
					Gtk::MessageDialog::Type::QUESTION, Gtk::MessageDialog::ButtonsType::YES_NO,
					"Do you really want to remove selected transaction:\n#{iter[1]}:\n#{iter[5]}");
				response_id=prompt.run;
				prompt.close;
				if response_id==Gtk::Dialog::ResponseType::YES
					@db.removeTransaction(iter[0]);
					self.reloadData;
				end
			end
		}
		btnTrFilter.signal_connect(:clicked){
				dialog=TransactionsFilterDialog.new(self, @filter);
				response=dialog.run
				if response==Gtk::Dialog::ResponseType::OK
					@filter=dialog.filter
					self.reloadData
				end
				dialog.close
		}
		#
		self.reloadData;
		show_all;
	end

	#remove all transactions and reload data
   	def reloadData
		@transactions.model.clear;
		@totalItems=0;
		@totalValue=0;
		if not @filter.nil?
			@filter.fieldNames({'description' => 'descr'})
		end
		@db.iterateTransactions{|tr|
			# if @categoryID.nil? or @categoryID==tr['categoryID']
				if (not @filter.nil?) and (not @filter.filter(tr))
					next
				end
				iter=@transactions.model.append;
				iter[0]=tr['ID'].to_i;
				iter[1]= tr['date'].to_s.empty? ? Date.jd() : Date::parse(tr['date']);
				iter[2]=tr['count'].to_f;
				iter[3]=tr['value'].to_f;
				iter[4]=@db.getCategoryPath(tr['categoryID']); #get category path
				iter[5]=tr['descr'];
				@totalItems+=1
				@totalValue+=iter[2]*iter[3]
			# end
		}
		self.updateSummary
	end

	#update summary data
	def updateSummary
		@summary_ctrl['items_count'].text=@totalItems.to_s+' items';
		@summary_ctrl['total_value'].text=sprintf('Total value: %.2f', @totalValue.to_f)
	end

end

end
