#! /usr/bin/env python

import bzrlib.commands
import bzrlib.config
import bzrlib.errors
import bzrlib.osutils
import bzrlib.plugin
import bzrlib.trace
import bzrlib.ui
import traceback
import os.path
import codecs
import shlex
import glob
import sys
import vim
import os

from StringIO import StringIO

bzrlib.plugin.load_plugins()

class BzrComplete():

    def __init__(self, arglead, cmdline, workdir,
                 complete_command_aliases=False,
                 complete_hidden_commands=False):

        self.cmdline = cmdline
        self.workdir = workdir
        self.complete_command_aliases = complete_command_aliases
        self.complete_hidden_commands = complete_hidden_commands

        self.args = shlex.split(cmdline)

        if '' == arglead:
            self.argn = len(self.args)
        else:
            args = shlex.split(arglead)
            self.argn = len(self.args) - len(args)
            if ' ' != arglead[0]:
                arglead = args[0]
            else:
                arglead = ''

        self.arglead = arglead

    def complete(self):

        if 1 == self.argn:
            matches = self.complete_cmdname()
        else:
            matches = self.complete_command()

        matches.sort()

        return matches

    def filter(self, list):

        matches = []

        for item in list:
            if item.startswith(self.arglead):
                matches.append(item)

        return matches

    def add_extra_space(self, list):

        return [ item + ' ' for item in list ]

    def complete_cmdname(self):

        cmds = []

        for cmdname, cmdclass in bzrlib.commands.get_all_cmds():
            if not self.complete_hidden_commands and cmdclass.hidden:
                continue
            cmds.append(cmdname)
            if self.complete_command_aliases:
                for alias in cmdclass.aliases:
                    if cmdname.startswith(alias):
                        continue
                    cmds.append(alias)

        for alias in bzrlib.config.GlobalConfig().get_aliases().keys():
            cmds.append(alias)

        return self.add_extra_space(self.filter(cmds))

    def complete_options(self):

        if self.cmdobj is None:
            return []

        opts = []

        for name, opt in self.cmdobj.options().items():
            opts.append('--' + opt.name)
            short_name = opt.short_name()
            if short_name:
                opts.append('-' + short_name)

        return self.add_extra_space(self.filter(opts))

    def fix_path(self, path):

        if os.path.isdir(path):
            return path + '/'

        return path

    def complete_command(self):

        self.cmdname = self.args[1]

        alias_args = bzrlib.commands.get_alias(self.cmdname)
        if alias_args is not None:
            self.cmdname = alias_args.pop(0)

        try:
            self.cmdobj = bzrlib.commands.get_cmd_object(self.cmdname)
        except bzrlib.errors.BzrCommandError:
            self.cmdobj = None

        if 0 < len(self.arglead):

            if '-' == self.arglead[0]:
                return self.complete_options()

            if '~' == self.arglead[0]:
                self.arglead = os.path.expanduser(self.arglead)

        dir = os.getcwd()
        os.chdir(self.workdir)

        try:
            list = glob.iglob(self.arglead + '*')
            list = [ self.fix_path(path) for path in list ]
        finally:
            os.chdir(dir)

        return list


def bzr_complete(arglead, cmdline, workdir):

    try:
        matches = BzrComplete(arglead, cmdline, workdir).complete()
    except ValueError:
        matches = []
        e = sys.exc_info()[1]
        print >>sys.stderr, 'parse error:', e.message

    vim.command("let matches = ['" + "', '".join(matches) + "']")

vim_stdout = sys.stdout
vim_stderr = sys.stderr

class VIMOutput(StringIO):

    def flush(self):
        vim_stdout.write('\n')
        return StringIO.flush(self)

    def write(self, str):
        vim_stdout.write(str)
        return StringIO.write(self, str)


class UI(bzrlib.ui.UIFactory):

    def __init__(self, output):
        vim.command('let l:old_statusline = &l:statusline')
        bzrlib.ui.UIFactory.__init__(self)
        self.output = output
        self.task = None
        self.transport_activity = ''

    def _update_statusline(self, restore=False):
        if restore:
            vim.command('let &l:statusline = l:old_statusline')
        else:
            status = ''
            task = self.task
            if task is not None:
                status += task.msg
                if not task.show_count:
                    s = ' '
                if task.current_cnt is not None and task.total_cnt is not None:
                    s = ' %d/%d' % (task.current_cnt, task.total_cnt)
                elif task.current_cnt is not None:
                    s = ' %d' % (task.current_cnt)
                else:
                    s = ' '
                status += s
            vim.command('let &l:statusline = \'' +
                        status + self.transport_activity + '\'')
        vim.command('redrawstatus')

    def _progress_updated(self, task):
        self.task = task
        self._update_statusline()

    def _progress_all_finished(self):
        self._update_statusline(restore=True)

    def report_transport_activity(self, transport, byte_count, direction):
        # self.transport_activity = transport.__class__.__name__ + ' ' + str(byte_count) + ' ' + str(direction)
        # self._update_statusline()
        pass

    def get_password(self, prompt='', **kwargs):
        ret = vim.eval('inputsecret(\'' + prompt + ': \')')
        self.output.write(prompt + '\n')
        return ret

    def get_boolean(self, prompt):
        msg = prompt + ' [y/N]: '
        ret = vim.eval('input(\'' + msg + '\')')
        self.output.write(msg + ret + '\n')
        if 'y' == ret:
            return True
        return False

    def prompt(self, prompt, **kwargs):
        if kwargs:
            prompt = prompt % kwargs
        self.output.write(prompt)

    def note(self, msg):
        self.output.write(msg + '\n')


def getchar():
    sys.stdout.flush()
    return vim.eval('nr2char(getchar())')

def raw_input(prompt=''):
    sys.stdout.flush()
    return vim.eval('input(\'' + prompt + '\')')
    # self.output.write(msg + ret + '\n')
    # return vim.eval('input


bzrlib.osutils.getchar = getchar


def bzr_exec(cmdline, to_buffer=True, to_terminal=False):

    argv = ['bzr']
    argv.extend(shlex.split(cmdline))

    if to_terminal:
        output = VIMOutput()
    else:
        output = StringIO()

    try:

        sys.stdout = output
        sys.stderr = output

        bzrlib.ui.ui_factory = UI(output)

        # Is this a final release version? If so, we should suppress warnings
        if bzrlib.version_info[3] == 'final':
            from bzrlib import symbol_versioning
            symbol_versioning.suppress_deprecation_warnings(override=False)
        try:
            user_encoding = bzrlib.osutils.get_user_encoding()
            argv = [a.decode(user_encoding) for a in argv[1:]]
        except UnicodeDecodeError:
            raise bzrlib.errors.BzrError(("Parameter '%r' is unsupported by the current "
                                                                "encoding." % a))
        try:
            ret = bzrlib.commands.run_bzr(argv)
            output = output.getvalue()
        except:
            output = '\n'.join(traceback.format_exc().splitlines())

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

