# Tooling_for_RVV_Datapah

## Building the docker image
`docker build --secret id=ssh_key,src="$your_ssh_github_key_path" -t docker_for_ax_sim . `

## Executing Ax-Sim inside docker image
### Run AX-sim
`./install-Release/bin/ax-accel-sim   run-elf  --generation EUROPA  axelera/tests/apps/test_conv_identity_pt_struct_ai0`


### Debug Spike/Plugin debug mode (debug spike plugins code e.g dma, datapath, smu, etc.)
`./install-Release/bin/ax-accel-sim --log-level DEBUG run-elf  --generation EUROPA --gdb axelera/tests/apps/test_conv_identity_pt_struct_ai0`

For breakpoints, stepping, register view (&manipulation), memory view (&manipulation) refer to gdb documentation.
Note: This modality won't allow you to debug your elf-executable but just your spike plugins.


### Debug Spike Executable elf (e.g axelera/tests/apps/test_conv_identity_pt_struct_ai0 or other workload)

#### Spike internal debugger
` ./install-Release/bin/ax-accel-sim   run-elf  --spike-args "-d"  --generation EUROPA  axelera/tests/apps/test_conv_identity_pt_struct_ai0`

Use `help` command inside spike interactive mode to see all the availables command.

Limitation: 
-No easy way to perform memory manipulation 
-No easy way to insert source level breakpoint 

#### Debug with gdb

Run spike instance
`./install-Release/bin/ax-accel-sim   run-elf  --spike-args "-H --rbb-port=9824"  --generation EUROPA  axelera/tests/apps/test_conv_identity_pt_struct_ai00`

Run openocd in another docker container terminal 
`openocd -f Tooling_for_RVV_Datapah/openocd0.11_spike.cfg`

Run gdb in another docker container terminal 
`riscv64-unknown-elf-gdb  axelera/tests/apps/test_conv_identity_pt_struct_ai0g`








