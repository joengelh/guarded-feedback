program guarded_feedback_0_5.aleo;

struct Settings:
    ownedby as address;
    voting as u32;
    deposit as u64;

struct Report:
    id as field;
    counter as u128;
    security_deposit as u64;
    block_height as u32;
    content as field;
    solved as boolean;
    comment as field;
    rewards as u64;
    claimed as boolean;

record user:
    owner as address.private;
    amount as u64.private;

record reported:
    owner as address.private;
    id as field.private;


mapping settings:
	key left as u8.public;
	value right as Settings.public;


mapping counter:
	key left as u8.public;
	value right as u128.public;


mapping reports:
	key left as u128.public;
	value right as Report.public;


mapping ids:
	key left as field.public;
	value right as u128.public;

function configure:
    input r0 as u32.public;
    input r1 as u64.public;

    finalize self.caller r0 r1;

finalize configure:
    input r0 as address.public;
    input r1 as u32.public;
    input r2 as u64.public;
    cast r0 r1 r2 into r3 as Settings;
    set r3 into settings[0u8];


function submit:
    input r0 as field.private;
    input r1 as u64.private;
    input r2 as u32.private;
    hash.bhp256 self.caller into r3 as field;    hash.bhp256 r3 into r4 as field;    add r0 r4 into r5;
    hash.bhp256 r5 into r6 as field;    cast self.caller r6 into r7 as reported.record;
    output r6 as field.private;
    output r7 as reported.record;

    finalize r0 r1 r6 r2;

finalize submit:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as u32.public;
    get settings[0u8] into r4;
    is.eq r4.deposit r1 into r5;
    assert.eq r5 true;
    get.or_use counter[0u8] 0u128 into r6;
    add r6 1u128 into r7;
    set r7 into counter[0u8];
    cast r2 r7 r1 block.height r0 false 0field 0u64 false into r8 as Report;
    set r8 into reports[r7];
    set r7 into ids[r2];


function respond:
    input r0 as u128.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;

    finalize r0 r1 r2 r3 self.caller;

finalize respond:
    input r0 as u128.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;
    input r4 as address.public;
    get settings[0u8] into r5;
    is.eq r4 r5.ownedby into r6;
    assert.eq r6 true;
    get reports[r0] into r7;
    cast r7.id r7.counter r7.security_deposit r7.block_height r7.content r3 r1 r2 r7.claimed into r8 as Report;
    set r8 into reports[r7.counter];


function claim:
    input r0 as u128.private;
    input r1 as field.private;
    input r2 as u64.private;
    hash.bhp256 self.caller into r3 as field;    hash.bhp256 r3 into r4 as field;    add r1 r4 into r5;
    hash.bhp256 r5 into r6 as field;    cast self.caller r2 into r7 as user.record;
    output r7 as user.record;

    finalize r0 r2 r6;

finalize claim:
    input r0 as u128.public;
    input r1 as u64.public;
    input r2 as field.public;
    get reports[r0] into r3;
    is.eq r3.id r2 into r4;
    assert.eq r4 true;
    is.eq r3.claimed false into r5;
    assert.eq r5 true;
    is.eq r3.rewards r1 into r6;
    assert.eq r6 true;
    cast r3.id r3.counter r3.security_deposit r3.block_height r3.content r3.solved r3.comment r3.rewards true into r7 as Report;
    set r7 into reports[r3.counter];
