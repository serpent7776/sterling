# vim: set sw=4 ts=4:
#
# Copyright © 2012,2013,2014,2015 Serpent7776. All Rights Reserved.
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
require 'sterling_coin/TreeView';
require 'sterling_coin/Hash-Ext';

module SterlingCoin

class CategoriesTree < TreeView

  def initialize(title)
    treemodel=Gtk::TreeStore.new(Integer, String);
    super(treemodel);
    renderer=Gtk::CellRendererText.new;
    col=Gtk::TreeViewColumn.new(title, renderer, :text=>1);
    append_column(col);
    @cattab={};	#table of categories {id=>TreeIter}
  end

  def replaceCategory(data)
    if @cattab.has_key?(data['ID'])
      row=@cattab[data['ID']];
    else
      row=model.append(@cattab[data['parentID'].to_i]);
      @cattab[data['ID']]=row;
    end
    row[0]=data['ID'];
    row[1]=data['name'];
  end

  def selectCategory(categoryID)
    iter=@cattab[categoryID.to_i];
    if !iter.nil?
      expand_to_path(iter.path);
      selection.select_iter(iter);
    end
  end

  def getSelectedCategoryID()
    iter=selection.selected;
    @cattab.find_key(iter);
  end

  def isCategoryID?(categoryID)
    !@cattab[categoryID.to_i].nil?;
  end

  def clear
    model.clear;
    @cattab={}
  end

end

end
