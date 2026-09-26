import json
import os
import pickle
import subprocess

import yaml


def smell(items=[]):  # mutable default
    try:
        subprocess.run("echo hi", shell=True)
        os.system("echo hi")
        eval("1+1")
        exec("x=1")
        pickle.loads(b"")
        yaml.load("a: 1")
        _ = os.environ["SECRET"]
        _ = json.loads("{}")
    except:
        pass  # type: ignore
    return items  # noqa
