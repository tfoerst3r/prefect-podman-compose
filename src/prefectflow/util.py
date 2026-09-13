# SPDX-FileCopyrightText: 2026 Thomas Förster <noreply@tfoerster.de>
#
# SPDX-License-Identifier: MIT


def __hidden() -> None:
    print('foo call')

def foo() -> None:
    __hidden()
