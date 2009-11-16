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


from bzrlib import commands, osutils, plugin, trace

import vim
import sys
import os


def getchar():
    sys.stdout.flush()
    return vim.eval('nr2char(getchar())')

def raw_input(prompt=''):
    sys.stdout.flush()
    return vim.eval('input(\'' + prompt + '\')')

if '1' == vim.eval("has('gui_running')"):
    os.environ['BZR_EDITOR'] = 'gvim -f'

osutils.getchar = getchar
trace.enable_default_logging()
commands.install_bzr_command_hooks()
plugin.load_plugins()


