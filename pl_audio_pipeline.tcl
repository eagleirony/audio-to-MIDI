
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# audio_pipeline

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xck26-sfvc784-2LV-c
   set_property BOARD_PART xilinx.com:kv260_som:part0:1.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:zynq_ultra_ps_e:3.5\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xfft:9.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:mult_gen:12.0\
xilinx.com:ip:c_addsub:12.0\
xilinx.com:ip:axis_data_fifo:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
audio_pipeline\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set pmod_i2s_lrclk [ create_bd_port -dir O pmod_i2s_lrclk ]
  set pmod_i2s_bclk [ create_bd_port -dir O pmod_i2s_bclk ]
  set pmod_i2s_dout [ create_bd_port -dir I pmod_i2s_dout ]
  set pmod_btn_sw1 [ create_bd_port -dir I pmod_btn_sw1 ]
  set pmod_led_d1 [ create_bd_port -dir O pmod_led_d1 ]
  set pmod_i2s2_dout [ create_bd_port -dir O pmod_i2s2_dout ]
  set pmod_i2s2_lrclk [ create_bd_port -dir O pmod_i2s2_lrclk ]
  set pmod_i2s2_bclk [ create_bd_port -dir I pmod_i2s2_bclk ]

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0 ]
  set_property -dict [list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_MIO_0_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_0_SLEW {slow} \
    CONFIG.PSU_MIO_10_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_10_SLEW {slow} \
    CONFIG.PSU_MIO_11_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_11_SLEW {slow} \
    CONFIG.PSU_MIO_12_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_12_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_12_POLARITY {Default} \
    CONFIG.PSU_MIO_12_SLEW {slow} \
    CONFIG.PSU_MIO_13_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_13_SLEW {slow} \
    CONFIG.PSU_MIO_14_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_14_SLEW {slow} \
    CONFIG.PSU_MIO_15_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_15_SLEW {slow} \
    CONFIG.PSU_MIO_16_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_16_SLEW {slow} \
    CONFIG.PSU_MIO_17_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_17_SLEW {slow} \
    CONFIG.PSU_MIO_18_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_18_SLEW {slow} \
    CONFIG.PSU_MIO_19_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_19_SLEW {slow} \
    CONFIG.PSU_MIO_1_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_1_SLEW {slow} \
    CONFIG.PSU_MIO_20_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_20_SLEW {slow} \
    CONFIG.PSU_MIO_21_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_21_SLEW {slow} \
    CONFIG.PSU_MIO_22_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_22_SLEW {slow} \
    CONFIG.PSU_MIO_23_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_23_POLARITY {Default} \
    CONFIG.PSU_MIO_23_SLEW {slow} \
    CONFIG.PSU_MIO_24_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_24_SLEW {slow} \
    CONFIG.PSU_MIO_25_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_25_SLEW {slow} \
    CONFIG.PSU_MIO_27_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_27_POLARITY {Default} \
    CONFIG.PSU_MIO_27_SLEW {slow} \
    CONFIG.PSU_MIO_28_POLARITY {Default} \
    CONFIG.PSU_MIO_29_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_29_POLARITY {Default} \
    CONFIG.PSU_MIO_29_SLEW {slow} \
    CONFIG.PSU_MIO_2_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_2_SLEW {slow} \
    CONFIG.PSU_MIO_30_POLARITY {Default} \
    CONFIG.PSU_MIO_32_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_32_POLARITY {Default} \
    CONFIG.PSU_MIO_32_SLEW {slow} \
    CONFIG.PSU_MIO_33_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_33_POLARITY {Default} \
    CONFIG.PSU_MIO_33_SLEW {slow} \
    CONFIG.PSU_MIO_34_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_34_POLARITY {Default} \
    CONFIG.PSU_MIO_34_SLEW {slow} \
    CONFIG.PSU_MIO_35_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_35_SLEW {slow} \
    CONFIG.PSU_MIO_36_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_36_SLEW {slow} \
    CONFIG.PSU_MIO_38_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_38_POLARITY {Default} \
    CONFIG.PSU_MIO_38_SLEW {slow} \
    CONFIG.PSU_MIO_39_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_39_SLEW {slow} \
    CONFIG.PSU_MIO_3_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_3_SLEW {slow} \
    CONFIG.PSU_MIO_40_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_40_SLEW {slow} \
    CONFIG.PSU_MIO_41_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_41_SLEW {slow} \
    CONFIG.PSU_MIO_42_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_42_SLEW {slow} \
    CONFIG.PSU_MIO_43_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_43_POLARITY {Default} \
    CONFIG.PSU_MIO_43_SLEW {slow} \
    CONFIG.PSU_MIO_44_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_44_POLARITY {Default} \
    CONFIG.PSU_MIO_44_SLEW {slow} \
    CONFIG.PSU_MIO_45_POLARITY {Default} \
    CONFIG.PSU_MIO_46_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_46_SLEW {slow} \
    CONFIG.PSU_MIO_47_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_47_SLEW {slow} \
    CONFIG.PSU_MIO_48_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_48_SLEW {slow} \
    CONFIG.PSU_MIO_49_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_49_SLEW {slow} \
    CONFIG.PSU_MIO_4_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_4_SLEW {slow} \
    CONFIG.PSU_MIO_50_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_50_SLEW {slow} \
    CONFIG.PSU_MIO_51_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_51_SLEW {slow} \
    CONFIG.PSU_MIO_54_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_54_SLEW {slow} \
    CONFIG.PSU_MIO_56_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_56_SLEW {slow} \
    CONFIG.PSU_MIO_57_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_57_SLEW {slow} \
    CONFIG.PSU_MIO_58_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_58_SLEW {slow} \
    CONFIG.PSU_MIO_59_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_59_SLEW {slow} \
    CONFIG.PSU_MIO_5_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_5_SLEW {slow} \
    CONFIG.PSU_MIO_60_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_60_SLEW {slow} \
    CONFIG.PSU_MIO_61_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_61_SLEW {slow} \
    CONFIG.PSU_MIO_62_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_62_SLEW {slow} \
    CONFIG.PSU_MIO_63_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_63_SLEW {slow} \
    CONFIG.PSU_MIO_64_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_64_SLEW {slow} \
    CONFIG.PSU_MIO_65_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_65_SLEW {slow} \
    CONFIG.PSU_MIO_66_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_66_SLEW {slow} \
    CONFIG.PSU_MIO_67_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_67_SLEW {slow} \
    CONFIG.PSU_MIO_68_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_68_SLEW {slow} \
    CONFIG.PSU_MIO_69_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_69_SLEW {slow} \
    CONFIG.PSU_MIO_6_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_6_SLEW {slow} \
    CONFIG.PSU_MIO_76_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_76_SLEW {slow} \
    CONFIG.PSU_MIO_77_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_77_SLEW {slow} \
    CONFIG.PSU_MIO_7_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_7_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_7_POLARITY {Default} \
    CONFIG.PSU_MIO_7_SLEW {slow} \
    CONFIG.PSU_MIO_8_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_8_POLARITY {Default} \
    CONFIG.PSU_MIO_8_SLEW {slow} \
    CONFIG.PSU_MIO_9_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_9_SLEW {slow} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#SPI 1#GPIO0 MIO#GPIO0 MIO#SPI 1#SPI 1#SPI 1#GPIO0 MIO#SD 0#SD 0#SD 0#SD 0#SD\
0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO0 MIO#I2C 1#I2C 1#PMU GPI 0#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PMU GPI 5#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PMU GPO 3#UART 1#UART 1#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#GPIO1 MIO#GPIO1\
MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1##########################} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#sclk_out#gpio0[7]#gpio0[8]#n_ss_out[0]#miso#mosi#gpio0[12]#sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out#gpio0[23]#scl_out#sda_out#gpi[0]#gpio1[27]#gpio1[28]#gpio1[29]#gpio1[30]#gpi[5]#gpio1[32]#gpio1[33]#gpio1[34]#gpo[3]#txd#rxd#gpio1[38]#sdio1_data_out[4]#sdio1_data_out[5]#sdio1_data_out[6]#sdio1_data_out[7]#gpio1[43]#gpio1[44]#gpio1[45]#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out##########################}\
\
    CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
    CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {8} \
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1066.656006} \
    CONFIG.PSU__AFI0_COHERENCY {0} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1333.333008} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1333.333} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__ACPU__FRAC_ENABLED {1} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__FRACFREQ {1333.333} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {1} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {444.444336} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {533.333} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.984985} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498123} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.998749} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {199.998001} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {199.998001} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {187.498123} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {1} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
    CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
    CONFIG.PSU__DDRC__CL {16} \
    CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
    CONFIG.PSU__DDRC__COMPONENTS {Components} \
    CONFIG.PSU__DDRC__CWL {14} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
    CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
    CONFIG.PSU__DDRC__ECC {Disabled} \
    CONFIG.PSU__DDRC__FGRM {1X} \
    CONFIG.PSU__DDRC__LP_ASR {manual normal} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
    CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
    CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
    CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400R} \
    CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
    CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
    CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {33} \
    CONFIG.PSU__DDRC__T_RC {47.06} \
    CONFIG.PSU__DDRC__T_RCD {16} \
    CONFIG.PSU__DDRC__T_RP {16} \
    CONFIG.PSU__DDRC__VREF {1} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
    CONFIG.PSU__DLL__ISUSED {1} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__FPGA_PL1_ENABLE {1} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 24 .. 25} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PL_CLK1_BUF {TRUE} \
    CONFIG.PSU__PMU_COHERENCY {0} \
    CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
    CONFIG.PSU__PMU__GPI0__ENABLE {1} \
    CONFIG.PSU__PMU__GPI0__IO {MIO 26} \
    CONFIG.PSU__PMU__GPI1__ENABLE {0} \
    CONFIG.PSU__PMU__GPI2__ENABLE {0} \
    CONFIG.PSU__PMU__GPI3__ENABLE {0} \
    CONFIG.PSU__PMU__GPI4__ENABLE {0} \
    CONFIG.PSU__PMU__GPI5__ENABLE {1} \
    CONFIG.PSU__PMU__GPI5__IO {MIO 31} \
    CONFIG.PSU__PMU__GPO0__ENABLE {0} \
    CONFIG.PSU__PMU__GPO1__ENABLE {0} \
    CONFIG.PSU__PMU__GPO2__ENABLE {0} \
    CONFIG.PSU__PMU__GPO3__ENABLE {1} \
    CONFIG.PSU__PMU__GPO3__IO {MIO 35} \
    CONFIG.PSU__PMU__GPO3__POLARITY {low} \
    CONFIG.PSU__PMU__GPO4__ENABLE {0} \
    CONFIG.PSU__PMU__GPO5__ENABLE {0} \
    CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;0|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;1|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;1|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;0|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;0|LPD;USB3_0;FF9D0000;FF9DFFFF;0|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;1|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;0|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;0|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
    CONFIG.PSU__SAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__SD0_COHERENCY {0} \
    CONFIG.PSU__SD0_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD0__CLK_100_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD0__CLK_200_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD0__CLK_50_DDR_ITAP_DLY {0x3D} \
    CONFIG.PSU__SD0__CLK_50_DDR_OTAP_DLY {0x4} \
    CONFIG.PSU__SD0__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD0__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
    CONFIG.PSU__SD0__GRP_CD__ENABLE {0} \
    CONFIG.PSU__SD0__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD0__GRP_WP__ENABLE {0} \
    CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
    CONFIG.PSU__SD0__SLOT_TYPE {SD 3.0} \
    CONFIG.PSU__SD1_COHERENCY {0} \
    CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD1__CLK_100_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_200_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_50_DDR_ITAP_DLY {0x3D} \
    CONFIG.PSU__SD1__CLK_50_DDR_OTAP_DLY {0x4} \
    CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {8Bit} \
    CONFIG.PSU__SD1__GRP_CD__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 39 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 3.0} \
    CONFIG.PSU__SPI1__GRP_SS0__IO {MIO 9} \
    CONFIG.PSU__SPI1__GRP_SS1__ENABLE {0} \
    CONFIG.PSU__SPI1__GRP_SS2__ENABLE {0} \
    CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SPI1__PERIPHERAL__IO {MIO 6 .. 11} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {EMIO} \
    CONFIG.PSU__UART1__BAUD_RATE {115200} \
    CONFIG.PSU__UART1__MODEM__ENABLE {0} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 36 .. 37} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__M_AXI_GP0 {1} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP0 {1} \
    CONFIG.PSU__USE__S_AXI_GP1 {0} \
  ] $zynq_ultra_ps_e_0


  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_include_mm2s {1} \
    CONFIG.c_include_sg {0} \
  ] $axi_dma_0


  # Create instance: audio_pipeline_0, and set properties
  set block_name audio_pipeline
  set block_cell_name audio_pipeline_0
  if { [catch {set audio_pipeline_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $audio_pipeline_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: ps8_0_axi_periph, and set properties
  set ps8_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_axi_periph ]
  set_property CONFIG.NUM_MI {3} $ps8_0_axi_periph


  # Create instance: rst_ps8_0_99M, and set properties
  set rst_ps8_0_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_99M ]

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
  ] $axi_smc


  # Create instance: xfft_0, and set properties
  set xfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 xfft_0 ]
  set_property -dict [list \
    CONFIG.aresetn {true} \
    CONFIG.implementation_options {pipelined_streaming_io} \
    CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {4} \
    CONFIG.output_ordering {natural_order} \
    CONFIG.target_clock_frequency {100} \
    CONFIG.target_data_throughput {50} \
    CONFIG.transform_length {2048} \
  ] $xfft_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {2} \
    CONFIG.IN1_WIDTH {2} \
    CONFIG.IN2_WIDTH {2} \
    CONFIG.IN3_WIDTH {2} \
    CONFIG.IN4_WIDTH {2} \
    CONFIG.IN5_WIDTH {2} \
    CONFIG.NUM_PORTS {6} \
  ] $xlconcat_1


  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property CONFIG.CONST_WIDTH {2} $xlconstant_2


  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {2} \
    CONFIG.CONST_WIDTH {2} \
  ] $xlconstant_3


  # Create instance: xlconstant_4, and set properties
  set xlconstant_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_4 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {3} \
    CONFIG.CONST_WIDTH {2} \
  ] $xlconstant_4


  # Create instance: xlconcat_2, and set properties
  set xlconcat_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_2 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {3} \
    CONFIG.IN1_WIDTH {12} \
    CONFIG.NUM_PORTS {3} \
  ] $xlconcat_2


  # Create instance: xlconstant_5, and set properties
  set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {3} \
  ] $xlconstant_5


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {16} \
  ] $xlslice_1


  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property CONFIG.DIN_FROM {15} $xlslice_2


  # Create instance: mult_gen_0, and set properties
  set mult_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_0 ]
  set_property -dict [list \
    CONFIG.PipeStages {0} \
    CONFIG.PortAWidth {16} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_0


  # Create instance: mult_gen_1, and set properties
  set mult_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_1 ]
  set_property -dict [list \
    CONFIG.Multiplier_Construction {Use_LUTs} \
    CONFIG.PipeStages {0} \
    CONFIG.PortAWidth {16} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_1


  # Create instance: c_addsub_0, and set properties
  set c_addsub_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 c_addsub_0 ]
  set_property -dict [list \
    CONFIG.A_Width {32} \
    CONFIG.B_Constant {false} \
    CONFIG.B_Value {00000000000000000000000000000000} \
    CONFIG.B_Width {32} \
    CONFIG.CE {false} \
    CONFIG.Latency {0} \
    CONFIG.Out_Width {32} \
  ] $c_addsub_0


  # Create instance: xlconcat_3, and set properties
  set xlconcat_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_3 ]
  set_property CONFIG.NUM_PORTS {6} $xlconcat_3


  # Create instance: axis_interconnect_0, and set properties
  set axis_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_0 ]
  set_property -dict [list \
    CONFIG.ARB_ON_TLAST {0} \
    CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
    CONFIG.M00_FIFO_DEPTH {2048} \
    CONFIG.M00_FIFO_MODE {1} \
    CONFIG.M01_FIFO_DEPTH {2048} \
    CONFIG.M01_FIFO_MODE {1} \
    CONFIG.ROUTING_MODE {0} \
    CONFIG.S00_FIFO_MODE {1} \
  ] $axis_interconnect_0


  # Create instance: axis_interconnect_1, and set properties
  set axis_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_1 ]
  set_property -dict [list \
    CONFIG.ARB_ON_TLAST {0} \
    CONFIG.M00_AXIS_HIGHTDEST {0x00000001} \
    CONFIG.M00_FIFO_DEPTH {2048} \
    CONFIG.M00_FIFO_MODE {1} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
    CONFIG.S00_FIFO_DEPTH {2048} \
    CONFIG.S00_FIFO_MODE {1} \
    CONFIG.S01_FIFO_DEPTH {2048} \
    CONFIG.S01_FIFO_MODE {1} \
  ] $axis_interconnect_1


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {64} \
    CONFIG.FIFO_MODE {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.TDATA_NUM_BYTES {4} \
  ] $axis_data_fifo_0


  # Create interface connections
  connect_bd_intf_net -intf_net S01_AXIS_1 [get_bd_intf_pins axis_interconnect_1/S01_AXIS] [get_bd_intf_pins axis_interconnect_0/M01_AXIS]
  connect_bd_intf_net -intf_net audio_pipeline_0_axis_o [get_bd_intf_pins audio_pipeline_0/axis_o] [get_bd_intf_pins axis_interconnect_0/S00_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins audio_pipeline_0/axis_i]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_smc/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins axis_interconnect_1/S00_AXIS]
  connect_bd_intf_net -intf_net axis_interconnect_0_M00_AXIS [get_bd_intf_pins axis_interconnect_0/M00_AXIS] [get_bd_intf_pins xfft_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_interconnect_1_M00_AXIS [get_bd_intf_pins axis_interconnect_1/M00_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins ps8_0_axi_periph/M00_AXI] [get_bd_intf_pins audio_pipeline_0/s00_axi]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins ps8_0_axi_periph/M01_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_FPD [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] [get_bd_intf_pins ps8_0_axi_periph/S00_AXI]

  # Create port connections
  connect_bd_net -net audio_pipeline_0_i2s2_dout [get_bd_pins audio_pipeline_0/i2s2_dout] [get_bd_ports pmod_i2s2_dout]
  connect_bd_net -net audio_pipeline_0_i2s_bclk [get_bd_pins audio_pipeline_0/i2s_bclk] [get_bd_ports pmod_i2s_bclk]
  connect_bd_net -net audio_pipeline_0_i2s_lrcl [get_bd_pins audio_pipeline_0/i2s_lrcl] [get_bd_ports pmod_i2s_lrclk]
  connect_bd_net -net audio_pipeline_0_pmod_led_d1 [get_bd_pins audio_pipeline_0/pmod_led_d1] [get_bd_ports pmod_led_d1]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready [get_bd_pins axis_data_fifo_0/s_axis_tready] [get_bd_pins xfft_0/m_axis_data_tready]
  connect_bd_net -net c_addsub_0_S [get_bd_pins c_addsub_0/S] [get_bd_pins axis_data_fifo_0/s_axis_tdata]
  connect_bd_net -net mult_gen_0_P [get_bd_pins mult_gen_0/P] [get_bd_pins c_addsub_0/A]
  connect_bd_net -net mult_gen_1_P [get_bd_pins mult_gen_1/P] [get_bd_pins c_addsub_0/B]
  connect_bd_net -net pmod_btn_sw1_1 [get_bd_ports pmod_btn_sw1] [get_bd_pins audio_pipeline_0/btn_in]
  connect_bd_net -net pmod_i2s2_bclk_1 [get_bd_ports pmod_i2s2_bclk] [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_rxd]
  connect_bd_net -net pmod_i2s_dout_1 [get_bd_ports pmod_i2s_dout] [get_bd_pins audio_pipeline_0/i2s_dout]
  connect_bd_net -net rst_ps8_0_99M_peripheral_aresetn [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins ps8_0_axi_periph/S00_ARESETN] [get_bd_pins ps8_0_axi_periph/M00_ARESETN] [get_bd_pins ps8_0_axi_periph/ARESETN] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins ps8_0_axi_periph/M01_ARESETN] [get_bd_pins axi_smc/aresetn] [get_bd_pins ps8_0_axi_periph/M02_ARESETN] [get_bd_pins xfft_0/aresetn] [get_bd_pins axis_interconnect_0/ARESETN] [get_bd_pins axis_interconnect_0/S00_AXIS_ARESETN] [get_bd_pins axis_interconnect_0/M00_AXIS_ARESETN] [get_bd_pins axis_interconnect_0/M01_AXIS_ARESETN] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_interconnect_1/ARESETN] [get_bd_pins axis_interconnect_1/S00_AXIS_ARESETN] [get_bd_pins axis_interconnect_1/M00_AXIS_ARESETN] [get_bd_pins axis_interconnect_1/S01_AXIS_ARESETN] [get_bd_pins audio_pipeline_0/rst] [get_bd_pins audio_pipeline_0/s00_axi_aresetn]
  connect_bd_net -net xfft_0_event_data_in_channel_halt [get_bd_pins xfft_0/event_data_in_channel_halt] [get_bd_pins xlconcat_3/In4]
  connect_bd_net -net xfft_0_event_data_out_channel_halt [get_bd_pins xfft_0/event_data_out_channel_halt] [get_bd_pins xlconcat_3/In5]
  connect_bd_net -net xfft_0_event_frame_started [get_bd_pins xfft_0/event_frame_started] [get_bd_pins xlconcat_3/In0]
  connect_bd_net -net xfft_0_event_status_channel_halt [get_bd_pins xfft_0/event_status_channel_halt] [get_bd_pins xlconcat_3/In3]
  connect_bd_net -net xfft_0_event_tlast_missing [get_bd_pins xfft_0/event_tlast_missing] [get_bd_pins xlconcat_3/In2]
  connect_bd_net -net xfft_0_event_tlast_unexpected [get_bd_pins xfft_0/event_tlast_unexpected] [get_bd_pins xlconcat_3/In1]
  connect_bd_net -net xfft_0_m_axis_data_tdata [get_bd_pins xfft_0/m_axis_data_tdata] [get_bd_pins xlslice_1/Din] [get_bd_pins xlslice_2/Din]
  connect_bd_net -net xfft_0_m_axis_data_tlast [get_bd_pins xfft_0/m_axis_data_tlast] [get_bd_pins axis_data_fifo_0/s_axis_tlast]
  connect_bd_net -net xfft_0_m_axis_data_tvalid [get_bd_pins xfft_0/m_axis_data_tvalid] [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins xlconcat_1/dout] [get_bd_pins xlconcat_2/In1]
  connect_bd_net -net xlconcat_2_dout [get_bd_pins xlconcat_2/dout] [get_bd_pins xfft_0/s_axis_config_tdata]
  connect_bd_net -net xlconcat_3_dout [get_bd_pins xlconcat_3/dout] [get_bd_pins audio_pipeline_0/xfft_event]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins xfft_0/s_axis_config_tvalid] [get_bd_pins xlconcat_2/In2]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconstant_2/dout] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net xlconstant_3_dout [get_bd_pins xlconstant_3/dout] [get_bd_pins xlconcat_1/In1] [get_bd_pins xlconcat_1/In2] [get_bd_pins xlconcat_1/In3] [get_bd_pins xlconcat_1/In4]
  connect_bd_net -net xlconstant_4_dout [get_bd_pins xlconstant_4/dout] [get_bd_pins xlconcat_1/In5]
  connect_bd_net -net xlconstant_5_dout [get_bd_pins xlconstant_5/dout] [get_bd_pins xlconcat_2/In0]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins xlslice_1/Dout] [get_bd_pins mult_gen_0/A] [get_bd_pins mult_gen_0/B]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins xlslice_2/Dout] [get_bd_pins mult_gen_1/A] [get_bd_pins mult_gen_1/B]
  connect_bd_net -net zynq_ultra_ps_e_0_emio_uart0_txd [get_bd_pins zynq_ultra_ps_e_0/emio_uart0_txd] [get_bd_ports pmod_i2s2_lrclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins ps8_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps8_0_99M/slowest_sync_clk] [get_bd_pins ps8_0_axi_periph/M00_ACLK] [get_bd_pins ps8_0_axi_periph/ACLK] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins ps8_0_axi_periph/M01_ACLK] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihpc0_fpd_aclk] [get_bd_pins ps8_0_axi_periph/M02_ACLK] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins xfft_0/aclk] [get_bd_pins axis_interconnect_0/S00_AXIS_ACLK] [get_bd_pins axis_interconnect_0/ACLK] [get_bd_pins axis_interconnect_0/M00_AXIS_ACLK] [get_bd_pins axis_interconnect_0/M01_AXIS_ACLK] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_interconnect_1/S01_AXIS_ACLK] [get_bd_pins axis_interconnect_1/M00_AXIS_ACLK] [get_bd_pins axis_interconnect_1/S00_AXIS_ACLK] [get_bd_pins axis_interconnect_1/ACLK] [get_bd_pins audio_pipeline_0/clk] [get_bd_pins audio_pipeline_0/s00_axi_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_ps8_0_99M/ext_reset_in]

  # Create address segments
  assign_bd_address -offset 0xA0000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs audio_pipeline_0/s00_axi/reg0] -force
  assign_bd_address -offset 0xA0010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_QSPI] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM]
  exclude_bd_addr_seg -offset 0x000800000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP0/HPC0_LPS_OCM]

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_Layers":"/zynq_ultra_ps_e_0_pl_clk0:true|/c_addsub_0_S:true|/xfft_0_event_tlast_missing:true|/xfft_0_event_data_in_channel_halt:true|/zynq_ultra_ps_e_0_pl_resetn0:true|/xfft_0_event_frame_started:true|/xfft_0_event_tlast_unexpected:true|/rst_ps8_0_99M_peripheral_aresetn:true|/xfft_0_event_status_channel_halt:true|/xfft_0_event_data_out_channel_halt:true|/mult_gen_0_P:true|/mult_gen_1_P:true|",
   "Default View_ScaleFactor":"0.709924",
   "Default View_TopLeft":"1875,62",
   "Display-PortTypeClock":"true",
   "Display-PortTypeData":"true",
   "Display-PortTypeInterrupt":"true",
   "Display-PortTypeOthers":"true",
   "Display-PortTypeReset":"true",
   "ExpandedHierarchyInLayout":"",
   "Grouping and No Loops_ScaleFactor":"0.264477",
   "Grouping and No Loops_TopLeft":"-155,-276",
   "Interfaces View_Layers":"/zynq_ultra_ps_e_0_pl_clk0:false|/c_addsub_0_S:false|/xfft_0_event_tlast_missing:false|/xfft_0_event_data_in_channel_halt:false|/zynq_ultra_ps_e_0_pl_resetn0:false|/xfft_0_event_frame_started:false|/xfft_0_event_tlast_unexpected:false|/rst_ps8_0_99M_peripheral_aresetn:false|/xfft_0_event_status_channel_halt:false|/xfft_0_event_data_out_channel_halt:false|/mult_gen_0_P:false|/mult_gen_1_P:false|",
   "Interfaces View_ScaleFactor":"0.378947",
   "Interfaces View_TopLeft":"-153,-525",
   "guistr":"# # String gsaved with Nlview 7.7.1 2023-07-26 3bc4126617 VDI=43 GEI=38 GUI=JA:21.0
#  -string -flagsOSRD
preplace port port-id_pmod_i2s_lrclk -pg 1 -lvl 12 -x 4240 -y 60 -defaultsOSRD
preplace port port-id_pmod_i2s_bclk -pg 1 -lvl 12 -x 4240 -y 20 -defaultsOSRD
preplace port port-id_pmod_i2s_dout -pg 1 -lvl 0 -x 0 -y 230 -defaultsOSRD
preplace port port-id_pmod_btn_sw1 -pg 1 -lvl 0 -x 0 -y 310 -defaultsOSRD
preplace port port-id_pmod_led_d1 -pg 1 -lvl 12 -x 4240 -y 80 -defaultsOSRD
preplace port port-id_pmod_i2s2_dout -pg 1 -lvl 12 -x 4240 -y 40 -defaultsOSRD
preplace port port-id_pmod_i2s2_lrclk -pg 1 -lvl 12 -x 4240 -y 190 -defaultsOSRD
preplace port port-id_pmod_i2s2_bclk -pg 1 -lvl 0 -x 0 -y 990 -defaultsOSRD
preplace inst zynq_ultra_ps_e_0 -pg 1 -lvl 11 -x 3880 -y 210 -defaultsOSRD
preplace inst axi_dma_0 -pg 1 -lvl 9 -x 3080 -y 220 -defaultsOSRD
preplace inst audio_pipeline_0 -pg 1 -lvl 1 -x 210 -y 230 -defaultsOSRD
preplace inst ps8_0_axi_periph -pg 1 -lvl 5 -x 1830 -y 560 -swap {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 116 113 117 114 118 119 122 115 120 121} -defaultsOSRD
preplace inst rst_ps8_0_99M -pg 1 -lvl 4 -x 1450 -y 800 -defaultsOSRD
preplace inst axi_smc -pg 1 -lvl 10 -x 3430 -y 180 -defaultsOSRD
preplace inst xfft_0 -pg 1 -lvl 3 -x 1020 -y 560 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 1 -x 210 -y 530 -defaultsOSRD
preplace inst xlconcat_1 -pg 1 -lvl 2 -x 600 -y 940 -defaultsOSRD
preplace inst xlconstant_2 -pg 1 -lvl 1 -x 210 -y 730 -defaultsOSRD
preplace inst xlconstant_3 -pg 1 -lvl 1 -x 210 -y 830 -defaultsOSRD
preplace inst xlconstant_4 -pg 1 -lvl 1 -x 210 -y 930 -defaultsOSRD
preplace inst xlconcat_2 -pg 1 -lvl 2 -x 600 -y 750 -defaultsOSRD
preplace inst xlconstant_5 -pg 1 -lvl 1 -x 210 -y 630 -defaultsOSRD
preplace inst xlslice_1 -pg 1 -lvl 4 -x 1450 -y 220 -defaultsOSRD
preplace inst xlslice_2 -pg 1 -lvl 4 -x 1450 -y 320 -defaultsOSRD
preplace inst mult_gen_0 -pg 1 -lvl 5 -x 1830 -y 150 -defaultsOSRD
preplace inst mult_gen_1 -pg 1 -lvl 5 -x 1830 -y 290 -defaultsOSRD
preplace inst c_addsub_0 -pg 1 -lvl 6 -x 2100 -y 280 -defaultsOSRD
preplace inst xlconcat_3 -pg 1 -lvl 4 -x 1450 -y 610 -defaultsOSRD
preplace inst axis_interconnect_0 -pg 1 -lvl 2 -x 600 -y 460 -swap {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 21 17 22 18 23 19 24 20} -defaultsOSRD
preplace inst axis_interconnect_1 -pg 1 -lvl 8 -x 2710 -y 420 -defaultsOSRD
preplace inst axis_data_fifo_0 -pg 1 -lvl 7 -x 2380 -y 260 -defaultsOSRD
preplace netloc audio_pipeline_0_i2s2_dout 1 1 11 400 30 N 30 N 30 N 30 N 30 N 30 N 30 N 30 3280 40 N 40 N
preplace netloc audio_pipeline_0_i2s_bclk 1 1 11 360 10 N 10 N 10 N 10 N 10 N 10 N 10 N 10 N 10 N 10 4220
preplace netloc audio_pipeline_0_i2s_lrcl 1 1 11 380 20 N 20 N 20 N 20 N 20 N 20 N 20 N 20 3290 50 N 50 4220
preplace netloc audio_pipeline_0_pmod_led_d1 1 1 11 410 40 N 40 N 40 N 40 N 40 N 40 N 40 N 40 3260 60 N 60 4210
preplace netloc mult_gen_0_P 1 5 1 1990 150n
preplace netloc mult_gen_1_P 1 5 1 N 290
preplace netloc pmod_btn_sw1_1 1 0 1 NJ 310
preplace netloc pmod_i2s2_bclk_1 1 0 12 NJ 990 360J 1050 NJ 1050 NJ 1050 N 1050 N 1050 N 1050 N 1050 N 1050 N 1050 N 1050 4190
preplace netloc pmod_i2s_dout_1 1 0 1 NJ 230
preplace netloc rst_ps8_0_99M_peripheral_aresetn 1 0 10 50 80 440 270 780 390 N 390 1640 380 N 380 2210 390 2520 190 2900 100 3260
preplace netloc xfft_0_event_data_in_channel_halt 1 3 1 NJ 640
preplace netloc xfft_0_event_data_out_channel_halt 1 3 1 NJ 660
preplace netloc xfft_0_event_frame_started 1 3 1 N 560
preplace netloc xfft_0_event_status_channel_halt 1 3 1 NJ 620
preplace netloc xfft_0_event_tlast_missing 1 3 1 N 600
preplace netloc xfft_0_event_tlast_unexpected 1 3 1 N 580
preplace netloc xfft_0_m_axis_data_tdata 1 3 1 1240 220n
preplace netloc xlconcat_1_dout 1 1 2 440 670 760
preplace netloc xlconcat_2_dout 1 2 1 790 550n
preplace netloc xlconcat_3_dout 1 0 5 40 70 N 70 N 70 N 70 1620
preplace netloc xlconstant_1_dout 1 1 2 410 660 800
preplace netloc xlconstant_2_dout 1 1 1 390J 730n
preplace netloc xlconstant_3_dout 1 1 1 380 830n
preplace netloc xlconstant_4_dout 1 1 1 370J 930n
preplace netloc xlconstant_5_dout 1 1 1 400 630n
preplace netloc xlslice_1_Dout 1 4 1 1660 140n
preplace netloc xlslice_2_Dout 1 4 1 1660 280n
preplace netloc zynq_ultra_ps_e_0_emio_uart0_txd 1 11 1 N 190
preplace netloc zynq_ultra_ps_e_0_pl_clk0 1 0 12 60 90 420 650 810 760 1240J 900 1660 370 N 370 2240 400 2540 200 2890 90 3290 90 3570 90 4220
preplace netloc zynq_ultra_ps_e_0_pl_resetn0 1 3 9 1280 80 N 80 N 80 N 80 N 80 N 80 N 80 N 80 4200
preplace netloc c_addsub_0_S 1 6 1 2190 220n
preplace netloc xfft_0_m_axis_data_tlast 1 3 4 1260 400 1650J 390 NJ 390 2200J
preplace netloc axis_data_fifo_0_s_axis_tready 1 3 4 1250 160 1630J 220 2010J 210 2230J
preplace netloc xfft_0_m_axis_data_tvalid 1 3 4 1270 410 1670J 400 NJ 400 2230J
preplace netloc axi_dma_0_M_AXIS_MM2S 1 0 10 30 60 390 50 N 50 N 50 N 50 N 50 N 50 N 50 N 50 3250
preplace netloc axi_dma_0_M_AXI_MM2S 1 9 1 3270 160n
preplace netloc axi_dma_0_M_AXI_S2MM 1 9 1 3280 150n
preplace netloc axi_smc_M00_AXI 1 10 1 N 180
preplace netloc ps8_0_axi_periph_M00_AXI 1 0 6 20 50 370 60 N 60 N 60 N 60 1980
preplace netloc ps8_0_axi_periph_M01_AXI 1 5 4 2000 140 N 140 N 140 2880
preplace netloc zynq_ultra_ps_e_0_M_AXI_HPM0_FPD 1 4 8 1680 70 N 70 N 70 N 70 N 70 N 70 N 70 4190
preplace netloc axis_interconnect_0_M00_AXIS 1 2 1 770J 450n
preplace netloc audio_pipeline_0_axis_o 1 1 1 430 190n
preplace netloc axis_data_fifo_0_M_AXIS 1 7 1 N 260
preplace netloc S01_AXIS_1 1 2 6 760J 380 NJ 380 1630J 360 NJ 360 2220J 380 2530
preplace netloc axis_interconnect_1_M00_AXIS 1 8 1 2910 190n
levelinfo -pg 1 0 210 600 1020 1450 1830 2100 2380 2710 3080 3430 3880 4240
pagesize -pg 1 -db -bbox -sgen -160 0 4460 1100
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


