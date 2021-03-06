#!/bin/sh
# test for basic tee functionality.

# Copyright (C) 2005-2014 Free Software Foundation, Inc.

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
print_ver_ tee

echo line >sample || framework_failure_
nums=$(seq 9) || framework_failure_

for n in 0 $nums; do
        files=$(seq $n)
        rm -f $files
        tee $files <sample >out || fail=1
        for f in out $files; do
                compare sample $f || fail=1
        done
done

Exit $fail
