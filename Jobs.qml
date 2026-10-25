// SPDX-License-Identifier: MIT
import QtQuick
import Quickshell
import Quickshell.Io

// A queue of commands run a few at a time: run(["ffprobe", ...], text => ...) calls back with what the command printed.
Scope {
    id: jobs

    property int workers: 4
    property var waiting: []
    property var pool: []
    property int pending: 0
    signal finished()

    function run(command, done) {
        waiting.push({ command, done });
        pending++;
        pump();
    }
    function pump() {
        for (const worker of pool) {
            if (waiting.length === 0) return;
            if (!worker.running) worker.start(waiting.shift());
        }
    }

    Instantiator {
        model: jobs.workers
        delegate: Process {
            id: worker
            property var done
            function start(job) {
                done = job.done;
                command = job.command;
                running = true;
            }
            stdout: StdioCollector { id: out }
            onExited: {
                worker.done(out.text);
                jobs.pending--;
                jobs.pump();
                jobs.finished();
            }
        }
        onObjectAdded: (i, worker) => jobs.pool.push(worker)
    }
}
