# flu-NGS-analysis
*Nextflow pipeline to generate consensus sequences and perform variant calling on influenza next-gen sequencing data.* 
*This pipeline runs on nextflow version 24.10.4.*

The pipeline performs the following processes:
1. Adapter trimming (*fastp*)
2. Primer trimming (*Cutadapt*)
3. Filtering out host reads (*Bowtie 2*)
4. Aligning reads to viral reference sequences for each gene segment (*Bowtie 2*)
5. Removing optical duplicates (*Picard*)
6. Collecting per-nucleotide read depth data (*SAMtools*)
7. Generating consensus sequences (*iVar*)
8. Calling sub-consensus variants and annotating protein-level effects (*iVar*)

This version of the pipeline uses the 2024-2025 IAV vaccine strains (*A/Wisconsin/67/2022(H1N1)* and *A/Massachusetts/18/2022(H3N2)*) and a recent Victoria-lineage IBV strain (*B/Texas/20/2024*) for genome alignment and variant calling. 

# Logging on to the biocluster

If you don't have a biocluster account, you can request one here: https://www.igb.illinois.edu/content/biocluster-account-form

1. In a terminal window, type:
   ```
   ssh yournetid@biologin3.igb.illinois.edu
   ```
   
   (filling in your own netid)
   
2. Give your IGB password when prompted.


# Downloading raw sequence data

1. Navigate to our lab's directory with:
   
   ```
   cd /home/groups/hpcbio_shared/cbrooke_lab
   ```
2. Create a new directory for your project and navigate inside it:
   
   ```
   mkdir new_project_folder
   cd new_project_folder
   ```
3. Create a subdirectory for your sequence data and navigate inside it:
   
   ```
   mkdir fastq
   cd fastq
   ```
    It doesn't matter what you call your project folder, but the sequences folder should be named "fastq".
   
4. Download your sequencing data by copying the curl command provided in the email from the sequencing facility.
   
5. Log on to a compute node using:
   ```
   srun --pty /bin/bash
   ```  

7. Uncompress the downloaded .tar file:
   
   ```
   tar -xf name_of_file.tar.bz2
   ```

# Preparing to run nextflow

1. Create a .csv metadata file containing your sample names in the first column and their subtypes in the second:
  
   <img width="135" alt="Screenshot 2025-06-30 at 2 59 59 PM" src="https://github.com/user-attachments/assets/e6680572-b244-40ec-96ff-3ceac260011a" />

   It's important that this file is in .csv format (not .tsv or .xls). The subtype values can be "H1N1", "H3N2", or "IBV".

2. Download and open the nextflow template file ("flu_ngs.nf") to change any parameters that you want to alter before you run the pipeline:
   
   <img width="745" alt="Screenshot 2025-06-30 at 3 01 06 PM" src="https://github.com/user-attachments/assets/75553f56-0b66-4603-8b7f-c0a243375408" />

    The first section of the file contains the editable parameters that you may want to change. (For example: the path to your project directory, the name of your .csv file, the locations of reference sequences, thresholds for variant-calling, and the versions of different softwares used in the pipeline). You can also specify these parameters on the command line when you run the pipeline (see: **Running the pipeline**). 

# Moving files to the biocluster

1. Open an sftp connection in a new terminal tab or window:
   
   ```
   sftp yournetid@biologin3.igb.illinois.edu
   ```
   
2. Transfer your metadata file and nextflow pipeline file from your computer's local environment to your project directory on the biocluster:
   
   ```
   put /Users/username/wherever/you/put/sampleinfo.csv /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder
   put /Users/username/wherever/you/put/flu_ngs.nf /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder
   ```
   
3. Close the sftp connection:
   
   ```
   exit
   ```

# Running the pipeline

(If you have more than a handful of samples, see: **Running nextflow with SLURM**)

1. Inside your project folder on the biocluster, load nextflow:
   
   ```
   module load nextflow/24.10.4-Java-15.0.1
   ```
   
2. Set the directory for the environmental variable NXF_HOME:
   
   ```
   export NXF_HOME=/home/groups/hpcbio_shared/cbrooke_lab/new_project_folder
   ```
   
3. Disable network checking:
   
   ```
   export NXF_DISABLE_CHECK_LATEST=true
   ```
   
4. Enable module swapping:
   
   ```
   export LMOD_DISABLE_SAME_NAME_AUTOSWAP="no"
   ```
   
5. You're ready to run the pipeline! This can be done with:
   
   ```
   nextflow run flu_ngs.nf
   ```

    If you didn't edit the parameters in the nextflow file, you can also specify them in this command using tags. For example, if you wanted to specify the locations of your project folder and your metadata file, you could use the command:
   
   ```
   nextflow run flu_ngs.nf --projectPath /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder --metaPath /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder/mysampleinfo.csv
   ```
   
    If you don't specify any parameters using tags on the command line, their values will default to the ones provided in the first section of the nextflow file. 
   
    The commands above run the pipeline directly from your terminal window, which will give you progress updates as each step is completed:

      <img width="573" alt="Screenshot 2025-06-30 at 3 11 37 PM" src="https://github.com/user-attachments/assets/768e9a6a-6332-472e-bd76-572e9b4b0ba2" />

    Running the pipeline this way means that the run will terminate when you exit the terminal window or shut off your computer. If you have a lot of samples, it may be easier to run the pipeline using a SLURM script instead (see: **Running nextflow with SLURM**).

# Exiting the biocluster and transferring your results to your computer's local environment

1. Sign out of your compute node:
   
   ```
   exit
   ```
   
2. Sign off from the biocluster:
   
   ```
   exit
   ```
   
3. Open an sftp connection:
   
   ```
   sftp yournetid@biologin3.igb.illinois.edu
   ```
   
4. Download depth statistics:
   
   ```
   get /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder/depth_stats/*.tsv /Users/username/your/download/folder
   ```
   
5. Download consensus sequences:
   
   ```
   get /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder/consensus/*.fa /Users/username/your/download/folder
   ```
   
6. Download annotated variant tables:
   
   ```
   get /home/groups/hpcbio_shared/cbrooke_lab/new_project_folder/variants/*.tsv /Users/username/your/download/folder
   ```

# Running nextflow with SLURM

Using a SLURM script (instead of running a command directly from the terminal) allows you to run long jobs without having to keep your terminal open and your computer on.

1. Download the provided SLURM template ("flu_ngs_slurm.txt").
   
2. Enter your email after "#SBATCH --mail-user" (you will get emailed updates when your job starts running and when it ends).
   
3. Enter your project directory after "SBATCH -D".
   
4. Under "#-----Commands-----", type the same nextflow run command that you would otherwise enter into the terminal.
   
5. Within your project directory, create a new script file:
   
   ```
   nano run_nextflow.sh
   ```
6. Paste the text of flu_ngs_slurm.txt into the window that opens.
    
7. Type ctrl-o to save the script, and hit enter.
    
8. Type ctrl-x to exit the script editor.
    
9. You can now run your script with:
   
   ```
   sbatch run_nextflow.sh
   ```
   
10. You can see how long your script has been running with:
   
      ```
      squeue -u yournetid
      ```
   
11. When your run completes (or if it fails), an email notification will be sent to the address you provided. 

# Customizing your run

By default, the pipeline outputs consensus sequences, per-nucleotide depth statistics, and variant calls for each sample. If you want to omit any of these steps, you can change the values of the parameters "params.callConsensus", "params.callDepth", or "params.callVariants" from 'TRUE' to 'FALSE' in the template nextflow file. You can also make these changes from the command line; for example:

```
nextflow run flu_ngs.nf --callVariants FALSE
```     
