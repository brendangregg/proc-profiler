# proc-profiler

This is a simple Linux wall-time kernel-stack profiler that reads /proc/PID/stack.

On Linux you should use [perf] for CPU profiling, or [eBPF] for both CPU and off-CPU profiling. Or just about anything else, including application traces. If you actually need my proc-profiler, you must have a really busted up system you need to debug. As I did, when I wrote this thing.

For similar work, see:

- http://poormansprofiler.org/
- https://blog.tanelpoder.com/2013/02/21/peeking-into-linux-kernel-land-using-proc-filesystem-for-quickndirty-troubleshooting/

[perf]: http://www.brendangregg.com/perf.html
[eBPF]: http://www.brendangregg.com/ebpf.html
