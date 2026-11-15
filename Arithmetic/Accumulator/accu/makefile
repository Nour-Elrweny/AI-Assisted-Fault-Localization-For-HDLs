.PHONY: vcs sim clean

TEST_DESIGN = accu

vcs:
		vcs +incdir+./  -R -timescale=1ns/100ps -fsdb  -full64  +vc  +v2k  -LDFLAGS -Wl,--no-as-needed -sverilog -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a ${TEST_DESIGN}.v testbench.v

sim:
		./simv -l run.log

clean:
		rm -rf *.log  csrc  simv*  *.key *.vpd  DVEfiles coverage *.vdb output.txt
