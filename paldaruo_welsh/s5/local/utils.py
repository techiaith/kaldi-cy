#!/usr/bin/env python
import os, codecs


def get_directory_structure(rootdir):
    """
    Creates a nested dictionary that represents the folder structure of rootdir
    """
    dir = {}
    
    rootdir = rootdir.rstrip(os.sep)
    start = rootdir.rfind(os.sep) + 1
    for path, dirs, files in os.walk(rootdir, followlinks=True):
        folders = path[start:].split(os.sep)
        subdir = dict.fromkeys(files)
        parent = reduce(dict.get, folders[:-1], dir)
        parent[folders[-1]] = subdir

    topdirname = dir.iterkeys().next()
    return dir[topdirname]

	
def get_prompts(sourcefile):
    """
    Creates a dictionary of sample ids to prompt texts
    """
    prompts = {}
    with codecs.open(sourcefile,'rb','utf-8') as prompts_file:
        for line in prompts_file:
            elements = line.rstrip().split(' ',1)
            key = elements[0].replace('*/','')
            prompts[key]=elements[1]

    return prompts
