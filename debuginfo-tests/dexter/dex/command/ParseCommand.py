# DExTer : Debugging Experience Tester
# ~~~~~~   ~         ~~         ~   ~~
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Parse a DExTer command. In particular, ensure that only a very limited
subset of Python is allowed, in order to prevent the possibility of unsafe
Python code being embedded within DExTer commands.
"""

import os
import unittest
from copy import copy

from collections import defaultdict, OrderedDict

from dex.utils.Exceptions import CommandParseError

from dex.command.CommandBase import CommandBase
from dex.command.commands.DexExpectProgramState import DexExpectProgramState
from dex.command.commands.DexExpectStepKind import DexExpectStepKind
from dex.command.commands.DexExpectStepOrder import DexExpectStepOrder
from dex.command.commands.DexExpectWatchType import DexExpectWatchType
from dex.command.commands.DexExpectWatchValue import DexExpectWatchValue
from dex.command.commands.DexLabel import DexLabel
from dex.command.commands.DexUnreachable import DexUnreachable
from dex.command.commands.DexWatch import DexWatch
from dex.utils import Timer
from dex.utils.Exceptions import CommandParseError, DebuggerException

def _get_valid_commands():
    """Return all top level DExTer test commands.

    Returns:
        { name (str): command (class) }
    """
    return {
      DexExpectProgramState.get_name() : DexExpectProgramState,
      DexExpectStepKind.get_name() : DexExpectStepKind,
      DexExpectStepOrder.get_name() : DexExpectStepOrder,
      DexExpectWatchType.get_name() : DexExpectWatchType,
      DexExpectWatchValue.get_name() : DexExpectWatchValue,
      DexLabel.get_name() : DexLabel,
      DexUnreachable.get_name() : DexUnreachable,
      DexWatch.get_name() : DexWatch
    }


def _get_command_name(command_raw: str) -> str:
    """Return command name by splitting up DExTer command contained in
    command_raw on the first opening paranthesis and further stripping
    any potential leading or trailing whitespace.
    """
    return command_raw.split('(', 1)[0].rstrip()


def _merge_subcommands(command_name: str, valid_commands: dict) -> dict:
    """Merge valid_commands and command_name's subcommands into a new dict.

    Returns:
        { name (str): command (class) }
    """
    subcommands = valid_commands[command_name].get_subcommands()
    if subcommands:
        return { **valid_commands, **subcommands }
    return valid_commands


def _build_command(command_type, raw_text: str, path: str, lineno: str) -> CommandBase:
    """Build a command object from raw text.

    This function will call eval().

    Raises:
        Any exception that eval() can raise.

    Returns:
        A dexter command object.
    """
    valid_commands = _merge_subcommands(
        command_type.get_name(), { command_type.get_name(): command_type })
    # pylint: disable=eval-used
    command = eval(raw_text, valid_commands)
    # pylint: enable=eval-used
    command.raw_text = raw_text
    command.path = path
    command.lineno = lineno
    return command


def resolve_labels(command: CommandBase, commands: dict):
    """Attempt to resolve any labels in command"""
    dex_labels = commands['DexLabel']
    command_label_args = command.get_label_args()
    for command_arg in command_label_args:
        for dex_label in list(dex_labels.values()):
            if (os.path.samefile(dex_label.path, command.path) and
                dex_label.eval() == command_arg):
                command.resolve_label(dex_label.get_as_pair())
    # labels for command should be resolved by this point.
    if command.has_labels():
        syntax_error = SyntaxError()
        syntax_error.filename = command.path
        syntax_error.lineno = command.lineno
        syntax_error.offset = 0
        syntax_error.msg = 'Unresolved labels'
        for label in command.get_label_args():
            syntax_error.msg += ' \'' + label + '\''
        raise syntax_error


def _search_line_for_cmd_start(line: str, start: int, valid_commands: dict) -> int:
    """Scan `line` for a string matching any key in `valid_commands`.

    Start searching from `start`.
    Commands escaped with `\` (E.g. `\DexLabel('a')`) are ignored.

    Returns:
        int: the index of the first character of the matching string in `line`
        or -1 if no command is found.
    """
    for command in valid_commands:
        idx = line.find(command, start)
        if idx != -1:
            # Ignore escaped '\' commands.
            if idx > 0 and line[idx - 1] == '\\':
                continue
            return idx
    return -1


def _search_line_for_cmd_end(line: str, start: int, paren_balance: int) -> (int, int):
    """Find the end of a command by looking for balanced parentheses.

    Args:
        line: String to scan.
        start: Index into `line` to start looking.
        paren_balance(int): paren_balance after previous call.

    Note:
        On the first call `start` should point at the opening parenthesis and
        `paren_balance` should be set to 0. Subsequent calls should pass in the
        returned `paren_balance`.

    Returns:
        ( end,  paren_balance )
        Where end is 1 + the index of the last char in the command or, if the
        parentheses are not balanced, the end of the line.

        paren_balance will be 0 when the parentheses are balanced.
    """
    for end in range(start, len(line)):
        ch = line[end]
        if ch == '(':
            paren_balance += 1
        elif ch == ')':
            paren_balance -=1
        if paren_balance == 0:
            break
    end += 1
    return (end, paren_balance)


class TextPoint():
    def __init__(self, line, char):
        self.line = line
        self.char = char

    def get_lineno(self):
        return self.line + 1

    def get_column(self):
        return self.char + 1


def format_parse_err(msg: str, path: str, lines: list, point: TextPoint) -> CommandParseError:
    err = CommandParseError()
    err.filename = path
    err.src = lines[point.line].rstrip()
    err.lineno = point.get_lineno()
    err.info = msg
    err.caret = '{}<r>^</>'.format(' ' * (point.char))
    return err


def skip_horizontal_whitespace(line, point):
    for idx, char in enumerate(line[point.char:]):
        if char not in ' \t':
            point.char += idx
            return


def _find_all_commands_in_file(path, file_lines, valid_commands):
    commands = defaultdict(dict)
    paren_balance = 0
    region_start = TextPoint(0, 0)
    for region_start.line in range(len(file_lines)):
        line = file_lines[region_start.line]
        region_start.char = 0

        # Search this line till we find no more commands.
        while True:
            # If parens are currently balanced we can look for a new command.
            if paren_balance == 0:
                region_start.char = _search_line_for_cmd_start(line, region_start.char, valid_commands)
                if region_start.char == -1:
                    break # Read next line.

                command_name = _get_command_name(line[region_start.char:])
                cmd_point = copy(region_start)
                cmd_text_list = [command_name]

                region_start.char += len(command_name) # Start searching for parens after cmd.
                skip_horizontal_whitespace(line, region_start)
                if region_start.char >= len(line) or line[region_start.char] != '(':
                    raise format_parse_err(
                        "Missing open parenthesis", path, file_lines, region_start)

            end, paren_balance = _search_line_for_cmd_end(line, region_start.char, paren_balance)
            # Add this text blob to the command.
            cmd_text_list.append(line[region_start.char:end])
            # Move parse ptr to end of line or parens
            region_start.char = end

            # If the parens are unbalanced start reading the next line in an attempt
            # to find the end of the command.
            if paren_balance != 0:
                break  # Read next line.

            # Parens are balanced, we have a full command to evaluate.
            raw_text = "".join(cmd_text_list)
            try:
                command = _build_command(
                    valid_commands[command_name],
                    raw_text,
                    path,
                    cmd_point.get_lineno(),
                )
            except SyntaxError as e:
                # This err should point to the problem line.
                err_point = copy(cmd_point)
                # To e the command start is the absolute start, so use as offset.
                err_point.line += e.lineno - 1 # e.lineno is a position, not index.
                err_point.char += e.offset - 1 # e.offset is a position, not index.
                raise format_parse_err(e.msg, path, file_lines, err_point)
            except TypeError as e:
                # This err should always point to the end of the command name.
                err_point = copy(cmd_point)
                err_point.char += len(command_name)
                raise format_parse_err(str(e), path, file_lines, err_point)
            else:
                resolve_labels(command, commands)
                assert (path, cmd_point) not in commands[command_name], (
                    command_name, commands[command_name])
                commands[command_name][path, cmd_point] = command

    if paren_balance != 0:
        # This err should always point to the end of the command name.
        err_point = copy(cmd_point)
        err_point.char += len(command_name)
        msg = "Unbalanced parenthesis starting here"
        raise format_parse_err(msg, path, file_lines, err_point)
    return dict(commands)

def _find_all_commands(source_files):
    commands = defaultdict(dict)
    valid_commands = _get_valid_commands()
    for source_file in source_files:
        with open(source_file) as fp:
            lines = fp.readlines()
        file_commands = _find_all_commands_in_file(source_file, lines,
                                                   valid_commands)
        for command_name in file_commands:
            commands[command_name].update(file_commands[command_name])

    return dict(commands)

def get_command_infos(source_files):
  with Timer('parsing commands'):
      try:
          commands = _find_all_commands(source_files)
          command_infos = OrderedDict()
          for command_type in commands:
              for command in commands[command_type].values():
                  if command_type not in command_infos:
                      command_infos[command_type] = []
                  command_infos[command_type].append(command)
          return OrderedDict(command_infos)
      except CommandParseError as e:
          msg = 'parser error: <d>{}({}):</> {}\n{}\n{}\n'.format(
                e.filename, e.lineno, e.info, e.src, e.caret)
          raise DebuggerException(msg)

class TestParseCommand(unittest.TestCase):
    class MockCmd(CommandBase):
        """A mock DExTer command for testing parsing.

        Args:
            value (str): Unique name for this instance.
        """

        def __init__(self, *args):
           self.value = args[0]

        def get_name():
            return __class__.__name__

        def eval(this):
            pass


    def __init__(self, *args):
        super().__init__(*args)

        self.valid_commands = {
            TestParseCommand.MockCmd.get_name() : TestParseCommand.MockCmd
        }


    def _find_all_commands_in_lines(self, lines):
        """Use DExTer parsing methods to find all the mock commands in lines.

        Returns:
            { cmd_name: { (path, line): command_obj } }
        """
        return _find_all_commands_in_file(__file__, lines, self.valid_commands)


    def _find_all_mock_values_in_lines(self, lines):
        """Use DExTer parsing methods to find all mock command values in lines.

        Returns:
            values (list(str)): MockCmd values found in lines.
        """
        cmds = self._find_all_commands_in_lines(lines)
        mocks = cmds.get(TestParseCommand.MockCmd.get_name(), None)
        return [v.value for v in mocks.values()] if mocks else []


    def test_parse_inline(self):
        """Commands can be embedded in other text."""

        lines = [
            'MockCmd("START") Lorem ipsum dolor sit amet, consectetur\n',
            'adipiscing elit, MockCmd("EMBEDDED") sed doeiusmod tempor,\n',
            'incididunt ut labore et dolore magna aliqua.\n'
        ]

        values = self._find_all_mock_values_in_lines(lines)

        self.assertTrue('START' in values)
        self.assertTrue('EMBEDDED' in values)


    def test_parse_multi_line_comment(self):
        """Multi-line commands can embed comments."""

        lines = [
            'Lorem ipsum dolor sit amet, consectetur\n',
            'adipiscing elit, sed doeiusmod tempor,\n',
            'incididunt ut labore et MockCmd(\n',
            '    "WITH_COMMENT" # THIS IS A COMMENT\n',
            ') dolore magna aliqua. Ut enim ad minim\n',
        ]

        values = self._find_all_mock_values_in_lines(lines)

        self.assertTrue('WITH_COMMENT' in values)

    def test_parse_empty(self):
        """Empty files are silently ignored."""

        lines = []
        values = self._find_all_mock_values_in_lines(lines)
        self.assertTrue(len(values) == 0)

    def test_parse_bad_whitespace(self):
        """Throw exception when parsing badly formed whitespace."""
        lines = [
            'MockCmd\n',
            '("XFAIL_CMD_LF_PAREN")\n',
        ]

        with self.assertRaises(CommandParseError):
            values = self._find_all_mock_values_in_lines(lines)

    def test_parse_good_whitespace(self):
        """Try to emulate python whitespace rules"""

        lines = [
            'MockCmd("NONE")\n',
            'MockCmd    ("SPACE")\n',
            'MockCmd\t\t("TABS")\n',
            'MockCmd(    "ARG_SPACE"    )\n',
            'MockCmd(\t\t"ARG_TABS"\t\t)\n',
            'MockCmd(\n',
            '"CMD_PAREN_LF")\n',
        ]

        values = self._find_all_mock_values_in_lines(lines)

        self.assertTrue('NONE' in values)
        self.assertTrue('SPACE' in values)
        self.assertTrue('TABS' in values)
        self.assertTrue('ARG_SPACE' in values)
        self.assertTrue('ARG_TABS' in values)
        self.assertTrue('CMD_PAREN_LF' in values)


    def test_parse_share_line(self):
        """More than one command can appear on one line."""

        lines = [
            'MockCmd("START") MockCmd("CONSECUTIVE") words '
                'MockCmd("EMBEDDED") more words\n'
        ]

        values = self._find_all_mock_values_in_lines(lines)

        self.assertTrue('START' in values)
        self.assertTrue('CONSECUTIVE' in values)
        self.assertTrue('EMBEDDED' in values)


    def test_parse_escaped(self):
        """Escaped commands are ignored."""

        lines = [
            'words \MockCmd("IGNORED") words words words\n'
        ]

        values = self._find_all_mock_values_in_lines(lines)

        self.assertFalse('IGNORED' in values)
