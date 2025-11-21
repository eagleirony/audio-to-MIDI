set repo_dir "."

set proj_name "audio_to_midi_project"

create_project ${proj_name} ${repo_dir}/${proj_name} -part xck26-sfvc784-2LV-c

add_files -norecurse ${repo_dir}/audio_pipeline.vhd
add_files -norecurse ${repo_dir}/params.vhd
add_files -norecurse ${repo_dir}/i2s_master.vhd
add_files -norecurse ${repo_dir}/i2s_slave.vhd
add_files -norecurse ${repo_dir}/axis_slave.vhd
add_files -norecurse ${repo_dir}/ctrl_bus.vhd
add_files -norecurse ${repo_dir}/fifo.vhd
add_files -norecurse ${repo_dir}/axis_master.vhd
update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse ${repo_dir}/kria-constraints.xdc
import_files -fileset constrs_1 ${repo_dir}/kria-constraints.xdc

set_property SOURCE_SET sources_1 [get_filesets sim_1]
import_files -fileset sim_1 -norecurse ${repo_dir}/axis_TB.vhd
import_files -fileset sim_1 -norecurse ${repo_dir}/i2s_slave_TB.vhd
import_files -fileset sim_1 -norecurse ${repo_dir}/i2s_master_TB.vhd
update_compile_order -fileset sim_1

source ${repo_dir}/pl_audio_pipeline.tcl
update_compile_order -fileset sources_1

make_wrapper -files [get_files ${repo_dir}/${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${repo_dir}/${proj_name}/${proj_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
update_compile_order -fileset sources_1

set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

launch_runs impl_1 -to_step write_bitstream -jobs 8