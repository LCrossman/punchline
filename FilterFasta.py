#!/usr/bin/python


#Program to filter out problem protein sequences, remove '*' from ends of predicted sequences and remove sequences shorter than 20 aa

import sys
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import os

sequences = []


for file in os.walk(topdown=False):
    records = list(SeqIO.parse(file, "fasta"))
    for rec in records:
        if len(rec.seq) == 0:
            sys.exit("zero length sequence in file {}".format(file))
        elif '|' not in rec.id:
            sys.exit("problem with ID field in {}".format(file))
        elif str(rec.seq).endswith('*'):
            rec.seq = Seq(str(rec.seq)[-1])
        elif len(rec.seq) < 20:
            print("Very short sequence in file {}, excluding".format(file))
        else:
            pass
    sequences.append(rec)


outfile = open("goodProteins.fasta", 'w')
SeqIO.write(sequences, outfile, "fasta")
