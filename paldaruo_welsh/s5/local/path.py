#!/usr/bin/env python
from subprocess import Popen, PIPE
from os import path

class ShellScriptException(Exception):
    def __init__(self, shell_script, shell_error):
        self.shell_script = shell_script
        self.shell_error = shell_error
        msg = "Error processing script %s: %s" % (shell_script, shell_error)
        Exception.__init__(self, msg)


def get_var(script_path, var):
    """
    Given a script, and the name of an environment variable, returns the
    value of the environment variable.
    :param script_path: Path the a shell script
    :type script_path: str or unicode
    :param var: environment variable name
    :type var: str or unicode
    :return: str
    """
    if path.isfile(script_path):
        input = '. "%s"; echo -n "$%s"\n'% (script_path, var)
        pipe = Popen(["bash"],  stdout=PIPE, stdin=PIPE, stderr=PIPE)
        stdout_data, stderr_data = pipe.communicate(input=input)
        if stderr_data:
            raise ShellScriptException(script_path, stderr_data)
        else:
            return stdout_data
    else:
        raise _noscripterror(script_path)

