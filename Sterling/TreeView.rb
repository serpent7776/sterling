# vim: set sw=4 ts=4:
#
# Copyright © 2014 Serpent7776. All Rights Reserved.
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

module Sterling

class TreeView < Gtk::TreeView

	def initialize(treemodel)
		super(treemodel);
		key_press_proc = Proc.new { |widget,event|
			if event.keyval == Gdk::Keyval::GDK_Right then
				sel = selection.selected
				expand_row(sel.path, false)
			elsif event.keyval == Gdk::Keyval::GDK_Left then
				sel = selection.selected
				b = collapse_row(sel.path)
				if not b then
					if not sel.parent.nil? then
						selection.select_path(sel.parent.path)
						set_cursor(sel.parent.path, nil, false)
					end
				end
				b
			end
		}
		signal_connect(:'key-press-event', &key_press_proc);
	end

end

end
