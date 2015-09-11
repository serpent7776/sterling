# vim: set sw=4 ts=4:
#
# Copyright © 2013,2014,2015 Serpent7776. All Rights Reserved.
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
require 'sterling_coin/CategoryEntry';
require 'sterling_coin/TransactionsFilter';

module SterlingCoin

class TransactionsFilterDialog < DialogWindow

	def initialize(parent, filter)
		super('Filter', parent)
		@ctrl={}
		@ctrl['date_min']=DateEntry.new
		@ctrl['date_max']=DateEntry.new
		@ctrl['count_min']=Gtk::SpinButton.new;
		@ctrl['count_min'].set_increments(1, 10).set_digits(2).set_range(Float::MIN, Float::MAX).text=('')
		@ctrl['count_max']=Gtk::SpinButton.new;
		@ctrl['count_max'].set_increments(1, 10).set_digits(2).set_range(Float::MIN, Float::MAX).text=('')
		@ctrl['value_min']=Gtk::SpinButton.new;
		@ctrl['value_min'].set_increments(0.1, 2.5).set_digits(2).set_range(-Float::MAX, Float::MAX).text=('')
		@ctrl['value_max']=Gtk::SpinButton.new;
		@ctrl['value_max'].set_increments(0.1, 2.5).set_digits(2).set_range(-Float::MAX, Float::MAX).text=('')
		@ctrl['category']=CategoryEntry.new;
		@ctrl['description']=Gtk::Entry.new;
		#
		proc_changed=Proc.new{|ctrl,v|
			if ctrl.text.empty?
				ctrl.text=''
			end
		}
		@ctrl['count_min'].signal_connect(:'output', &proc_changed)
		@ctrl['count_max'].signal_connect(:'output', &proc_changed)
		@ctrl['value_min'].signal_connect(:'output', &proc_changed)
		@ctrl['value_max'].signal_connect(:'output', &proc_changed)
		#
		if not filter.nil?
			@ctrl['date_min'].text= filter.date_min.nil? ? '' : filter.date_min.strftime('%d.%m.%Y')
			@ctrl['date_max'].text= filter.date_max.nil? ? '' : filter.date_max.strftime('%d.%m.%Y')
			@ctrl['count_min'].text= filter.count_min.nil? ? '' : filter.count_min.to_s
			@ctrl['count_max'].text= filter.count_max.nil? ? '' : filter.count_max.to_s
			@ctrl['value_min'].text= filter.value_min.nil? ? '' : filter.value_min.to_s
			@ctrl['value_max'].text= filter.value_max.nil? ? '' : filter.value_max.to_s
			@ctrl['category'].categoryID= filter.categoryID.nil? ? 0 : filter.categoryID
			@ctrl['description'].text= filter.description.nil? ? '' : filter.description
		end
		#
		table=Gtk::Table.new(5, 3);
		table.attach(Gtk::Label.new('Date'), 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['date_min'], 1, 2, 0, 1, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['date_max'], 2, 3, 0, 1, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Count'), 0, 1, 1, 2, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['count_min'], 1, 2, 1, 2, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['count_max'], 2, 3, 1, 2, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Value'), 0, 1, 2, 3, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['value_min'], 1, 2, 2, 3, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['value_max'], 2, 3, 2, 3, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Category'), 0, 1, 3, 4, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['category'], 1, 3, 3, 4, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(Gtk::Label.new('Description'), 0, 1, 4, 5, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 2, 2);
		table.attach(@ctrl['description'], 1, 3, 4, 5, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::FILL | Gtk::AttachOptions::EXPAND, 2, 2);
		#
		self.vbox.add(table);
		self.add_button('_OK', Gtk::Dialog::ResponseType::OK);
		self.add_button('_Cancel', Gtk::Dialog::ResponseType::CANCEL);
		#
		btnClear=Gtk::Button.new('Clea_r')
		btnClear.signal_connect(:clicked){
			self.clearFilter
		}
		self.action_area.add(btnClear)
		show_all
	end

	#clear all controls and filter
	def clearFilter
		@ctrl['date_min'].text=''
		@ctrl['date_max'].text=''
		@ctrl['count_min'].text=''
		@ctrl['count_max'].text=''
		@ctrl['value_min'].text=''
		@ctrl['value_max'].text=''
		@ctrl['category'].categoryID=0
		@ctrl['description'].text=''
		@filter=nil
	end

	#return TransactionsFilter
	def filter
		filter=TransactionsFilter.new
		date_min=@ctrl['date_min'].text
		date_max=@ctrl['date_max'].text
		filter.date=
			if date_min.empty? and date_max.empty? then nil
			else [date_min, date_max]
			end
		filter.count=[@ctrl['count_min'].text, @ctrl['count_max'].text]
		filter.value=[@ctrl['value_min'].text, @ctrl['value_max'].text]
		filter.category=@ctrl['category'].categoryID
		filter.description=@ctrl['description'].text
		return filter
	end

end

end
