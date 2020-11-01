
#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

bw_sender=100
bw_receiver=100
delay=0

iperf_port=5001
for qsize in 100; do
    dirResult=results
    # Expt 2 : Convergence test for DCTCP vs TCP
    dir=convergenceDCTCP-q$qsize
    dir1=convergenceDCTCP-q$qsize
    time=200
    mkdir $dir 2>/dev/null 

    for i in 1; do
    # Measure throughput over time for 5 flows
    python dctcp.py --bw-sender $bw_sender \
                  --bw-receiver $bw_receiver \
                  --delay $delay \
                  --dir $dir \
                  --maxq $qsize \
                  --time $time \
                  --n 6 \
                  --enable-ecn 1 \
                  --enable-dctcp 1 \
                  --expt 2

    # Parse the iperf.txt files for each sender 
    python parse_iperf.py --n 6 --dir $dir
    
    # Plot convergence graph
    python plot_throughput.py -f $dir/iperf1-plot.txt $dir/iperf2-plot.txt \
                                 $dir/iperf3-plot.txt $dir/iperf4-plot.txt \
                                 $dir/iperf5-plot.txt --legend flow1 flow2 \
                                 flow3 flow4 flow5 -o \
                                 $dirResult/convergenceDCTCP.png
    python plot_queue.py -f $dir/q.txt  -o $dirResult/dctcp_queue.png
    
    done
    #rm -rf $dir
    # Repeat above for TCP
    dir=convergenceTCP-q$qsize
    dir2=convergenceTCP-q$qsize
    time=200
    mkdir $dir 2>/dev/null 
    for i in 1; do
    python dctcp.py --bw-sender $bw_sender \
                    --bw-receiver $bw_receiver \
                    --delay $delay \
                    --dir $dir \
                    --maxq $qsize \
                    --time $time \
                    --n 6 \
                    --enable-ecn 0 \
                    --enable-dctcp 0 \
                    --expt 2
    python parse_iperf.py --n 6 --dir $dir
    python plot_throughput.py -f $dir/iperf1-plot.txt $dir/iperf2-plot.txt \
                                 $dir/iperf3-plot.txt $dir/iperf4-plot.txt \
                                 $dir/iperf5-plot.txt --legend flow1 flow2 \
                                 flow3 flow4 flow5 -o \
                                 $dirResult/convergenceTCP.png
    python plot_queue.py -f $dir/q.txt  -o $dirResult/tcp_queue.png
    python plot_queue_2.py -f $dir1/q.txt $dir2/q.txt  -o $dirResult/total_queue.png
    done
done
