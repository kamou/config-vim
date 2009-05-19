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


from bzrstatus.complete import Complete
from bzrstatus.output import Output
from bzrstatus.ui import UI

from StringIO import StringIO

import bzrlib
import shlex
import vim
import sys


vim_stdout = sys.stdout
vim_stderr = sys.stderr


bzr_instances = {}


class Bzr:

    def __init__(self, path):
        self.path = path
        self.tab = vim.eval('tabpagenr()')
        bzr_instances[self.tab] = self

    def complete(self, arglead, cmdline, workdir):

        try:
            matches = Complete(arglead, cmdline, workdir).complete()
        except ValueError:
            matches = []
            e = sys.exc_info()[1]
            print >>sys.stderr, 'parse error:', e.message

        vim.command("let matches = ['" + "', '".join(matches) + "']")

    def run(self, cmdline, to_buffer=True, to_terminal=False):

        argv = ['bzr']
        argv.extend(shlex.split(cmdline))

        if to_terminal:
            output = Output()
        else:
            output = StringIO()

        try:

            sys.stdout = output
            sys.stderr = output

            bzrlib.trace.enable_default_logging()
            bzrlib.ui.ui_factory = UI(output)

            # Is this a final release version? If so, we should suppress warnings
            if bzrlib.version_info[3] == 'final':
                from bzrlib import symbol_versioning
                symbol_versioning.suppress_deprecation_warnings(override=False)

            new_argv = []
            try:
                # ensure all arguments are unicode strings
                for a in argv[1:]:
                    if isinstance(a, unicode):
                        new_argv.append(a)
                    else:
                        new_argv.append(a.decode('ascii'))
            except UnicodeDecodeError:
                raise errors.BzrError("argv should be list of unicode strings.")
            argv = new_argv

            try:
                ret = bzrlib.commands.run_bzr_catch_errors(argv)
                output = output.getvalue()
            except:
                output = '\n'.join(traceback.format_exc().splitlines())

            bzrlib.ui.ui_factory._progress_all_finished()

            if not to_buffer:
                return output

            lines = output.splitlines()
            l = len(lines)
            if 0 == l:
                return

            b = vim.current.buffer
            w = vim.current.window

            row, col = w.cursor

            b[row:row] = lines
            w.cursor = (row + l, col)

        finally:

            sys.stdout = vim_stdout
            sys.stderr = vim_stderr


def bzr():
    return bzr_instances[vim.eval('tabpagenr()')]


