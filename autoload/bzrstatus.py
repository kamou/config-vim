#! /usr/bin/env python

import bzrlib.commands
import bzrlib.config
import bzrlib.plugin
import os.path
import shlex
import glob
import vim

bzrlib.plugin.load_plugins()

class BzrComplete():

    def __init__(self, arglead, cmdline,
                 complete_command_aliases=False,
                 complete_hidden_commands=False):

        self.cmdline = cmdline
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

        return self.filter(cmds)

    def complete_options(self):

        if self.cmdobj is None:
            return []

        opts = [ '--' + opt.name for opt in self.cmdobj.options().values() ]

        return self.filter(opts)

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

        list = glob.iglob(self.arglead + '*')
        list = [ self.fix_path(path) for path in list ]

        return list

def bzr_complete(arglead, cmdline):

    matches = BzrComplete(arglead, cmdline).complete()

    vim.command("let matches = ['" + "', '".join(matches) + "']")

