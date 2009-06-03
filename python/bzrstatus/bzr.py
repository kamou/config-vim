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

from bzrlib.errors import (BzrError, NoWorkingTree,
                           NotBranchError, NotLocalUrl)
from bzrlib.bzrdir import BzrDir
import bzrlib

import traceback
import shlex
import vim
import sys
import os


vim_stdout = sys.stdout
vim_stderr = sys.stderr


bzr_instances = {}


class Bzr:

    def __init__(self, path):

        if '/' == path[-1]:
            self.path = path[0:-1]
        else:
            self.path = path

        self.root = self.path

        self.tree = None
        self.branch = None

        try:
            bzrdir = BzrDir.open_containing(self.path)[0]
            try:
                self.tree = bzrdir.open_workingtree(recommend_upgrade=False)
                self.branch = self.tree.branch
            except (NoWorkingTree, NotLocalUrl):
                try:
                    self.branch = bzrdir.open_branch()
                except NotBranchError:
                    pass
        except NotBranchError:
            pass

        if self.tree is not None:
            self.root = self.tree.basedir

        self.tab = vim.eval('tabpagenr()')
        bzr_instances[self.tab] = self

    def complete(self, arglead, cmdline):

        try:
            matches = Complete(arglead, cmdline, self.root).complete()
        except ValueError:
            matches = []
            e = sys.exc_info()[1]
            print >> sys.stderr, 'parse error:', e.message

        vim.command("let matches = ['" + "', '".join(matches) + "']")

    def run(self, cmd, to_buffer=True, progress_updates=False):

        if type(cmd) is str:
            argv = shlex.split(cmd)
        else:
            argv = cmd

        if to_buffer:
            output = Output(progress_updates,
                            vim.current.buffer,
                            vim.current.window)
        else:
            output = StringIO()

        olddir = os.getcwd()
        os.chdir(self.root)

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
                for a in argv:
                    if isinstance(a, unicode):
                        new_argv.append(a)
                    else:
                        new_argv.append(a.decode('ascii'))
            except UnicodeDecodeError:
                raise BzrError("argv should be list of unicode strings.")
            argv = new_argv

            try:
                ret = bzrlib.commands.run_bzr_catch_errors(argv)
            except:
                output = StringIO(traceback.format_exc())
                ret = -1

            bzrlib.ui.ui_factory.finish()

            if not to_buffer:
                return output.getvalue()

            output.flush(redraw=False, final=True)

            return ret

        finally:

            for handler in bzrlib.trace._bzr_logger.handlers:
                handler.close()
            if bzrlib.trace._trace_file is not None:
                bzrlib.trace._trace_file.close()
                bzrlib.trace._trace_file = None

            os.chdir(olddir)

            sys.stdout = vim_stdout
            sys.stderr = vim_stderr

    def update_file(self):
        filename = ''
        if self.branch is not None:
            filename += '[' + self.branch.nick + '] '
        filename += self.root
        vim.command("exe 'silent file '.fnameescape('" + filename + "')")


def bzr():
    return bzr_instances[vim.eval('tabpagenr()')]


