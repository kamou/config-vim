#
# Copyright (C) 2009 Benoit Pierre <benoit.pierre@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


from bzrlib import user_encoding

from StringIO import StringIO

import time
import sys
import vim


vim_stdout = sys.stdout
vim_stderr = sys.stderr


class Output(StringIO):

    def __init__(self, progress_updates, buffer, window=None):
        StringIO.__init__(self)
        self.progress_updates = progress_updates
        self.buffer = buffer
        self.read_pos = 0
        self.window = window
        if self.progress_updates:
            self.update_time = time.time()
        if self.window is not None:
            self.row = self.window.cursor[0]

    def flush(self, redraw=True, final=False):
        ret = StringIO.flush(self)
        if not self.progress_updates and not final:
            return ret
        write_pos, self.pos = self.pos, self.read_pos
        if final:
            lines = self.readlines()
        else:
            lines = []
            while self.pos < write_pos:
                line = self.readline()
                if not final and '\n' != line[-1]:
                    self.pos -= len(line)
                    break
                lines.append(line)
        if 0 != len(lines):
            unicode_lines = []
            for line in lines:
                if type(line) is unicode:
                    unicode_lines.append(line.encode(user_encoding))
                else:
                    unicode_lines.append(line)
            if self.window is None:
                self.buffer.append(unicode_lines)
            else:
                self.buffer[self.row:self.row] = unicode_lines
                self.row += len(unicode_lines)
                self.window.cursor = (self.row, 1)
                if redraw:
                    vim.command('redraw')
        self.read_pos, self.pos = self.pos, write_pos
        return ret

    def write(self, str):
        ret = StringIO.write(self, str)
        if self.progress_updates:
            now = time.time()
            if now >= self.update_time + 0.5:
                self.update_time = now
                self.flush()
        return ret


