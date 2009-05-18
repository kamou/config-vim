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


import bzrlib
import vim


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


