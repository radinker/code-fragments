// ====================================================================================
//  brief         Fragment 1 -- Polymorphism
//  author        Jose Arboleda
//  date          2024
//  copyright     MIT License
// ====================================================================================
use std::boxed::Box;

// A trait with some default behavior
trait X {
    fn print(&self) {
        println!("This is trait X's default behavior");
    }
}

struct A;
struct B;
struct C;

// Multiple implementations of trait X
impl X for A {
    fn print(&self) {
        println!("This is X impl for A!");
    }
}

impl X for B {
    fn print(&self) {
        println!("This is X impl for B!");
    }
}

impl X for C {}

fn main() {
    println!("\nPolymorphism using references");
    println!("====================================================================================");
    let a = A {};
    let b = B {};
    let mut x: &dyn X = &a;

    x.print(); // A's override

    x = &b;
    x.print(); // B's override

    println!("\nUsing raw pointers");
    println!("====================================================================================");
    let mut x_ptr: *const dyn X = &b;
    unsafe {
        (*x_ptr).print(); // B's override
    }

    x_ptr = &a;
    unsafe {
        (*x_ptr).print(); // A's override
    }

   println!("\nUsing smart pointers");
   println!("====================================================================================");
   let mut x_sptr: Box<dyn X> = Box::new(B {}); // B's override
   x_sptr.print();

   x_sptr = Box::new(A {}); // A's override
   x_sptr.print();

   println!("\nAccessing trait X's default behavior");
   println!("====================================================================================");
   let c = C {};
   c.print();
}

