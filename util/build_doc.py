#!/usr/bin/env python2.5

# Build all available asciidoc and doxygen documentation, and create an html index file
# Originally By 510 Systems
# http://www.510systems.com
# Modified for the Nonpolynomial Labs Build System by Kyle Machulis
# http://www.nonpolynomial.com/

'''
Enumerate available build targets, and return build target for current system
'''

from optparse import OptionParser
import dircache
import os
import re, operator
import sys


def build_doc_index(asciidocs, doxyfiles):
    return

def build_doxygen(filename, output_dir):
    doxygen_output_dir = os.path.join(output_dir, "doxygen")
    if not os.path.exists(doxygen_output_dir):
        os.makedirs(doxygen_output_dir)
    print "Building doxygen for %s to %s" % (filename, doxygen_output_dir)
    os.chdir(doxygen_output_dir)
    os.system("doxygen %s" % (filename))
    return output_dir

def build_asciidoc(filename, output_dir):
    asciidoc_output_dir = os.path.join(output_dir, "asciidoc")
    if not os.path.exists(asciidoc_output_dir):
        os.makedirs(asciidoc_output_dir)
    output_file = os.path.join(asciidoc_output_dir, os.path.splitext(os.path.split(filename)[-1])[0] + ".html")
    print "Building asciidoc for %s to %s" % (filename, output_file)
    os.system("asciidoc -o %s %s" % (output_file, filename))
    return output_file

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option('-d', '--dir', dest='dir', action='store', default='', help='Directory to scan for Doxygen and asciidoc files')
    parser.add_option('-o', '--output', dest='output', action='store', default='', help='Directory to output files to')
    (options, args) = parser.parse_args()

    if not options.dir or not options.output:
        parser.print_help()
        sys.exit(1)

    print "Building documentation to %s" % (options.dir)
    files = dircache.listdir(options.dir)
    asciidocs = [build_asciidoc(os.path.join(options.dir, asciidoc_file), options.output) for asciidoc_file in filter(lambda x: os.path.splitext(x)[-1] == ".asciidoc", files)]
    doxyfile = [build_doxygen(os.path.join(options.dir, doxyfile), options.output) for doxyfile in filter(lambda x: os.path.split(x)[-1] == "Doxyfile", files)]
    sys.exit(0)
                     
