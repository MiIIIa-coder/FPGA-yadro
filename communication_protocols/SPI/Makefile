all:
	rm -rf log.txt
	iverilog -g2005-sv -DICARUS=1 -o tb.qqq tb.sv
	vvp tb.qqq >> /dev/null >> log.txt
	gtkwave tb.vcd