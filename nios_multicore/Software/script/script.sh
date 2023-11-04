###############################################################################
# Copyright 2023 Naim Lemar
# Copyright 2020 Igor Semenov and LaCASA@UAH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
###############################################################################/

#!/bin/bash

# Constants for directories and project name
sopc_file="../../Hardware/nios_multicore.sopcinfo"
software_dir="../../Software"
source_dir="$software_dir/source"
project_name="Matrix_Multiplication"

# Function to generate board support packages (BSP) for N cores
generate_bsp() {
    core_count=$1
	
    echo "********** Generating board support packages for $core_count cores **********"
	
    for ((core=0; core<core_count; core++)); do
        core_name="core_$core"

        echo -e "\n\n********** BSP for core $core_name **********\n\n"
		
        bsp_dir="$software_dir/${project_name}_${core_name}_bsp"
        app_dir="$software_dir/${project_name}_${core_name}"
        
		rm -rf "$bsp_dir"
        nios2-bsp hal "$bsp_dir" "$sopc_file" \
						--cpu-name ${core_name}_nios2 \
						--set hal.enable_small_c_library true \
						--set hal.enable_exit false \
						--set hal.enable_c_plus_plus false \
						--set hal.enable_clean_exit false \
						--set hal.enable_sim_optimize false \
						--set hal.enable_reduced_device_drivers true \
						--default_sections_mapping ${core_name}_ram \
						--cmd add_section_mapping .text ${core_name}_rom \
						--cmd add_section_mapping .shared shared_memory

        echo -e "\n\n********** Application for core $core_name **********\n\n"
		
		rm -rf "$app_dir"
        nios2-app-generate-makefile --bsp-dir $bsp_dir \
									--app-dir $app_dir \
									--src-dir $source_dir \
									--set APP_CFLAGS_USER_FLAGS \
									-DCORE_ID=$core \
									-DCORE_COUNT=$core_count       
    done
}

# Function to compile projects for N cores
compile_projects() {
    core_count=$1
	
    echo "********** Compiling projects for $core_count cores **********"
	
    for ((core=0; core<core_count; core++)); do
        core_name="core_$core"
		
        echo -e "\n\n********** Compiling for core $core_name **********\n\n"
		
        app_dir="$software_dir/${project_name}_${core_name}"
		
        (cd "$app_dir" && make)
		
    done
}

# Function to load executable files to N cores
load_elfs() {
    core_count=$1
	
    echo "********** Loading ELFs to $core_count cores **********"
	
    for ((core=core_count-1; core>=0; core--)); do
        core_name="core_$core"
		
        echo -e "\n\n********** Loading code to $core_name **********\n\n"
		
        app_dir="$software_dir/${project_name}_${core_name}"
		
        nios2-download --instance "$core" -g "$app_dir/main.elf"
		
    done
	
    echo -e "\n\n********** Opening terminal for core core_0 **********\n\n"
	
    nios2-terminal --instance 0
}

# Main script execution
case "$1" in
    generate_bsp_files)
        generate_bsp "$2"
        ;;
    compile_projects)
        compile_projects "$2"
        ;;
    load_elf_files)
        load_elfs "$2"
        ;;
    *)
        echo "Please use one of these options: $0 generate_bsp_files|compile_projects|load_elf_files  Number_of_Cores"
        ;;
esac
