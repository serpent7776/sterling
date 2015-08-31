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
require 'fileutils';
require 'xdg';
require 'Sterling/DB1';
require 'Sterling/CategoriesList';
require 'Sterling/TransactionsDialog';
require 'Sterling/ScrollingDecorator';
require 'Sterling/FinanceTree';
require 'Sterling/Version';

module Sterling

#main class creating main window
class Sterling < Gtk::Window
  def initialize()
    super;
    #@version=0.10;
    vbox=Gtk::VBox.new;
    #menu:
    @menu=Gtk::MenuBar.new;
    ##menu 'File'
    menuitem_file=Gtk::MenuItem.new('_File');
    @menu.append(menuitem_file);
    menu_file=Gtk::Menu.new;
    menuitem_file.set_submenu(menu_file);
    menuitem_quit=Gtk::MenuItem.new('_Quit');
    menu_file.append(menuitem_quit);
    menuitem_quit.signal_connect(:activate) {
      Gtk::main_quit;
    }
    ##menu 'Categories'
    menuitem_categories=Gtk::MenuItem.new('_Categories');
    @menu.append(menuitem_categories);
    menu_categories=Gtk::Menu.new;
    menuitem_categories.set_submenu(menu_categories);
    menuitem_categories_list=Gtk::MenuItem.new('_List');
    menu_categories.append(menuitem_categories_list);
    menuitem_categories_list.signal_connect(:activate) {
      dialog=CategoriesList.new(self);
      dialog.run;
      dialog.close;
      self.reload;
    }
    ##menu 'Transactions'
    menuitem_transactions=Gtk::MenuItem.new('_Transactions');
    @menu.append(menuitem_transactions);
    menu_transactions=Gtk::Menu.new;
    menuitem_transactions.set_submenu(menu_transactions);
    menuitem_transactions_show_all=Gtk::MenuItem.new('Show _all');
    menuitem_transactions_show_selected_category=Gtk::MenuItem.new('Show from _selected category');
    menu_transactions.append(menuitem_transactions_show_all);
    menu_transactions.append(menuitem_transactions_show_selected_category);
    menuitem_transactions_show_all.signal_connect(:activate) {
      dialog=TransactionsDialog.new(self);
      dialog.run;
      dialog.close;
      self.reloadData;
    }
    menuitem_transactions_show_selected_category.signal_connect(:activate) {
      #~ iter=@treeview.selection.selected;
      categoryID=@finances.getSelectedCategoryID;
      if not categoryID.nil?
	dialog=TransactionsDialog.new(self, categoryID);
	dialog.run;
	dialog.close;
	self.reloadData;
      end
    }
    ##menu 'About'
    menuitem_about=Gtk::MenuItem.new('_About');
    @menu.append(menuitem_about);
    menu_about=Gtk::Menu.new;
    menuitem_about.set_submenu(menu_about);
    menuitem_about_sterling=Gtk::MenuItem.new('About _Sterling');
    menu_about.append(menuitem_about_sterling);
    menuitem_about_sterling.signal_connect(:activate){
      text=sprintf("Sterling v%s\npersonal finance manager\n\nby Serpent7776", Version.version);
      dialog=Gtk::MessageDialog.new(self, Gtk::Dialog::MODAL,
	  Gtk::MessageDialog::Type::INFO, Gtk::MessageDialog::ButtonsType::OK, text);
      dialog.run;
      dialog.close;
    }
    #open database
    basedir="#{ENV['HOME']}/.sterling"
    FileUtils.mkdir_p(basedir)
    @db=DB1.getInstance("#{basedir}/default.db");
    if @db.getCategoriesCount==0
      @db.createDefaultCategories;
    end
    #treeview:
    @finances=ScrollingDecorator.new(FinanceTree.new, 500, 225)
    #statusbar:
    @statusbar=Gtk::Statusbar.new;
    @status={}
    @status['income']=Gtk::Label.new
    @status['expense']=Gtk::Label.new
    @status['total']=Gtk::Label.new
    @statusbar.add(@status['total']).add(@status['income']).add(@status['expense'])
    #
    add(vbox);
    vbox.pack_start(@menu, false, false, 0);
    vbox.add(@finances);
    vbox.pack_start(@statusbar, false, false, 0);
    #
    self.signal_connect(:destroy) {
      Gtk::main_quit;
    }
    #
    self.reload;
    gem_dir = Gem::Specification.find_by_name('sterling_coin').gem_dir
    self.set_icon(gem_dir+'/lib/assets/sterling.png');
  end

#do full reload
  def reload
    self.reloadCategories;
    self.reloadData;
  end

  # reloads categories from database and insert them into treeview
  def reloadCategories()
    @finances.reloadCategories;
  end

  #reload income and expenses and insert them into categories in treeview
  def reloadData()
    @finances.reloadData;
    updateStatusBar();
  end

  #updates text in statusbar
  def updateStatusBar()
    # text=sprintf("Total: %.2f \tincomes: %.2f \texpenses: %.2f", @finances.totalIncome-@finances.totalExpense, @finances.totalIncome, @finances.totalExpense);
    @status['income'].text=sprintf('incomes: %.2f', @finances.totalIncome)
    @status['expense'].text=sprintf('expenses: %.2f', @finances.totalExpense)
    @status['total'].text=sprintf('total: %.2f', @finances.totalIncome-@finances.totalExpense)
    # context=@statusbar.get_context_id('total');
    # @statusbar.pop(context);
    # @statusbar.push(context, text);
  end
end

end
