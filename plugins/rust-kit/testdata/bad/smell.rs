#![allow(dead_code)]

use std::mem;

pub unsafe fn raw_ptr(p: *const u8) -> u8 {
    *p
}

pub fn transmute_u32(x: u32) -> [u8; 4] {
    unsafe { mem::transmute(x) }
}

#[no_mangle]
pub extern "C" fn exported(x: i32) -> i32 {
    x
}

pub fn unfinished() {
    todo!("not done");
}

pub fn also_unfinished() {
    unimplemented!()
}

use std::sync::Mutex;

pub fn poison_unwrap(m: &Mutex<i32>) -> i32 {
    *m.lock().unwrap()
}
