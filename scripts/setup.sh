#!/bin/bash


# Install software
sudo apt-get install sra-toolkit cmake zlib1g-dev
cd
mkdir software

# Install MegaHit
cd
cd software
git clone https://github.com/voutcn/megahit.git
cd megahit
make
echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc
source ~/.bashrc

# Install Prodigal
cd
cd software
git clone https://github.com/hyattpd/Prodigal.git
cd Prodigal
make
sudo make install

# Install Diamond
cd
cd software
git clone https://github.com/bbuchfink/diamond.git
cd diamond
./build_simple.sh 
echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc
source ~/.bashrc
 



# Install MMseqs2
cd
cd software
git clone https://github.com/soedinglab/MMseqs2.git
cd MMseqs2
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=. ..
make -j
make install 
echo "export PATH=$(pwd)/bin/:\$PATH" >> ~/.bashrc
source ~/.bashrc

# Install Plass
cd
cd software
git clone https://github.com/soedinglab/plass.git
cd plass
git submodule update --init
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=. ..
make -j 4 && make install
echo "export PATH=$(pwd)/bin/:\$PATH" >> ~/.bashrc
source ~/.bashrc

# HMMER
cd
cd software
wget http://eddylab.org/software/hmmer/hmmer-3.2.tar.gz
tar zxvf hmmer-3.2.tar.gz 
cd hmmer-3.2
./configure
make -j 8
echo "export PATH=$(pwd)/src/:\$PATH" >> ~/.bashrc
source ~/.bashrc


# Fetch data
cd
mkdir data
cd data/
fastq-dump ERR1384114 # HiSeq


# get databases
cd
mkdir databases
cd databases
wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.fasta.gz
gzip -d Pfam-A.fasta.gz
# Building dbs
#    * MMSeqs
wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.full.gz
mmseqs convertmsa Pfam-A.full.gz pfamMsa
rm Pfam-A.full.gz
mmseqs msa2profile pfamMsa pfamProfiles --match-mode 1
rm pfamMsa*
mmseqs createindex pfamProfiles tmp -k 5 -s 7
ln -s ~/databases/pfamProfiles_seq_h ~/databases/pfamProfiles_consensus_h
ln -s ~/databases/pfamProfiles_seq_h.index ~/databases/pfamProfiles_consensus_h.index
mmseqs convert2fasta pfamProfiles_consensus pfamProfiles_consensus.faa
#    * Diamond
diamond makedb --in Pfam-A.fasta -d pfamDiamond.db
diamond makedb --in pfamProfiles_consensus.faa -d pfamConsensusDiamond.db
rm Pfam-A.fasta
#    * HMMER
wget http://wwwuser.gwdg.de/~mmirdit/scratch/hmmer.tar.gz
tar zxvf hmmer.tar.gz 
rm hmmer.tar.gz

