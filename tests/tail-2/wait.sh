#!/bin/sh
# Make sure that 'tail -f' returns immediately if a file doesn't exist
# while 'tail -F' waits for it to appear.

# Copyright (C) 2003-2014 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ tail

touch here || framework_failure_
{ touch unreadable && chmod a-r unreadable; } || framework_failure_


for inotify in ---disable-inotify ''; do
  timeout 10 tail -s0.1 -f $inotify not_here
  test $? = 124 && fail=1

  if test ! -r unreadable; then # can't test this when root
    timeout 10 tail -s0.1 -f $inotify unreadable
    test $? = 124 && fail=1
  fi

  timeout 1 tail -s0.1 -f $inotify here 2>tail.err
  test $? = 124 || fail=1

  # 'tail -F' must wait in any case.

  timeout 1 tail -s0.1 -F $inotify here 2>>tail.err
  test $? = 124 || fail=1

  if test ! -r unreadable; then # can't test this when root
    timeout 1 tail -s0.1 -F $inotify unreadable
    test $? = 124 || fail=1
  fi

  timeout 1 tail -s0.1 -F $inotify not_here
  test $? = 124 || fail=1

  grep -Ev 'inotify (resources exhausted|cannot be used)' tail.err > x
  mv x tail.err
  test -s tail.err && fail=1
  >tail.err

  tail_F()
  {
    local delay="$1"

    touch k || framework_failure_
    tail -s.1 --max-unchanged-stats=2 -F $inotify k > tail.out &
    pid=$!
    sleep $delay
    mv k l
    sleep $delay
    touch k
    mv k l
    sleep $delay
    echo NO >> l
    sleep $delay
    kill $pid
    rm -f k l

    test ! -s tail.out
  }
  retry_delay_ tail_F .1 4 || fail=1
done

Exit $fail
