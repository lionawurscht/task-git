# task-git.sh

`task-git.sh` is a wrapper around Taskwarrior's `task` that places the task
database in version control, and generates commits each time the `task` database
is altered.

## Usage

1. Navigate to your Taskwarrior data directory (usually in `~/.task`) and type `git init`. If you plan to push to a remote, go ahead and add your remote now.
2. Add symlink to task-git.sh as /usr/bin/task-git

    `ln -s /path/to/task-git/task-git.sh /usr/bin/task-git`

3. Run `chmod +x /path/to/task-git/task-git.sh`.
4. Use `task-git` instead of `task` when you want the Taskwarrior database files to be automatically committed to version control after each operation.
5. (Optional) Edit /etc/bash_completion.d/task to add this line to the end of the file so `task-git` will <TAB>-complete the same as `task`

    `complete -o nospace -F _task task-git`
6. You can set the default behavior for push/pull via the task config file. Set `git.push` and `git.pull` to either `1` or `0`.
7. For some debug messaged run like this: `DEBUG=true task-git`

It is recommended to use the Taskwarrior database only on one machine, as you will be resolving conflicts if using the same task database on multiple machines.

## Installation

On arch you may install using the provided `PKGBUILD` in `arch`. Just run `makepkg -si`.

## License

task-git.sh
Copyright (C) 2013 Kosta Harlan
Copyright (C) 2015 Timothy Hallett (on modifications)
Copyright (C) 2018 Lion Waaser (on modifications)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

