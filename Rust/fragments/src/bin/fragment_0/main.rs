use std::borrow::Borrow;
use std::future::Future;
use std::thread::{sleep, spawn};
use std::task::{Context, Poll, Wake};
use std::time::Duration;
use std::pin::{Pin, pin};
use std::sync::{atomic, Arc, Condvar, Mutex};
use std::result::Result;

static IO_VALUE: atomic::AtomicI32 = atomic::AtomicI32::new(-1);

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

struct DummyWaker {}

impl Wake for DummyWaker {
    fn wake(self: Arc<Self>) {}
}

fn exec_block_on<T>(f: impl Future<Output = T>) -> T {
    let mut future = pin!(f);

    let event_waker = Arc::new(EventWaker{lock: Mutex::new(0), var: Condvar::new()});
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

/*fn exec_try<T>(f: impl Future<Output = T>) -> Result<T, &str> {
    let mut future = pin!(f);

    let waker = Arc::new(DummyWaker{}).into();
    let mut cx = Context::from_waker(&waker);

    match future.as_mut().poll(&mut cx) {
        Poll::Ready(res) => return Ok(res),
        Poll::Pending => Err("Not ready")
    }
}*/

struct FutureValue {
    computing: bool
}

impl Future for FutureValue {
    type Output = i32;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let p_waker = cx.waker().clone();

        if !self.computing {
            Pin::into_inner(self).computing = true;

            spawn(move || {
                sleep(Duration::from_secs(1));
                IO_VALUE.store(100, atomic::Ordering::Relaxed);
                p_waker.wake();
            });

            return Poll::Pending;
        }

        Poll::Ready(IO_VALUE.load(atomic::Ordering::Relaxed))
    }
}

async fn get_value() -> i32 {
    let future = FutureValue{computing: false};
    future.await
}

fn main() {
    let result = exec_block_on(get_value());
    println!("Result: {}", result);
    
}
