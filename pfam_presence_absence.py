#!/usr/bin/python3


import sys
from collections import Counter
d = {}
mofits = []

try:
    handle = open(sys.argv[1], 'r')
    infile = open(sys.argv[2], 'r')
except:
    print("Usage: python pfam_presence_abscence.py hmmer_search_result_file textfile_list_of_pfam_domains_one_on_each_line.txt")

for lin in infile:
    mofits.append(lin.rstrip())

for line in handle:
    if line.startswith('#'):
        pass
    else:
        elements = line.split()
        species = elements[0].split('|')
        names = species[0]
        try:
            d[names].append(elements[3])
        except:
            d[names]=[elements[3]]


for key, value in d.items():
    outfile = open(key+".pfams", 'w')
    outfile.write(key+"\n")
    c = Counter(value)
    for m in mofits:
        print m
        if m in c.keys():
              statement = "{}\n".format(int(c[m]))
              outfile.write("{}".format(statement))
        else:
            statement = "{}\n".format(0)
            outfile.write(statement)

