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


from StringIO import StringIO

import sys


vim_stdout = sys.stdout
vim_stderr = sys.stderr


class Output(StringIO):

    def flush(self):
        vim_stdout.write('\n')
        return StringIO.flush(self)

    def write(self, str):
        vim_stdout.write(str)
        return StringIO.write(self, str)


