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
require 'Sterling/DialogWindow';
require 'Sterling/CategoriesTree';
require 'Sterling/CategoriesTreeFiller';
require 'Sterling/ScrollingDecorator';
#require 'Sterling/DB1';

module Sterling

class CategorySelector < DialogWindow

  def initialize(parent)
    #db=DB1.getInstance
    super('Select category', parent);
    @categories=ScrollingDecorator.new(CategoriesTree.new('Category'), 150, 150)
    self.vbox.add(@categories);
    add_button('OK', Gtk::Dialog::ResponseType::OK);
    add_button('Cancel', Gtk::Dialog::ResponseType::CANCEL);
    CategoriesTreeFiller.fill(@categories);
    show_all;
  end

  def setData(categoryID)
    @categoryID=categoryID;
  end

  def getData
    return @categories.getSelectedCategoryID;
  end

  def run
    @categories.selectCategory(@categoryID);
    super;
  end

end

end
