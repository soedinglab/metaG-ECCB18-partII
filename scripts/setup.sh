#!/bin/bash -e

# Install software
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install sra-toolkit cmake zlib1g-dev npm build-essential git

BASE="$HOME/mmseqs2tutorial"
mkdir $BASE && cd $BASE
mkdir software && cd software

# Install MegaHit
git clone https://github.com/voutcn/megahit.git
cd megahit
git checkout ef1bae692ee435b5bcc78407be25f4a051302f74
make -j 8
echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc

# Install Prodigal
cd $BASE/software
git clone https://github.com/hyattpd/Prodigal.git
cd Prodigal
git checkout fe80417640fe00a35dc0b5d771c6c75f4403a4d0
make
sudo make install

# Install MMseqs2
cd $BASE/software
git clone https://github.com/soedinglab/MMseqs2.git
cd MMseqs2
git checkout 9375bafabbb1e714404887bcfe6b8ce879092cd5
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DHAVE_TESTS=0 -DCMAKE_INSTALL_PREFIX=. ..
make -j 8
make install
MMDIR=$(pwd)
echo "export PATH=$(pwd)/bin/:\$PATH" >> ~/.bashrc
echo "if [ -f ${MMDIR}/util/bash-completion.sh ]; then" >> ~/.bashrc
echo "    ${MMDIR}/util/bash-completion.sh" >> ~/.bashrc
echo "fi" >> ~/.bashrc

# Install Plass
cd $BASE/software
git clone https://github.com/soedinglab/plass.git
cd plass
git checkout 2e0ef60c705798a1617b499e6ae919ace938e1fc
git submodule update --init
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=. ..
make -j 4 && make install
echo "export PATH=$(pwd)/bin/:\$PATH" >> ~/.bashrc

# HMMER
cd $BASE/software
wget http://eddylab.org/software/hmmer/hmmer-3.2.tar.gz
tar zxvf hmmer-3.2.tar.gz
cd hmmer-3.2
./configure
make -j 8
echo "export PATH=$(pwd)/src/:\$PATH" >> ~/.bashrc

# Fetch data
mkdir $BASE/data
cd $BASE/data
#fastq-dump SRR5802616
#fastq-dump SRR7690139 # MiSeq human gut (small)
#fastq-dump ERR695607 # HiSeq human gut (big: 2Gb)
#fastq-dump SRR6484311 # HiSeq 2500
# (((((("illumina"[Platform]) AND "instrument illumina hiseq 2500"[Properties]) AND "00000000150"[ReadLength]) AND human gut) AND "wgs"[Strategy])) AND "paired"[Layout]
#fastq-dump SRR3998932 # MiSeq
fastq-dump ERR1384114 # HiSeq
rm -rf $HOME/ncbi


# bashrc
echo -e 'function getentry {\n    tail -c+$2 "$1" | head -c$3\n}\n' >> ~/.bashrc
source ~/.bashrc

# get databases
mkdir $BASE/databases
cd $BASE/databases
#wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.fasta.gz
#gzip -d Pfam-A.fasta.gz
#rm Pfam-A.fasta
# Building dbs
#    * MMSeqs
wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.full.gz
mmseqs convertmsa Pfam-A.full.gz pfamMsa
mmseqs msa2profile pfamMsa pfamProfiles --match-mode 1
rm -f pfamMsa pfamMsa.index
rm -f Pfam-A.full.gz
mmseqs createindex pfamProfiles tmp -k 5 -s 7
ln -sf $BASE/databases/pfamProfiles_seq_h $BASE/databases/pfamProfiles_consensus_h
ln -sf $BASE/databases/pfamProfiles_seq_h.index $BASE/databases/pfamProfiles_consensus_h.index
mmseqs convert2fasta pfamProfiles_consensus pfamProfiles_consensus.faa

#    * HMMER
wget http://wwwuser.gwdg.de/~mmirdit/scratch/hmmer.tar.gz
tar zxvf hmmer.tar.gz
rm hmmer.tar.gz

# to open a file in an internal editor window of this IDE
sudo npm install -g c9

