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
require 'Sterling/DB1';
require 'Sterling/Hash-Ext';

module Sterling

class FinanceTree < Gtk::TreeView

  attr_reader :totalIncome, :totalExpense;

  def initialize()
    @totalIncome=0;
    @totalExpense=0;
    @db=DB1.getInstance
    #~ treemodel=Gtk::TreeStore.new(Integer, String, Float, Float, Float, Float); #category_id,category_name,income,expense,child_income,child_expense
    treemodel=Gtk::TreeStore.new(Integer, String, Float, Float); #category_id,category_name,income,expense
    super(treemodel);
    @cattab={};	#map{category_id=>TreeIter}
    renderer=Gtk::CellRendererText.new;
    col=Gtk::TreeViewColumn.new('Category:', renderer, :text=>1);
    self.append_column(col);
    col=Gtk::TreeViewColumn.new('Income:', renderer, :text=>2);
    col.set_cell_data_func(renderer) { |col, renderer, model, iter|
      renderer.text= iter[2].zero? ? '' : sprintf('%.2f', iter[2]);
    }
    self.append_column(col);
    col=Gtk::TreeViewColumn.new('Expense:', renderer, :text=>3);
    col.set_cell_data_func(renderer) { |col, renderer, model, iter|
      renderer.text= iter[3].zero? ? '' : sprintf('%.2f', iter[3]);
    }
    self.append_column(col);
  end

  def reloadCategories
    buf=[];
    self.clear;
    @cattab={};
    callback=lambda{ |r|
      if r['parentID']==0 or @cattab.has_key?(r['parentID'].to_i)
	row=model.append(@cattab[r['parentID'].to_i]);
	@cattab[r['ID']]=row;
	row[0]=r['ID'];
	row[1]=r['name'];
	row[2]=0.0;
	row[3]=0.0;
	#~ row[4]=0.0;
	#~ row[5]=0.0;
      else
	buf.push(r);
      end
    }
    @db.iterateCategories(&callback);
    while(buf.count>0)
      callback.call(buf.pop);
    end
    @cattab[0]=[];	#hidden category
  end

  def reloadData
    #clear all data:
    @totalIncome=0;
    @totalExpense=0;
    @cattab.values.each{|iter|
      iter[2]=0.0;
      iter[3]=0.0;
      #~ iter[4]=0.0;
      #~ iter[5]=0.0;
    }
    #load data from db
    @db.iterateTransactionsShort{ |r|
      iter=@cattab[r['categoryID'].to_i];
      value=r['value']*r['count'];
      if value>0.0
	iter[2]+=value;
	@totalIncome+=value;
      else
	iter[3]-=value;
	@totalExpense-=value;
      end
    }
    #~ (@totalIncome, @totalExpense)=self.sumTotalValue;
    self.sumTotalValue;
  end

  def reload
    self.reloadCategories;
    self.reloadData;
  end

  #~ def replaceItem(data)
    #~ if @cattab.has_key?(data['ID'])
      #~ row=@cattab[data['ID']];
    #~ else
      #~ row=model.append(@cattab[data['parentID'].to_i]);
      #~ @cattab[data['ID']]=row;
    #~ end
    #~ row[0]=data['ID'];
    #~ row[1]=data['name'];
  #~ end

  #~ def selectCategory(categoryID)
    #~ iter=@cattab[categoryID.to_i];
    #~ if !iter.nil?
      #~ expand_to_path(iter.path);
      #~ selection.select_iter(iter);
    #~ end
  #~ end

  def getSelectedCategoryID()
    iter=selection.selected;
    #~ @cattab.find_key(iter);
    return iter.nil? ? nil : iter[0];
  end

  def isCategoryID?(categoryID)
    !@cattab[categoryID.to_i].nil?;
  end

  def clear
    model.clear;
    @cattab={}
  end

  def getTotalValue(iter)
    income=iter[2];
    expense=iter[3];
    if iter.has_child?
      ch=iter.first_child;
      while true
	(i, e)=getTotalValue(ch);
	income+=i;
	expense+=e;
	if not ch.next! then break end;
      end
    end
    iter[2]=income;
    iter[3]=expense;
    return [income, expense];
  end

  def sumTotalValue
    income=0.0;
    expense=0.0;
    iter=self.model.iter_first;
    while not iter.nil?
      (i, e)=self.getTotalValue(iter);
      income+=i;
      expense+=e;
      if not iter.next! then break end;
    end
    return [income, expense];
  end

end

end
