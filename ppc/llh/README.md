# To run the flasher fits on perturbed ice models.

script llh.sh sets up the required ice configuration files and flasher data to run ppc and calculate the llh for a perturbed icemodel.
./llh.sh 0 {perturbed_icemodel_data_file} {string to flash} {lowest DOM to flash} {Highest DOM to flash} {/path/to/perturbed/icemodel/}

script setup_fit.sh creates the condor files to run ppc for multiple perturbed icemodels.
./setup_fit.sh {/path/to/all/perturbed/icemodels/directory} {relative path to the Fourier mode models}