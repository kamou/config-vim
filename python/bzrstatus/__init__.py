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


from bzrlib import commands, osutils, trace, ui
from bzrlib import api_minimum_version

import vim
import sys
import os


def getchar():
    sys.stdout.flush()
    return vim.eval('nr2char(getchar())')

if '1' == vim.eval("has('gui_running')"):
    os.environ['BZR_EDITOR'] = 'gvim -f'

print 'bzrstatus/__init__.py'

if api_minimum_version >= (2, 2, 0):

    from bzrlib import library_state

    class FakeUI:
        def __enter__(self):
            return self

    tracer = trace.DefaultConfig()
    state = library_state.BzrLibraryState(ui=FakeUI(), trace=tracer)
    state.__enter__()

    commands._register_builtin_commands()

else:

    commands.install_bzr_command_hooks()

osutils.getchar = getchar


