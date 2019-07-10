Punchline Pfam domain searches

Dependencies:
HMMER3 Ð installation instructions here: http://hmmer.org/documentation.html
Python2.7 or Python3
Biopython - http://biopython.org/DIST/docs/install/Installation.html
R
R corrplot library Ð install.packages(ÒcorrplotÓ) from within R

First step:
Gather your files:
1. Download Pfam-A database from here: https://pfam.xfam.org and FTP tab at the top of the page
                Make a note of the version number in case you need to quote it later.
2. Collect all your proteins to search in one file as a protein fasta file Ð you will need to make sure each protein is named so that you know which strain it was from and all need a unique name such as H10407|H10407_0003.  The strain name should be first, followed by a | character and the name of the coding sequence or locus tag.
** more details on how to do this if requested **
Second step:
        Run Pfam Ð the fastest way to search a large number of protein sequences with a large number of Pfam motifs is to use hmmsearch.  
hmmsearch Ð-noali Ð-notextw --cpu [insert number of cpus here] --domtblout your_outfile_name Pfam_A_hmm_profiles your_protein_fasta

Third step:
         Get your raw hmmer file in shape with:
         Rejig_hmmer_output.py yourhmmeroutputfile

Fourth step:
         Run pfam_presence_absence.py
pfam_presence_absence.py hmmsearch_outfile Pfam_domain_names

This will create a large number of files, each with the top line of the species in question
The Pfam_domain_names file is a list of all the Pfam domain shortnames you are searching with, as a text file with one name per line.  An example file is provided in github as motifs.txt and is specific for the 32.0 version of Pfam-A, released Sept. 2018.

Fifth step:
         We join these files to an R matrix with:
join_and_create_dataset_punchline.R
       Includes:
   Kruskal-wallis significance testing using R

***What to do if the plot needs resizing***** - coming soon.

Sixth step:
          Heatmap and correlation plot using Rscript
Rscript Heatmapper_punchline.R

Seventh step:
          Phylogeny clustering
*still under construction
You will be able to build the input phylogeny file by: running plot_pfam_phylog.R
Then run phylip neighbour on that file and afterwards run: plot_pfam_phylog.R
If you get errors (usually about the strain names) you can try: validateforphylip.py

Look at the resulting tree with your favourite tree viewer program
Or try color_tree_labels.R in useful_scripts folder on github.
         
