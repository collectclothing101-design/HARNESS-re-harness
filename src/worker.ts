import { spawn, type ChildProcess } from 'node:child_process';
import process from 'node:process';

export type WorkerExit = { pid: number; code: number | null; signal: NodeJS.Signals | null };
export type WorkerStatus = { activeWorkers: number; lastWorkerPid: number | null; lastWorkerExit: WorkerExit | null };

const WORKER_SOURCE = `
process.on('SIGTERM', () => {});
if (process.send) process.send('ready');
setTimeout(() => process.exit(0), Number(process.argv[1]));
`;

function delay(milliseconds: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, milliseconds));
}

export class WorkerRegistry {
  private readonly active = new Map<number, ChildProcess>();
  private starting = false;
  private lastWorkerPid: number | null = null;
  private lastWorkerExit: WorkerExit | null = null;

  status(): WorkerStatus {
    return { activeWorkers: this.active.size, lastWorkerPid: this.lastWorkerPid, lastWorkerExit: this.lastWorkerExit };
  }

  async run(milliseconds: number, signal: AbortSignal): Promise<{ pid: number; completed: boolean }> {
    if (signal.aborted) throw new Error('request aborted');
    if (this.starting || this.active.size > 0) throw new Error('a worker probe is already active');
    this.starting = true;
    const child = spawn(process.execPath, ['-e', WORKER_SOURCE, String(milliseconds)], { stdio: ['ignore', 'ignore', 'ignore', 'ipc'] });
    const pid = child.pid;
    if (pid === undefined) throw new Error('worker process did not receive a pid');
    this.lastWorkerPid = pid;
    this.lastWorkerExit = null;
    child.once('message', message => {
      if (message === 'ready') {
        this.starting = false;
        this.active.set(pid, child);
      }
    });
    const exited = new Promise<WorkerExit>((resolve, reject) => {
      child.once('error', error => {
        this.starting = false;
        this.active.delete(pid);
        reject(error);
      });
      child.once('exit', (code, exitSignal) => {
        this.starting = false;
        const result = { pid, code, signal: exitSignal };
        this.active.delete(pid);
        this.lastWorkerExit = result;
        resolve(result);
      });
    });
    let abort: () => void = () => {};
    const aborted = new Promise<'aborted'>(resolve => {
      abort = () => resolve('aborted');
      signal.addEventListener('abort', abort, { once: true });
    });
    try {
      const outcome = await Promise.race([exited.then(() => 'exited' as const), aborted]);
      if (outcome === 'exited') return { pid, completed: true };
      child.kill('SIGTERM');
      const graceful = await Promise.race([exited.then(() => true), delay(50).then(() => false)]);
      if (!graceful) child.kill('SIGKILL');
      await Promise.race([
        exited,
        delay(1000).then(() => { throw new Error(`worker process ${pid} did not exit after cancellation`); })
      ]);
      throw new Error('request aborted');
    } finally {
      signal.removeEventListener('abort', abort);
    }
  }
}
