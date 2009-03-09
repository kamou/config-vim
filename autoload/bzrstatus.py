#! /usr/bin/env python

import bzrlib.commands
import bzrlib.config
import bzrlib.plugin
import os.path
import shlex
import glob
import vim
import re

bzrlib.plugin.load_plugins()

def bzr_complete_commands():

    cmds = []

    for cmdname, cmdclass in bzrlib.commands.get_all_cmds():
        if cmdclass.hidden:
            continue
        cmds.append(cmdname)
        for alias in cmdclass.aliases:
            cmds.append(alias)

    for alias in bzrlib.config.GlobalConfig().get_aliases().keys():
        cmds.append(alias)

    return cmds

def bzr_complete_options(cmdname):

    cmdobj = bzrlib.commands.get_cmd_object(cmdname)

    return [ '--' + opt.name for opt in cmdobj.options().values() ]

def bzr_complete_fix_path(path):
    if os.path.isdir(path):
        return path + '/'
    return path

def bzr_complete_path(arglead):

    m = re.match('^(~\w*)(/.*|$)', arglead)

    if m:
        arglead = os.path.expanduser(m.group(1)) + m.group(2)

    return [ glob.iglob(arglead + '*'), bzr_complete_fix_path ]

def bzr_complete(arglead, cmdline):

    args = shlex.split(cmdline)

    if '' == arglead:
        argc = len(args) + 1
    else:
        argc = len(args)

    fix = lambda e: e

    if 2 == argc:
        list = bzr_complete_commands()
    else:
        if 0 < len(arglead) and '-' == arglead[0]:
            list = bzr_complete_options(args[1])
        else:
            list, fix = bzr_complete_path(arglead)

    matches = []

    for item in list:
        if item.startswith(arglead):
            matches.append(fix(item))

    matches.sort()

    vim.command("let matches = ['" + "', '".join(matches) + "']")

