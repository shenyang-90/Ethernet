# NOTE : This is *terrible* for perf. It needs to be tweaked to target the area you are interested in.
ida_database -open
ida_probe -log -wave
