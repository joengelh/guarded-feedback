// The 'guarded_feedback' program.
program guarded_feedback.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}
