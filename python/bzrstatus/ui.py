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


from bzrlib import ui

import time
import vim
import re


def escape(string):
    return re.sub("'", "''", string)


class UI(ui.UIFactory):

    def __init__(self, output):
        ui.UIFactory.__init__(self)
        vim.command('let l:old_more = &more')
        vim.command('set nomore')
        self.output = output
        self.task = None
        self.transport = None
        self.activity = { 'read': 0, 'write': 0, None: 0 }
        now = time.time()
        self.transport_update_time = now
        self.progress_update_time = now
        self.bytes_since_update = 0
        self.rate = 0
        self.last_progress_msg = ''
        self.last_transport_msg = ''
        self.last_task = None

    def make_output_stream(self, encoding=None, encoding_type=None):
        return self.output

    def _format_activity(self):
        msg = ''
        for direction in ('read', 'write'):
            if direction == 'read':
                dir_char = 'D'
            else:
                dir_char = 'U'
            msg += '%6dKB %s ' % (self.activity[direction] >> 10, dir_char)
        msg += '%6dKB/s' % (int(self.rate) >> 10)
        return msg

    def finish(self):
        vim.command('let &l:statusline = &g:statusline')
        vim.command('let &more = l:old_more')
        vim.command('redrawstatus')

    def _update_statusline(self):
        status = self.last_progress_msg + '%=' + self.last_transport_msg
        vim.command('let &l:statusline = \' ' + escape(status) + '\' ')
        vim.command('redrawstatus')

    def _progress_updated(self, task):
        now = time.time()
        if now > self.transport_update_time + 10:
            # no recent activity; expire it
            self.last_transport_msg = ''
        if task != self.task or now >= (self.progress_update_time + 0.2):
            status = [task.msg]
            if not task.show_count:
                s = ''
            if task.current_cnt is not None and task.total_cnt is not None:
                p = task.current_cnt * 20 / task.total_cnt
                s = '[' + ('#' * p) + ('.' * (20 - p)) + ('] %u/%u' %
                                                          (task.current_cnt,
                                                           task.total_cnt))
            elif task.current_cnt is not None:
                s = '%u' % (task.current_cnt)
            else:
                s = ''
            status.append(s)
            self.last_progress_msg = ' '.join(status)
            self.progress_update_time = now
            self.task = task
            self._update_statusline()

    def _progress_all_finished(self):
        self._update_statusline()

    def report_transport_activity(self, transport, byte_count, direction):
        self.transport = getattr(transport, '_scheme', None) or repr(transport)
        self.activity[direction] += byte_count
        self.bytes_since_update += byte_count
        now = time.time()
        if now >= (self.transport_update_time + 0.5):
            self.rate = self.bytes_since_update / (now - self.transport_update_time)
            self.bytes_since_update = 0
            self.transport_update_time = now
            self.last_transport_msg = self.transport + ' ' + self._format_activity()
            self._update_statusline()

    def get_username(self, prompt, **kwargs):
        self.output.flush()
        if kwargs:
            prompt = prompt % kwargs
        ret = vim.eval('input(\'' + escape(prompt) + ': \')')
        self.output.write(prompt + '\n')
        return ret

    def get_password(self, prompt='', **kwargs):
        self.output.flush()
        if kwargs:
            prompt = prompt % kwargs
        ret = vim.eval('inputsecret(\'' + escape(prompt) + ': \')')
        self.output.write(prompt + '\n')
        return ret

    def get_boolean(self, prompt):
        self.output.flush()
        ret = int(vim.eval('confirm(\'' + escape(prompt) + '\', "&Yes\n&No", 2)'))
        if 1 != ret:
            ret = 0
        self.output.write(prompt + '? ' + ['no', 'yes'][ret] + '\n')
        return 1 == ret

    def prompt(self, prompt, **kwargs):
        self.output.flush()
        if kwargs:
            prompt = prompt % kwargs
        self.output.write(prompt)

    def note(self, msg):
        self.output.write(msg + '\n')
        self.output.flush()


