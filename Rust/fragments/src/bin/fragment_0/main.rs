// ====================================================================================
//  brief         Fragment 0 -- Async Executor
//  author        Jose Arboleda
//  date          2024
//  copyright     MIT License
// ====================================================================================
use std::future::Future;
use std::pin::{Pin, pin};
use std::sync::{Arc, Condvar, Mutex};
use std::sync::atomic::{AtomicI32, AtomicU32, Ordering};
use std::task::{Context, Poll, Wake};
use std::time::Duration;
use std::thread::{sleep, spawn};

use rand::Rng;

// Some definitions to perform a dummy IO operation
// ====================================================================================
const  IO_IDLE:    i32 = 0;
const  IO_PENDING: i32 = 1;
const  IO_READY:   i32 = 2;

const  IO_DELAY:   u64 = 1;


// Just a function to perform some dummy IO and set the IO_VALUE to a random number
fn perform_io() -> u32 {
    let mut rng = rand::thread_rng();

    // I/O bound time
    sleep(Duration::from_secs(IO_DELAY));

    rng.gen::<u32>() % 100
}

// Async executor implementation
// ====================================================================================

// Waker that uses a conditional variable to implement the wake API
struct EventWaker {
    lock: Mutex<i32>,
    var: Condvar
}

impl Wake for EventWaker {
    fn wake(self: Arc<Self>) {
        let _guard = self.lock.lock().unwrap();
        self.var.notify_one();
    }
}

// The actual async executor to block on a given future
fn exec_block_on<T>(f: impl Future<Output = T>) -> T {
    let mut future = pin!(f);

    // This pointer to the waker is needed to block on the conditional variable
    let event_waker = Arc::new(EventWaker{lock: Mutex::new(0),
        var: Condvar::new()});

    let waker = event_waker.clone().into();
    let mut cx = Context::from_waker(&waker);

    loop {
        match future.as_mut().poll(&mut cx) {
            Poll::Ready(res) => return res,
            Poll::Pending => {
                let   guard = event_waker.lock.lock().unwrap();
                let _unused = event_waker.var.wait(guard).unwrap();
            }
        }
    }
}

// Future trait implementation
// ====================================================================================

// Structure to share data atomically
struct SharedData {
    pub status: AtomicI32,
    pub result: AtomicU32
}

impl SharedData {
    pub fn new() -> Self {
        SharedData{status: AtomicI32::new(IO_IDLE), result: AtomicU32::new(0)}
    }
}

// Future implementation with shared data to hold the IO operation state and result
struct FutureValue {
   data: Arc<SharedData>
}

impl Future for FutureValue {
    type Output = u32;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let p_waker = cx.waker().clone();
        let io_status = self.data.status.load(Ordering::SeqCst);

        println!("Polling FutureValue...");

        // When the I/O operation is completed, consume and return the IO_VALUE
        if io_status == IO_READY {
            self.data.status.store(IO_IDLE, Ordering::SeqCst);
            return Poll::Ready(self.data.result.load(Ordering::SeqCst));
        }

        // When there is no ongoing I/O operation, spawn a thread to perform it and
        // notify upon completion
        if io_status == IO_IDLE {
            self.data.status.store(IO_PENDING, Ordering::SeqCst);

            let data = self.data.clone();

            spawn(move || {
                let result = perform_io();

                data.result.store(result, Ordering::SeqCst);
                data.status.store(IO_READY, Ordering::SeqCst);

                p_waker.wake();
            });
        }

        Poll::Pending
    }
}

// ====================================================================================
// Asynchronous function to get a dummy IO value
async fn get_io_value() -> u32 {
    let future = FutureValue{data: Arc::new(SharedData::new())};
    future.await
}

fn main() {

    println!("\nMultiple values");
    println!("====================================================================================");

    for _ in 0..3 {
        let result = exec_block_on(get_io_value());
        println!("Result: {}", result);
    }

    println!("\nMultiple threads");
    println!("====================================================================================");

    let t = spawn(move || {
        let result = exec_block_on(get_io_value());
        println!("Result: {}", result);
    });

    let result = exec_block_on(get_io_value());
    println!("Result: {}", result);

    let _ = t.join();
}
