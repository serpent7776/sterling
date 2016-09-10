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
require 'date';
require 'sterling_coin/DB1';
require 'sterling_coin/DialogWindow';
require 'sterling_coin/CategorySelector';
require 'sterling_coin/DateEntry';
require 'sterling_coin/TransactionValidator';
require 'sterling_coin/CategoryEntry';

module SterlingCoin

class TransactionEditor < DialogWindow

  #~ attr_reader :transactionID, :transactionData;

	def initialize(parent)
		super('Edit transaction details', parent);
		@db=DB1.getInstance
		table=Gtk::Table.new(5, 2);
		@ctrl={};
		@ctrl['date']=DateEntry.new
		#@ctrl['date_box']=Gtk::HBox.new
		#@ctrl['date']=Gtk::Entry.new.set_editable(false);
		#@ctrl['date_sel']=Gtk::Button.new('...')
		@ctrl['count']=Gtk::SpinButton.new;
		@ctrl['count'].set_increments(1, 10).set_digits(2).set_range(Float::MIN, Float::MAX.to_i);
		@ctrl['value']=Gtk::SpinButton.new;
		@ctrl['value'].set_increments(0.1, 2.5).set_digits(2).set_range(-Float::MAX, Float::MAX);
		@ctrl['category']=CategoryEntry.new
		#@ctrl['category_box']=Gtk::HBox.new;
		#@ctrl['category']=Gtk::Entry.new.set_editable(false);
		#@ctrl['category'].editable=false;
		#@ctrl['category_sel']=Gtk::Button.new('...');
		@ctrl['descr']=Gtk::TextView.new;
		descr_scroll=Gtk::ScrolledWindow.new;
		descr_scroll.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC).set_size_request(290, 70);
		descr_scroll.add(@ctrl['descr'])
		#@ctrl['category_box'].add(@ctrl['category']).pack_start(@ctrl['category_sel'], false, false);
		#proc_category_sel=Proc.new{
			#dialog=CategorySelector.new(parent);
			#dialog.setData(@transactionData['categoryID']);
			#response_id=dialog.run;
			#categoryID=dialog.getData;
			#dialog.close;
			#if (response_id==Gtk::Dialog::ResponseType::OK)
				#@transactionData['categoryID']=categoryID;
				#@ctrl['category'].text=@db.getCategoryPath(categoryID);
			#end
		#}
		#@ctrl['category_sel'].signal_connect(:clicked, &proc_category_sel)
		#@ctrl['category_sel'].signal_connect(:'mnemonic-activate', &proc_category_sel)
		table.attach(Gtk::Label.new('Date'), 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['date'], 1, 2, 0, 1, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Count'), 0, 1, 1, 2, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['count'], 1, 2, 1, 2, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Value'), 0, 1, 2, 3, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['value'], 1, 2, 2, 3, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Category'), 0, 1, 3, 4, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		#table.attach(@ctrl['category_box'], 1, 2, 3, 4, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['category'], 1, 2, 3, 4, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Description'), 0, 1, 4, 5, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		#table.attach(@ctrl['descr'], 1, 2, 4, 5, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(descr_scroll, 1, 2, 4, 5, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, 2, 2);
		#
		self.vbox.add(table);
		btn_ok=self.add_button('O_K', Gtk::Dialog::ResponseType::OK);
		self.add_button('_Cancel', Gtk::Dialog::ResponseType::CANCEL);
		@transactionID=0;
		@transactionData={
			'date'=>Date.today.strftime('%d.%m.%Y'),
			'count'=>1,
			'value'=>0,
			'categoryID'=>0,
			'descr'=>''
		};
		proc_validate=Proc.new do |widget,event|
			data={
				#'ID'=> @transactionID,
				'date'=> @ctrl['date'].text,
				'count'=> @ctrl['count'].text,
				'value'=> @ctrl['value'].text,
				#'categoryID'=> @transactionData['categoryID'],
				#'descr'=> @ctrl['descr'].buffer.text,
			}
			r=TransactionValidator.validate(data)
			if r[:code]>0
				dialog=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
					Gtk::MessageDialog::Type::ERROR, Gtk::MessageDialog::ButtonsType::OK, r[:msg]);
				dialog.run
				dialog.close
				true
			end
		end
		btn_ok.signal_connect(:'mnemonic-activate', &proc_validate)
		btn_ok.signal_connect(:'button-press-event', &proc_validate)
		show_all;
	  end

	def setTransactionData(id, data)
		@transactionID=id;
		@transactionData=data;
	end

  def getTransactionData
    data={};
    data['ID']=@transactionID;
    data['date']=@ctrl['date'].text;
    data['count']=@ctrl['count'].text.to_f;
    data['value']=@ctrl['value'].text.to_f;
    #data['categoryID']=@transactionData['categoryID'];
    data['categoryID']=@ctrl['category'].categoryID
    data['descr']=@ctrl['descr'].buffer.text;
    return data;
  end

  def run
    @ctrl['date'].text= @transactionData['date'].to_s.empty? ? Date::jd.strftime('%d.%m.%Y') : Date::parse(@transactionData['date']).strftime('%d.%m.%Y');
    @ctrl['count'].value=@transactionData['count'].to_f;
    @ctrl['value'].value=@transactionData['value'].to_f;
	@ctrl['category'].categoryID=@transactionData['categoryID'];
    #@ctrl['category'].text=@db.getCategoryPath(@transactionData['categoryID']);
    @ctrl['descr'].buffer.text= @transactionData['descr'].nil? ? '' : @transactionData['descr'];
    super;
  end

end

end
