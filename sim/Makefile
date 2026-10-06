#=========================================================
# Makefile for UART Verification using QuestaSim
#=========================================================

#=========================================================
# SIMULATOR
#=========================================================

SIMULATOR = Questa

#=========================================================
# WORK LIBRARY
#=========================================================

WORK = work

#=========================================================
# RTL FILES
#=========================================================

RTL = ../rtl/*.v \
      ../rtl/uart_if.sv

#=========================================================
# TESTBENCH FILES
#=========================================================

SVTB = ../test/uart_pkg.sv \
       ../test/top.sv

#=========================================================
# INCLUDE DIRECTORIES
#=========================================================

INC = +incdir+../env \
      +incdir+../env_lib \
      +incdir+../test \
      +incdir+../rtl

#=========================================================
# QUESTA OPTIONS
#=========================================================

VSIMOPT = -vopt -voptargs=+acc

#=========================================================
# BATCH COMMANDS
#=========================================================

VSIMBATCH = -c -do "log -r /*; run -all; quit"

#=========================================================
# HELP
#=========================================================

help:
	@echo "========================================================================"
	@echo " UART Verification Makefile "
	@echo "========================================================================"
	@echo " make clean        	 => Clean generated files"
	@echo " make sv_cmp       	 => Compile RTL and TB"
	@echo " make run_base_test       => Run base_testcase-single_transfer"
	@echo " make run_reset_test      => Run apply reset_testcase"
	@echo " make run_rst_transfer_test => Run apply reset while a transfer is occuring"
	@echo " make run_newd_high       => Run newd_held_high"
	@echo " make run_multi_transfer  => Run multiple_data_transfer"
	@echo " make run_done_sig_test   => Run check the done signals"
	@echo " make run_all_zeroes_test => Run corner_case: all zeroes"
	@echo " make run_all_ones_test   => Run corner_case: all ones"
	@echo "--------------------------------------------------------------------------"
	@echo " make view_wave1   => View base_test waveform"
	@echo " make view_wave2   => View reset_test waveform"
	@echo " make view_wave3   => View rst_transfer_test waveform"
	@echo " make view_wave4   => View newd_held_high_test waveform"
	@echo " make view_wave5   => View multiple_transfer waveform"
	@echo " make view_wave6   => View done_sig_test waveform"
	@echo " make view_wave7   => View all_zeroes_test waveform"
	@echo " make view_wave8   => View all_ones_test waveform"
	@echo "=========================================================================="

#=========================================================
# MAIN TARGETS
#=========================================================

clean  : clean_Questa

sv_cmp : sv_cmp_Questa

run_base_test  : TEST1_Questa
run_reset_test  : TEST2_Questa
run_rst_transfer_test  : TEST3_Questa
run_newd_high  : TEST4_Questa
run_multi_transfer  : TEST5_Questa
run_done_sig_test  : TEST6_Questa
run_all_zeroes_test  : TEST7_Questa
run_all_ones_test  : TEST8_Questa
TEST9  : TEST9_Questa

#=========================================================
# COMPILE
#=========================================================

sv_cmp_Questa:
	vlib $(WORK)
	vmap work $(WORK)
	vlog -sv $(INC) $(RTL) $(SVTB)

#=========================================================
# TEST1
#=========================================================

TEST1_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test1.wlf \
	-l test1.log \
	-sv_seed 1111 \
	work.top +TEST1

#=========================================================
# TEST2
#=========================================================

TEST2_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test2.wlf \
	-l test2.log \
	-sv_seed 2222 \
	work.top +RESET_TEST

#=========================================================
# TEST3
#=========================================================

TEST3_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test3.wlf \
	-l test3.log \
	-sv_seed 3113 \
	work.top +RESET_TRANSFER_TEST

#=========================================================
# TEST4
#=========================================================

TEST4_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test4.wlf \
	-l test4.log \
	-sv_seed 4224 \
	work.top +NEWD_HIGH_TEST

#=========================================================
# TEST5
#=========================================================

TEST5_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test5.wlf \
	-l test5.log \
	-sv_seed 5555 \
	work.top +TEST5

#=========================================================
# TEST6
#=========================================================

TEST6_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test6.wlf \
	-l test6.log \
	-sv_seed 6666 \
	work.top +DONE_SIG_TEST

#=========================================================
# TEST7
#=========================================================

TEST7_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test7.wlf \
	-l test7.log \
	-sv_seed random \
	work.top +ALL_ZERO_TEST

#=========================================================
# TEST8
#=========================================================

TEST8_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test8.wlf \
	-l test8.log \
	-sv_seed random \
	work.top +ALL_ONES_TEST

#=========================================================
# TEST9
#=========================================================

TEST9_Questa: sv_cmp_Questa
	vsim $(VSIMOPT) $(VSIMBATCH) \
	-wlf wave_test9.wlf \
	-l test9.log \
	-sv_seed 9999 \
	work.top +TEST9

#=========================================================
# VIEW WAVEFORMS
#=========================================================

view_wave1:
	vsim -view wave_test1.wlf

view_wave2:
	vsim -view wave_test2.wlf

view_wave3:
	vsim -view wave_test3.wlf

view_wave4:
	vsim -view wave_test4.wlf

view_wave5:
	vsim -view wave_test5.wlf

view_wave6:
	vsim -view wave_test6.wlf

view_wave7:
	vsim -view wave_test7.wlf

view_wave8:
	vsim -view wave_test8.wlf

view_wave9:
	vsim -view wave_test9.wlf

#=========================================================
# CLEAN
#=========================================================

clean_Questa:
	rm -rf work
	rm -rf transcript
	rm -rf *.log
	rm -rf *.wlf
	rm -rf modelsim.ini
	clear
